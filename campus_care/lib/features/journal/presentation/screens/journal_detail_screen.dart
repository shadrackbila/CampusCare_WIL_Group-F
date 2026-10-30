import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../shared/models/mood_level.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/mood_style.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../viewModels/journal_provider.dart';

class JournalDetailScreen extends StatefulWidget {
  const JournalDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  bool _deleting = false;

  Future<void> _delete() async {
    final journal = context.read<JournalProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await journal.delete(widget.entryId);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Entry deleted.')));
      if (mounted) nav.pop();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = context.watch<JournalProvider>().byId(widget.entryId);
    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()]),
            const SizedBox(height: 16),
            if (entry == null)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'This entry could not be found.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Back to journal',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              )
            else
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${formatLongDate(entry.entryDate)} ${entry.entryDate.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (entry.moodScore != null)
                          Semantics(
                            label:
                                'Mood: ${MoodLevel.fromScore(entry.moodScore!).label}',
                            child: Icon(
                              MoodStyle.icon(entry.moodScore!),
                              color: MoodStyle.color(entry.moodScore!),
                              size: 34,
                            ),
                          ),
                      ],
                    ),
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final t in entry.tags) Chip(label: Text('#$t')),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    SelectableText(
                      entry.content,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Delete entry',
                      style: AppButtonStyle.outlined,
                      loading: _deleting,
                      onPressed: _delete,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
