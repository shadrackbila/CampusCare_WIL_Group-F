import '../../../core/utils/sa_time.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.entryDate,
    required this.content,
    required this.tags,
    this.moodScore,
  });

  final String id;
  final DateTime entryDate; // date only, UTC-flagged
  final String content;
  final List<String> tags;
  final int? moodScore;

  /// First line(s) for the list, cut at [max] characters.
  String preview([int max = 90]) {
    final flat = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return flat.length <= max ? flat : '${flat.substring(0, max).trimRight()}...';
  }

  static const selectColumns = 'id, entry_date, content, mood_score, tags';

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'] as String,
        entryDate: parseDateOnly(j['entry_date'] as String),
        content: (j['content'] as String?) ?? '',
        moodScore: (j['mood_score'] as num?)?.toInt(),
        tags: [for (final t in (j['tags'] as List? ?? const [])) t as String],
      );
}

/// The tags offered in the app (stored without the "#").
const journalTags = ['stress', 'anxiety', 'gratitude', 'other'];
const journalMaxLength = 1000;
