import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/auth_repository.dart';
import '../../data/session_preferences.dart';
import '../../models/student.dart';

enum AuthStatus {
  /// Waiting for the stored session to be restored (cold start).
  unknown,
  signedOut,

  /// User opened a password-reset link; they must choose a new password.
  passwordRecovery,
  signedIn,

  /// Logged in, but the account has no student profile (e.g. a staff account).
  noProfile,

  /// Logged in, but the profile could not be loaded (network/permission).
  profileError,
}

/// Owns session state. Screens call its actions and catch [AppException];
/// the router reacts to [status] changes, so screens never navigate after login.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo, this._prefs) {
    unawaited(_init());
  }

  final AuthRepository _repo;
  final SessionPreferences _prefs;

  StreamSubscription<AuthState>? _sub;
  AuthStatus _status = AuthStatus.unknown;
  Student? _student;
  String? _notice;
  bool _loginRecorded = false;
  bool _disposed = false;

  AuthStatus get status => _status;
  Student? get student => _student;

  Future<bool> loadRememberMe() => _prefs.getRememberMe();

  /// One-shot message for the login screen (e.g. an expired reset link).
  String? takeNotice() {
    final n = _notice;
    _notice = null;
    return n;
  }

  Future<void> _init() async {
    _sub = _repo.authChanges.listen(_onAuthChange, onError: _onAuthError);

    // "Remember me" off: end the stored session on the next cold start.
    if (_repo.currentSession != null && !await _prefs.getRememberMe()) {
      try {
        await _repo.signOut(localOnly: true);
      } catch (_) {}
    }
    // Cold start: the session is restored asynchronously, so never assume
    // "no user" until the initial auth event or this fallback has run.
    if (_status == AuthStatus.unknown) await _syncFromSession();
  }

  void _onAuthChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.passwordRecovery:
        _setStatus(AuthStatus.passwordRecovery);
      case AuthChangeEvent.signedOut:
        _student = null;
        _loginRecorded = false;
        _setStatus(AuthStatus.signedOut);
      case AuthChangeEvent.tokenRefreshed:
        break;
      default:
        unawaited(_syncFromSession());
    }
  }

  void _onAuthError(Object error) {
    _notice = AppException.from(error).message;
    _notify();
  }

  Future<void> _syncFromSession() async {
    if (_status == AuthStatus.passwordRecovery) return;
    if (_repo.currentSession == null) {
      _student = null;
      _setStatus(AuthStatus.signedOut);
      return;
    }
    await _loadStudent();
  }

  Future<void> _loadStudent() async {
    try {
      final s = await _repo.fetchStudent();
      if (s == null) {
        _student = null;
        _setStatus(AuthStatus.noProfile);
      } else {
        _student = s;
        _setStatus(AuthStatus.signedIn);
        if (!_loginRecorded) {
          _loginRecorded = true;
          unawaited(_repo.recordLogin());
        }
      }
    } on AppException {
      _setStatus(AuthStatus.profileError);
    }
  }

  void _setStatus(AuthStatus s) {
    _status = s;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ---- Actions (throw AppException on failure) ----

  Future<void> signIn({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    await _prefs.setRememberMe(rememberMe);
    await _repo.signIn(identifier: identifier, password: password);
    // The auth stream drives the status change; the router does the navigation.
  }

  /// Returns true if the project requires email confirmation before first login.
  Future<bool> signUp({
    required String studentNumber,
    required String fullName,
    required String email,
    required String password,
  }) =>
      _repo.signUp(
        studentNumber: studentNumber,
        fullName: fullName,
        email: email,
        password: password,
      );

  Future<void> signOut() => _repo.signOut();

  Future<void> sendPasswordReset(String email) =>
      _repo.sendPasswordReset(email);

  /// Changes the password of the logged-in user (Supabase Auth stores and hashes it).
  Future<void> changePassword(String newPassword) =>
      _repo.updatePassword(newPassword);

  Future<void> completePasswordRecovery(String newPassword) async {
    await _repo.updatePassword(newPassword);
    _setStatus(AuthStatus.unknown);
    await _syncFromSession();
  }

  /// Re-read the profile (used after onboarding steps and on "Retry").
  Future<void> refreshStudent() async {
    _setStatus(AuthStatus.unknown);
    await _syncFromSession();
  }

  /// Quietly re-reads the profile (e.g. after the preferred name changed) without going back
  /// through the splash screen. Keeps the current profile if the read fails.
  Future<void> reloadStudent() async {
    if (_status != AuthStatus.signedIn) return;
    try {
      final s = await _repo.fetchStudent();
      if (s != null) {
        _student = s;
        _notify();
      }
    } on AppException {
      // Not important enough to interrupt the student.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}
