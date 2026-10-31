import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../models/journal_entry.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> fetch(String studentId);
  Future<JournalEntry> add({
    required String studentId,
    required String content,
    int? moodScore,
    List<String> tags = const [],
  });
  Future<void> delete(String entryId);
}

class SupabaseJournalRepository implements JournalRepository {
  SupabaseJournalRepository(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, s) {
      throw AppException.from(e, s);
    }
  }

  @override
  Future<List<JournalEntry>> fetch(String studentId) => _guard(() async {
    final rows = await _client
        .from('journal_entries')
        .select(JournalEntry.selectColumns)
        .eq('student_id', studentId)
        .order('entry_date', ascending: false)
        .order('created_at', ascending: false)
        .limit(200);
    return [for (final r in rows) JournalEntry.fromJson(r)];
  });

  @override
  Future<JournalEntry> add({
    required String studentId,
    required String content,
    int? moodScore,
    List<String> tags = const [],
  }) => _guard(() async {
    final text = content.trim();
    if (text.isEmpty) {
      throw const AppException(
        'Please write something before saving.',
        type: AppErrorType.validation,
      );
    }
    if (text.length > journalMaxLength) {
      throw const AppException(
        'Your entry is too long (maximum 1000 characters).',
        type: AppErrorType.validation,
      );
    }
    final row = await _client
        .from('journal_entries')
        .insert({
          'student_id': studentId,
          'content': text,
          if (moodScore != null) 'mood_score': moodScore,
          'tags': tags,
        })
        .select(JournalEntry.selectColumns)
        .single();
    return JournalEntry.fromJson(row);
  });

  @override
  Future<void> delete(String entryId) => _guard(() async {
    await _client.from('journal_entries').delete().eq('id', entryId);
  });
}
