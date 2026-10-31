import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../models/student.dart';

/// All Supabase Auth + profile access lives here. Widgets never call Supabase directly.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  /// Returns true when the project requires email confirmation (no session yet).
  Future<bool> signUp({
    required String studentNumber,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          // `role` is only a hint. The database trigger creates STUDENT accounts only.
          'role': 'student',
          'student_number': studentNumber.trim(),
          'full_name': fullName.trim(),
        },
      );
      // With email confirmation on, Supabase returns an obfuscated user with no
      // identities when the email is already registered.
      if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
        throw const AppException(
          'An account with this email already exists.',
          type: AppErrorType.conflict,
        );
      }
      return res.session == null;
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  /// [identifier] is an email address or a student number.
  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim();
    try {
      if (id.contains('@')) {
        await _client.auth.signInWithPassword(email: id, password: password);
      } else {
        // Student-number login goes through the `student-login` Edge Function so the
        // email address is never exposed to the app or to anonymous callers.
        final res = await _client.functions.invoke(
          'student-login',
          body: {'student_number': id, 'password': password},
        );
        final data = res.data;
        final refresh = data is Map ? data['refresh_token'] as String? : null;
        if (refresh == null) {
          throw const AppException(
            'Incorrect student number or password.',
            type: AppErrorType.auth,
          );
        }
        await _client.auth.setSession(refresh);
      }
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  Future<void> signOut({bool localOnly = false}) async {
    try {
      await _client.auth.signOut(
        scope: localOnly ? SignOutScope.local : SignOutScope.global,
      );
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  /// Always succeeds from the caller's point of view (no account enumeration).
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: AppConfig.passwordResetRedirect,
      );
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  /// The logged-in user's student row, or null if the account has no student profile.
  /// RLS guarantees a student can only ever read their own row.
  Future<Student?> fetchStudent() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final row = await _client
          .from('students')
          .select(Student.selectColumns)
          .eq('user_id', uid)
          .maybeSingle();
      return row == null ? null : Student.fromJson(row);
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  /// Non-critical streak bookkeeping. Failures are ignored on purpose.
  Future<void> recordLogin() async {
    try {
      await _client.rpc('record_login');
    } catch (_) {}
  }
}
