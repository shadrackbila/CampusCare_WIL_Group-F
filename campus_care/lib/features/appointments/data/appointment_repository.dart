import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_format.dart';
import '../models/appointment.dart';
import '../models/practitioner.dart';
import '../models/support_service.dart';

/// Booking and appointment management. Students never insert or update appointments
/// directly: booking, cancelling and confirming go through database functions, which
/// re-check availability on the server.
abstract class AppointmentRepository {
  Future<List<Appointment>> fetchMine(String studentId);
  Future<Appointment> fetchOne(String appointmentId);
  Future<List<Practitioner>> fetchPractitioners();
  Future<List<SupportService>> fetchServices();

  /// [practitionerId] null = no preference.
  Future<List<DateTime>> fetchAvailableDates({
    String? practitionerId,
    required DateTime from,
    required DateTime to,
  });

  /// Free start times as "HH:MM". [practitionerId] null = no preference.
  Future<List<String>> fetchSlots({
    String? practitionerId,
    required DateTime date,
  });

  /// Returns the new appointment id.
  Future<String> book({
    required String serviceId,
    required DateTime date,
    required String time,
    String? practitionerId,
  });

  Future<void> cancel(String appointmentId);
  Future<void> confirm(String appointmentId);
}

class SupabaseAppointmentRepository implements AppointmentRepository {
  SupabaseAppointmentRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  @override
  Future<List<Appointment>> fetchMine(String studentId) => _guard(() async {
    final rows = await _client
        .from('appointments')
        .select(Appointment.selectColumns)
        .eq('student_id', studentId)
        .order('appointment_date', ascending: false)
        .order('appointment_time', ascending: false)
        .limit(200);
    return [for (final r in rows) Appointment.fromJson(r)];
  });

  @override
  Future<Appointment> fetchOne(String appointmentId) => _guard(() async {
    final row = await _client
        .from('appointments')
        .select(Appointment.selectColumns)
        .eq('id', appointmentId)
        .single();
    return Appointment.fromJson(row);
  });

  @override
  Future<List<Practitioner>> fetchPractitioners() => _guard(() async {
    final rows = await _client
        .from('practitioners')
        .select(Practitioner.selectColumns)
        .eq('is_active', true)
        .eq('verification_status', 'verified')
        .order('full_name');
    return [for (final r in rows) Practitioner.fromJson(r)];
  });

  @override
  Future<List<SupportService>> fetchServices() => _guard(() async {
    final rows = await _client
        .from('services')
        .select(SupportService.selectColumns)
        .order('name');
    return [for (final r in rows) SupportService.fromJson(r)];
  });

  @override
  Future<List<DateTime>> fetchAvailableDates({
    String? practitionerId,
    required DateTime from,
    required DateTime to,
  }) => _guard(() async {
    final res = await _client.rpc(
      'get_available_dates',
      params: {
        'p_practitioner_id': practitionerId,
        'p_from': toIsoDate(from),
        'p_to': toIsoDate(to),
      },
    );
    return [
      for (final r in (res as List))
        () {
          final d = DateTime.parse(
            ((r as Map)['available_date'] as String).substring(0, 10),
          );
          return DateTime.utc(d.year, d.month, d.day);
        }(),
    ];
  });

  @override
  Future<List<String>> fetchSlots({
    String? practitionerId,
    required DateTime date,
  }) => _guard(() async {
    final res = practitionerId == null
        ? await _client.rpc(
            'get_available_slots_any',
            params: {'p_date': toIsoDate(date)},
          )
        : await _client.rpc(
            'get_available_slots',
            params: {
              'p_practitioner_id': practitionerId,
              'p_date': toIsoDate(date),
            },
          );
    return [
      for (final r in (res as List))
        ((r as Map)['slot_time'] as String).substring(0, 5),
    ];
  });

  @override
  Future<String> book({
    required String serviceId,
    required DateTime date,
    required String time,
    String? practitionerId,
  }) => _guard(() async {
    final res = await _client.rpc(
      'book_appointment',
      params: {
        'p_service_id': serviceId,
        'p_date': toIsoDate(date),
        'p_time': time,
        if (practitionerId != null) 'p_practitioner_id': practitionerId,
      },
    );
    return res as String;
  });

  @override
  Future<void> cancel(String appointmentId) => _guard(() async {
    await _client.rpc(
      'cancel_appointment',
      params: {'p_appointment_id': appointmentId},
    );
  });

  @override
  Future<void> confirm(String appointmentId) => _guard(() async {
    await _client.rpc(
      'confirm_appointment',
      params: {'p_appointment_id': appointmentId},
    );
  });
}
