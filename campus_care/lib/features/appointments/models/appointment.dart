import '../../../core/utils/date_format.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
  rescheduled,
  pendingConfirmation,
  unknown;

  static AppointmentStatus fromDb(String? s) {
    switch (s) {
      case 'pending':
        return pending;
      case 'confirmed':
        return confirmed;
      case 'cancelled':
        return cancelled;
      case 'completed':
        return completed;
      case 'no_show':
        return noShow;
      case 'rescheduled':
        return rescheduled;
      case 'pending_confirmation':
        return pendingConfirmation;
      default:
        return unknown;
    }
  }
}

enum AppointmentTab { upcoming, past, cancelled }

class Appointment {
  const Appointment({
    required this.id,
    required this.date,
    required this.hour,
    required this.minute,
    required this.status,
    required this.serviceName,
    this.practitionerName,
    this.cancelledBy,
    this.cancellationReason,
    this.rescheduledFrom,
    this.noPreference = false,
  });

  final String id;

  /// Date only (UTC-flagged midnight).
  final DateTime date;
  final int hour;
  final int minute;
  final AppointmentStatus status;
  final String serviceName;
  final String? practitionerName;
  final String? cancelledBy;
  final String? cancellationReason;

  /// For a rescheduled appointment: the original slot (South African wall-clock, UTC-flagged).
  final DateTime? rescheduledFrom;
  final bool noPreference;

  /// South African wall-clock start (UTC-flagged, so it compares with saWallClock()).
  DateTime get startsAt => DateTime.utc(date.year, date.month, date.day, hour, minute);

  String get timeLabel => formatTime12(hour, minute);

  bool get isActive =>
      status == AppointmentStatus.pending ||
      status == AppointmentStatus.confirmed ||
      status == AppointmentStatus.pendingConfirmation;

  bool canCancel(DateTime nowSa) => isActive && startsAt.isAfter(nowSa);

  bool get needsConfirmation => status == AppointmentStatus.pendingConfirmation;

  /// Which list this belongs in. [nowSa] is saWallClock(now).
  AppointmentTab tab(DateTime nowSa) {
    switch (status) {
      case AppointmentStatus.cancelled:
      case AppointmentStatus.rescheduled:
        return AppointmentTab.cancelled;
      case AppointmentStatus.completed:
      case AppointmentStatus.noShow:
      case AppointmentStatus.unknown:
        return AppointmentTab.past;
      case AppointmentStatus.pending:
      case AppointmentStatus.confirmed:
      case AppointmentStatus.pendingConfirmation:
        // Still "upcoming" for the hour it is happening.
        return startsAt.add(const Duration(hours: 1)).isAfter(nowSa)
            ? AppointmentTab.upcoming
            : AppointmentTab.past;
    }
  }

  /// Short label for the status chip.
  String statusLabel(DateTime nowSa) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return tab(nowSa) == AppointmentTab.past ? 'Past' : 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.pendingConfirmation:
        return 'Needs your confirmation';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.noShow:
        return 'Missed';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
      case AppointmentStatus.cancelled:
        final by = cancelledBy;
        if (by == 'admin') return 'Cancelled by admin';
        if (by == 'practitioner') return 'Cancelled by practitioner';
        return 'Cancelled';
      case AppointmentStatus.unknown:
        return 'Past';
    }
  }

  static const selectColumns = 'id, appointment_date, appointment_time, status, cancelled_by, '
      'cancellation_reason, no_preference, practitioners(title, full_name), services(name), '
      'rescheduled_from:appointments!rescheduled_from_id(appointment_date, appointment_time)';

  static DateTime _dateOnly(String s) {
    final p = DateTime.parse(s.substring(0, 10));
    return DateTime.utc(p.year, p.month, p.day);
  }

  static DateTime _dateTime(Map<String, dynamic> j) {
    final d = _dateOnly(j['appointment_date'] as String);
    final t = (j['appointment_time'] as String).split(':');
    return DateTime.utc(d.year, d.month, d.day, int.parse(t[0]), int.parse(t[1]));
  }

  factory Appointment.fromJson(Map<String, dynamic> j) {
    final when = _dateTime(j);
    final pr = j['practitioners'];
    final sv = j['services'];
    final rf = j['rescheduled_from'];
    String? name;
    if (pr is Map<String, dynamic>) {
      final t = (pr['title'] as String?)?.trim() ?? '';
      final n = pr['full_name'] as String? ?? '';
      name = t.isEmpty ? n : '$t $n';
    }
    return Appointment(
      id: j['id'] as String,
      date: DateTime.utc(when.year, when.month, when.day),
      hour: when.hour,
      minute: when.minute,
      status: AppointmentStatus.fromDb(j['status'] as String?),
      serviceName: sv is Map<String, dynamic> ? (sv['name'] as String? ?? 'Support session') : 'Support session',
      practitionerName: name,
      cancelledBy: j['cancelled_by'] as String?,
      cancellationReason: j['cancellation_reason'] as String?,
      rescheduledFrom: rf is Map<String, dynamic> ? _dateTime(rf) : null,
      noPreference: (j['no_preference'] as bool?) ?? false,
    );
  }
}
