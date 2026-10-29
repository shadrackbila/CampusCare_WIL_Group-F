import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../models/mood_entry.dart';
import '../models/streaks.dart';
import '../models/weekly_mood.dart';

/// Mood / emotional check-ins and streaks. The provider depends on this interface so
/// tests can swap in a fake.
abstract class WellnessRepository {
  Future<Streaks> fetchStreaks(String studentId);

  /// Newest mood entry created at or after [sinceUtc], or null.
  Future<MoodEntry?> fetchLatestMoodSince(String studentId, DateTime sinceUtc);

  Future<List<WeeklyMood>> fetchWeekly(String studentId);

  Future<MoodEntry> saveMood({required String studentId, required int score});

  Future<void> saveEmotional({
    required String studentId,
    required int stress,
    required int coping,
    required int support,
    String? moodEntryId,
  });
}

class SupabaseWellnessRepository implements WellnessRepository {
  SupabaseWellnessRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  static void _checkScale(int v) {
    if (v < 1 || v > 5) {
      throw const AppException(
        'Please choose a value from 1 to 5.',
        type: AppErrorType.validation,
      );
    }
  }

  @override
  Future<Streaks> fetchStreaks(String studentId) => _guard(() async {
    final row = await _client
        .from('student_streaks')
        .select()
        .eq('student_id', studentId)
        .maybeSingle();
    return row == null ? Streaks.empty : Streaks.fromJson(row);
  });

  @override
  Future<MoodEntry?> fetchLatestMoodSince(
    String studentId,
    DateTime sinceUtc,
  ) => _guard(() async {
    final rows = await _client
        .from('mood_entries')
        .select(MoodEntry.selectColumns)
        .eq('student_id', studentId)
        .gte('created_at', sinceUtc.toUtc().toIso8601String())
        .order('created_at', ascending: false)
        .limit(1);
    return rows.isEmpty ? null : MoodEntry.fromJson(rows.first);
  });

  @override
  Future<List<WeeklyMood>> fetchWeekly(String studentId) => _guard(() async {
    final rows = await _client
        .from('v_mood_weekly')
        .select()
        .eq('student_id', studentId)
        .order('week_start');
    return [for (final r in rows) WeeklyMood.fromJson(r)];
  });

  @override
  Future<MoodEntry> saveMood({required String studentId, required int score}) =>
      _guard(() async {
        _checkScale(score);
        final row = await _client
            .from('mood_entries')
            .insert({'student_id': studentId, 'mood_score': score})
            .select(MoodEntry.selectColumns)
            .single();
        return MoodEntry.fromJson(row);
      });

  @override
  Future<void> saveEmotional({
    required String studentId,
    required int stress,
    required int coping,
    required int support,
    String? moodEntryId,
  }) => _guard(() async {
    _checkScale(stress);
    _checkScale(coping);
    _checkScale(support);
    await _client.from('emotional_checkins').insert({
      'student_id': studentId,
      'stress_level': stress,
      'coping_level': coping,
      'support_level': support,
      if (moodEntryId != null) 'mood_entry_id': moodEntryId,
    });
  });
}
