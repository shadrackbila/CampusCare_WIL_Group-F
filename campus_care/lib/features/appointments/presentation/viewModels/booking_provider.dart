import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/sa_time.dart';
import '../../data/appointment_repository.dart';
import '../../models/appointment.dart';
import '../../models/practitioner.dart';
import '../../models/support_service.dart';

enum BookingStep { practitioner, schedule, confirm, booked }

enum GenderFilter { all, male, female }

/// State of one run through the booking flow. Created when the flow opens and thrown
/// away when it closes. The database has the final say: the chosen slot is re-checked
/// when booking, and a "slot taken" answer sends the student back to pick another.
class BookingProvider extends ChangeNotifier {
  BookingProvider(this._repo, {DateTime Function()? clock, this.onBooked})
    : _clock = clock ?? DateTime.now;

  final AppointmentRepository _repo;
  final DateTime Function() _clock;
  final VoidCallback? onBooked;

  /// How many months ahead (after the current one) the calendar may go.
  /// Students may only book this many days ahead (must match booking_max_date() in 08_booking_window.sql).
  static const maxDaysAhead = 21;

  BookingStep _step = BookingStep.practitioner;
  List<Practitioner> _practitioners = const [];
  List<SupportService> _services = const [];
  SupportService? _service;
  bool _loadingSetup = false;
  String? _setupError;

  GenderFilter _filter = GenderFilter.all;
  Practitioner? _practitioner; // null = no preference
  bool _practitionerChosen = false;

  late DateTime _month = _firstOfMonth(saToday(_clock()));
  Set<DateTime> _availableDates = const {};
  bool _loadingDates = false;
  DateTime? _date;
  List<String> _slots = const [];
  bool _loadingSlots = false;
  String? _time;
  String? _scheduleError;

  bool _booking = false;
  String? _confirmError;
  Appointment? _booked;

  int _datesGen = 0;
  int _slotsGen = 0;
  bool _disposed = false;

  BookingStep get step => _step;
  List<SupportService> get services => _services;
  SupportService? get service => _service;
  bool get loadingSetup => _loadingSetup;
  String? get setupError => _setupError;
  GenderFilter get filter => _filter;
  Practitioner? get practitioner => _practitioner;
  bool get practitionerChosen => _practitionerChosen;
  DateTime get month => _month;
  Set<DateTime> get availableDates => _availableDates;
  bool get loadingDates => _loadingDates;
  DateTime? get selectedDate => _date;
  List<String> get slots => _slots;
  bool get loadingSlots => _loadingSlots;
  String? get selectedTime => _time;
  String? get scheduleError => _scheduleError;
  bool get booking => _booking;
  String? get confirmError => _confirmError;
  Appointment? get booked => _booked;
  DateTime get today => saToday(_clock());

  /// Last bookable day (inclusive).
  DateTime get maxBookableDate => today.add(const Duration(days: maxDaysAhead));

  bool isBookable(DateTime d) {
    final day = DateTime.utc(d.year, d.month, d.day);
    return !day.isBefore(today) && !day.isAfter(maxBookableDate);
  }

  List<Practitioner> get visiblePractitioners {
    switch (_filter) {
      case GenderFilter.all:
        return _practitioners;
      case GenderFilter.male:
        return _practitioners.where((p) => p.gender == 'male').toList();
      case GenderFilter.female:
        return _practitioners.where((p) => p.gender == 'female').toList();
    }
  }

  bool get hasPractitioners => _practitioners.isNotEmpty;

  bool get canGoPrevMonth => _month.isAfter(_firstOfMonth(today));
  bool get canGoNextMonth => _month.isBefore(_firstOfMonth(maxBookableDate));

  bool get canContinueFromSchedule => _date != null && _time != null;

  static DateTime _firstOfMonth(DateTime d) => DateTime.utc(d.year, d.month, 1);

  // ---- Setup ----

  Future<void> loadSetup() async {
    _loadingSetup = true;
    _setupError = null;
    _notify();
    try {
      final r = await Future.wait<Object?>([
        _repo.fetchPractitioners(),
        _repo.fetchServices(),
      ]);
      _practitioners = r[0] as List<Practitioner>;
      _services = r[1] as List<SupportService>;
      _service = SupportService.defaultOf(_services);
    } on AppException catch (e) {
      _setupError = e.message;
    } finally {
      _loadingSetup = false;
      _notify();
    }
  }

  void setFilter(GenderFilter f) {
    if (f == _filter) return;
    _filter = f;
    _notify();
  }

  void setService(SupportService s) {
    _service = s;
    _notify();
  }

  // ---- Step 1: practitioner ----

  /// [p] null means "No preference".
  void choosePractitioner(Practitioner? p) {
    final changed = !_practitionerChosen || _practitioner?.id != p?.id;
    _practitioner = p;
    _practitionerChosen = true;
    if (changed) {
      _date = null;
      _time = null;
      _slots = const [];
      _availableDates = const {};
    }
    _step = BookingStep.schedule;
    _scheduleError = null;
    _notify();
    if (changed || _availableDates.isEmpty) unawaited(_loadMonth());
  }

  // ---- Step 2: date and time ----

  void changeMonth(int delta) {
    final next = DateTime.utc(_month.year, _month.month + delta, 1);
    if (delta < 0 && !canGoPrevMonth) return;
    if (delta > 0 && !canGoNextMonth) return;
    _month = next;
    _availableDates = const {};
    _notify();
    unawaited(_loadMonth());
  }

  Future<void> reloadMonth() => _loadMonth();

  Future<void> _loadMonth() async {
    final gen = ++_datesGen;
    final t = today;
    final first = _month;
    final monthEnd = DateTime.utc(_month.year, _month.month + 1, 0);
    final max = maxBookableDate;
    final last = monthEnd.isAfter(max) ? max : monthEnd;
    final from = first.isBefore(t) ? t : first;
    _loadingDates = true;
    _scheduleError = null;
    _notify();
    if (last.isBefore(from)) {
      _availableDates = const {};
      _loadingDates = false;
      _notify();
      return;
    }
    try {
      final dates = await _repo.fetchAvailableDates(
        practitionerId: _practitioner?.id,
        from: from,
        to: last,
      );
      if (gen != _datesGen) return;
      _availableDates = dates.toSet();
    } on AppException catch (e) {
      if (gen != _datesGen) return;
      _scheduleError = e.message;
      _availableDates = const {};
    } finally {
      if (gen == _datesGen) {
        _loadingDates = false;
        _notify();
      }
    }
  }

  Future<void> selectDate(DateTime d) async {
    if (!isBookable(d)) return;
    _date = DateTime.utc(d.year, d.month, d.day);
    _time = null;
    _slots = const [];
    _notify();
    await _loadSlots();
  }

  Future<void> _loadSlots() async {
    final date = _date;
    if (date == null) return;
    final gen = ++_slotsGen;
    _loadingSlots = true;
    _scheduleError = null;
    _notify();
    try {
      final slots = await _repo.fetchSlots(
        practitionerId: _practitioner?.id,
        date: date,
      );
      if (gen != _slotsGen) return;
      _slots = slots;
    } on AppException catch (e) {
      if (gen != _slotsGen) return;
      _scheduleError = e.message;
      _slots = const [];
    } finally {
      if (gen == _slotsGen) {
        _loadingSlots = false;
        _notify();
      }
    }
  }

  Future<void> reloadSlots() => _loadSlots();

  void selectTime(String t) {
    if (!_slots.contains(t)) return;
    _time = t;
    _notify();
  }

  void continueToConfirm() {
    if (!canContinueFromSchedule) return;
    _confirmError = null;
    _step = BookingStep.confirm;
    _notify();
  }

  // ---- Step 3: confirm ----

  Future<void> confirm() async {
    final date = _date;
    final time = _time;
    final service = _service;
    if (_booking || date == null || time == null) return;
    if (service == null) {
      _confirmError =
          'Booking is not available right now. Please try again later.';
      _notify();
      return;
    }
    _booking = true;
    _confirmError = null;
    _notify();
    try {
      final id = await _repo.book(
        serviceId: service.id,
        date: date,
        time: time,
        practitionerId: _practitioner?.id,
      );
      Appointment? appt;
      try {
        appt = await _repo.fetchOne(id);
      } on AppException {
        // The booking succeeded; only the details lookup failed, so show what we know.
        final parts = time.split(':');
        appt = Appointment(
          id: id,
          date: date,
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
          status: AppointmentStatus.confirmed,
          serviceName: service.name,
          practitionerName: _practitioner?.displayName,
          noPreference: _practitioner == null,
        );
      }
      _booked = appt;
      _step = BookingStep.booked;
      onBooked?.call();
    } on AppException catch (e) {
      if (e.type == AppErrorType.validation) {
        // Slot taken (or similar): back to the calendar with fresh availability.
        _scheduleError = e.message;
        _time = null;
        _step = BookingStep.schedule;
        unawaited(_loadMonth().then((_) => _loadSlots()));
      } else {
        _confirmError = e.message;
      }
    } finally {
      _booking = false;
      _notify();
    }
  }

  // ---- Navigation ----

  /// Goes back one step. Returns false when already at the first step (caller closes the flow).
  bool back() {
    switch (_step) {
      case BookingStep.practitioner:
      case BookingStep.booked:
        return false;
      case BookingStep.schedule:
        _step = BookingStep.practitioner;
      case BookingStep.confirm:
        _step = BookingStep.schedule;
    }
    _notify();
    return true;
  }

  void editDateTime() {
    _step = BookingStep.schedule;
    _notify();
  }

  void editPractitioner() {
    _step = BookingStep.practitioner;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
