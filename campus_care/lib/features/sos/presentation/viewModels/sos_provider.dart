import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/platform/external_launcher.dart';
import '../../data/safety_repository.dart';
import '../../models/dialable_number.dart';
import '../../models/emergency_contact.dart';

class CallResult {
  const CallResult({required this.started, required this.number});

  /// False when the phone could not open the dialler: show [number] so the student can dial it.
  final bool started;
  final String number;
}

/// Emergency SOS. It must work even when the database is unreachable, so every number has a
/// built-in fallback and a failed load is never shown as a blocking error.
class SosProvider extends ChangeNotifier {
  SosProvider(this._repo, this._launcher, {required this.studentId});

  final SafetyRepository _repo;
  final ExternalLauncher _launcher;
  final String studentId;

  /// South Africa's national emergency number from a mobile phone.
  static const fallbackEmergencyNumber = '112';

  /// The CUT Wellness Centre number shown in the design.
  static const fallbackWellnessNumber = '051 507 9020';

  List<EmergencyContact> _contacts = const [];
  bool _loading = false;
  bool _disposed = false;

  bool get loading => _loading;

  EmergencyContact? _first(SosKind kind) {
    for (final c in _contacts) {
      if (c.kind == kind &&
          (kind == SosKind.peerChat || dialableNumber(c.phone) != null)) {
        return c;
      }
    }
    return null;
  }

  String get emergencyNumber =>
      _first(SosKind.emergency)?.phone?.trim() ?? fallbackEmergencyNumber;
  String get wellnessNumber =>
      _first(SosKind.wellnessCentre)?.phone?.trim() ?? fallbackWellnessNumber;
  String get wellnessLabel =>
      _first(SosKind.wellnessCentre)?.label ?? 'Contact Wellness Centre';
  String get peerChatLabel =>
      _first(SosKind.peerChat)?.label ?? 'Chat with a Peer Educator';
  String get peerChatDescription =>
      _first(SosKind.peerChat)?.description ?? 'Available in the app.';

  /// Any further phone contacts the Wellness Centre has added.
  List<EmergencyContact> get otherPhoneContacts => [
    for (final c in _contacts)
      if (c.kind == SosKind.other && dialableNumber(c.phone) != null) c,
  ];

  Future<void> load() async {
    _loading = true;
    _notify();
    try {
      _contacts = await _repo.fetchContacts();
    } on AppException {
      // Keep the fallbacks; the SOS screen still works.
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<CallResult> callEmergency() =>
      _call(emergencyNumber, 'call_emergency');
  Future<CallResult> callWellnessCentre() =>
      _call(wellnessNumber, 'call_wellness_centre');
  Future<CallResult> callOther(EmergencyContact c) =>
      _call(c.phone ?? '', null);

  /// Called when the student opens the peer chat from the SOS screen.
  void logPeerChat() => _log('open_peer_chat');

  Future<CallResult> _call(String number, String? action) async {
    if (action != null) _log(action);
    final dial = dialableNumber(number);
    if (dial == null) return CallResult(started: false, number: number);
    final ok = await _launcher.dial(dial);
    return CallResult(started: ok, number: number);
  }

  /// Best effort and never blocks or delays the call; a failure is not shown to the student.
  void _log(String action) {
    unawaited(_repo.logSos(studentId, action).catchError((Object _) {}));
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
