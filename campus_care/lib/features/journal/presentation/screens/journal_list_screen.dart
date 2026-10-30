import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/mood_style.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../models/journal_entry.dart';
import '../viewModels/journal_provider.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final j = context.read<JournalProvider>();
      j.load(silent: j.loaded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final j = context.watch<JournalProvider>();
    return SkyBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<JournalProvider>().load(silent: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              const PageHeader(actions: [NotificationBell()]),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Journal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).push(AppRoutes.journalNew()),
                    icon: const Icon(Icons.add),
                    label: const Text('New Entry'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (j.error != null) ...[
                ErrorBanner(j.error!),
                TextButton(
                  onPressed: () => context.read<JournalProvider>().load(),
                  child: const Text(
                    'Try again',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              if (j.loading && !j.loaded)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (j.entries.isEmpty && j.error == null)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Your journal is empty. Writing down what is on your mind can help. '
                        'Only you and authorised Wellness Centre staff can see your entries.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Write your first entry',
                        onPressed: () =>
                            Navigator.of(context).push(AppRoutes.journalNew()),
                      ),
                    ],
                  ),
                )
              else
                for (final e in j.entries) _EntryCard(entry: e),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateLabel = formatDate(entry.entryDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: 'Journal entry, $dateLabel. ${entry.preview()}',
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: () =>
                Navigator.of(context).push(AppRoutes.journalEntry(entry.id)),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.preview(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (entry.moodScore != null)
                    Icon(
                      MoodStyle.icon(entry.moodScore!),
                      color: MoodStyle.color(entry.moodScore!),
                      size: 30,
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
