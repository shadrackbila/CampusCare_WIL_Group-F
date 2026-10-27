import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppErrorType {
  network,
  auth,
  permission,
  validation,
  notFound,
  conflict,
  unknown,
}

/// The only error type the UI ever sees. Raw Supabase/database errors are
/// converted here so users get readable messages and nothing sensitive leaks.
class AppException implements Exception {
  const AppException(
    this.message, {
    this.type = AppErrorType.unknown,
    this.cause,
  });

  final String message;
  final AppErrorType type;
  final Object? cause;

  static const _generic = 'Something went wrong. Please try again.';

  @override
  String toString() => 'AppException($type): $message';

  factory AppException.from(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    // Log the error type and code only. Never log payloads or user data.
    if (kDebugMode) debugPrint('[CampusCare] ${error.runtimeType}${_codeOf(error)}');

    // The auth server answered with a 5xx: that is a server-side failure, not the
    // user's connection. Handle it before the generic network branch.
    if (error is AuthRetryableFetchException &&
        (error.statusCode ?? '').toString().startsWith('5')) {
      return AppException(_serverMessage(error), type: AppErrorType.auth, cause: error);
    }
    if (error is AuthRetryableFetchException ||
        error is SocketException ||
        error is TimeoutException ||
        error.runtimeType.toString() == 'ClientException') {
      return AppException(
        'No connection. Check your internet and try again.',
        type: AppErrorType.network,
        cause: error,
      );
    }
    if (error is AuthException) {
      return AppException(_authMessage(error), type: AppErrorType.auth, cause: error);
    }
    if (error is PostgrestException) return _fromPostgrest(error);
    if (error is FunctionException) return _fromFunction(error);

    return AppException(_generic, cause: error);
  }

  static String _codeOf(Object e) {
    if (e is PostgrestException) return ' code=${e.code}';
    if (e is AuthException) return ' status=${e.statusCode}';
    if (e is FunctionException) return ' status=${e.status}';
    return '';
  }

  static String _serverMessage(AuthException e) {
    // Signup runs a database trigger; a duplicate student number makes it fail with
    // a 500 "Database error saving new user".
    if (e.message.toLowerCase().contains('database error saving new user') ||
        e.statusCode == '500') {
      return 'We could not create your account. That student number or email may '
          'already be registered. Try logging in, or contact support.';
    }
    return 'The service is temporarily unavailable. Please try again shortly.';
  }

  static String _authMessage(AuthException e) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login credentials') || m.contains('invalid_credentials')) {
      return 'Incorrect student number/email or password.';
    }
    if (m.contains('email not confirmed')) {
      return 'Please confirm your email address, then try again.';
    }
    if (m.contains('database error saving new user')) {
      // The signup trigger failed, almost always a duplicate student number.
      return 'That student number or email is already registered. Try logging in instead.';
    }
    if (m.contains('already registered') || m.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (m.contains('university email')) {
      return e.message; // our own signup-hook message
    }
    if (m.contains('rate limit') || m.contains('too many')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }
    if (m.contains('same password') || m.contains('different from the old')) {
      return 'Your new password must be different from your old one.';
    }
    if (m.contains('password') &&
        (m.contains('weak') || m.contains('at least') || m.contains('short'))) {
      return 'Choose a stronger password (at least 8 characters).';
    }
    if (m.contains('expired') || m.contains('otp') || m.contains('invalid token')) {
      return 'That link is invalid or has expired. Please request a new one.';
    }
    if (m.contains('session') && (m.contains('missing') || m.contains('not found'))) {
      return 'Your session has expired. Please log in again.';
    }
    return "We couldn't complete that. Please try again.";
  }

  static AppException _fromPostgrest(PostgrestException e) {
    switch (e.code) {
      case '42501':
        return AppException("You don't have permission to do that.",
            type: AppErrorType.permission, cause: e);
      case '23505':
        return AppException('That already exists.',
            type: AppErrorType.conflict, cause: e);
      case '23514': // check constraint
      case '22P02': // invalid input syntax
        return AppException('Please check the information you entered and try again.',
            type: AppErrorType.validation, cause: e);
      case 'PGRST116':
        return AppException("We couldn't find what you were looking for.",
            type: AppErrorType.notFound, cause: e);
      case 'PGRST301':
        return AppException('Your session has expired. Please log in again.',
            type: AppErrorType.auth, cause: e);
      case 'P0001':
        // Raised deliberately by our own database functions with a friendly message,
        // e.g. "That time slot is no longer available".
        return AppException(e.message, type: AppErrorType.validation, cause: e);
      default:
        return AppException(_generic, cause: e);
    }
  }

  static AppException _fromFunction(FunctionException e) {
    switch (e.status) {
      case 400:
      case 401:
        return AppException('Incorrect student number or password.',
            type: AppErrorType.auth, cause: e);
      case 404:
        return AppException(
            "Student-number sign-in isn't available yet. Please use your university email.",
            type: AppErrorType.notFound,
            cause: e);
      case 429:
        return AppException('Too many attempts. Please wait a few minutes and try again.',
            type: AppErrorType.auth, cause: e);
      default:
        return AppException(_generic, cause: e);
    }
  }
}
