import 'date_format.dart';

/// Form validators. Return null when valid, otherwise a user-facing message.
class Validators {
  const Validators._();

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _studentNumber = RegExp(r'^[A-Za-z0-9]{6,15}$');

  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? studentNumber(String? v) {
    final r = required(v, 'Student number');
    if (r != null) return r;
    return _studentNumber.hasMatch(v!.trim())
        ? null
        : 'Enter a valid student number';
  }

  static String? fullName(String? v) {
    final r = required(v, 'Initials & surname');
    if (r != null) return r;
    return v!.trim().length < 2 ? 'Enter your initials and surname' : null;
  }

  static String? email(String? v) {
    final r = required(v, 'Email address');
    if (r != null) return r;
    return _email.hasMatch(v!.trim()) ? null : 'Enter a valid email address';
  }

  /// Login accepts either a student number or an email address.
  static String? loginIdentifier(String? v) {
    final r = required(v, 'Student number or email');
    if (r != null) return r;
    return v!.contains('@') ? email(v) : studentNumber(v);
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Use letters and at least one number';
    }
    return null;
  }

  static String? loginPassword(String? v) =>
      (v == null || v.isEmpty) ? 'Password is required' : null;

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    return v == original ? null : 'Passwords do not match';
  }

  // ---- Onboarding ----

  static String? phone(String? v, {bool requiredField = true}) {
    final raw = (v ?? '').trim();
    if (raw.isEmpty) return requiredField ? 'Phone number is required' : null;
    final digits = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^\+?\d{9,15}$').hasMatch(digits)
        ? null
        : 'Enter a valid phone number';
  }

  static String? optionalEmail(String? v) =>
      (v == null || v.trim().isEmpty) ? null : email(v);

  static String? postalCode(String? v) {
    final r = required(v, 'Postal code');
    if (r != null) return r;
    return RegExp(r'^\d{4}$').hasMatch(v!.trim()) ? null : 'Enter a 4-digit postal code';
  }

  static String? dateOfBirth(DateTime? d, {DateTime? today}) {
    if (d == null) return 'Date of birth is required';
    final age = ageOn(d, today ?? DateTime.now());
    if (age < 14 || age > 100) return 'Check your date of birth';
    return null;
  }


}
