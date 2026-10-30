import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/sa_time.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../models/journal_entry.dart';
import '../viewModels/journal_provider.dart';
import '../widgets/mood_face_row.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _text = TextEditingController();
  int? _mood;
  final Set<String> _tags = {};
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (_text.text.trim().isEmpty) return true;
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard this entry?'),
        content: const Text('What you have written has not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep writing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return r == true;
  }

  Future<void> _cancel() async {
    if (await _confirmDiscard() && mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final journal = context.read<JournalProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_text.text.trim().isEmpty) {
      setState(() => _error = 'Please write something before saving.');
      return;
    }
    setState(() => _error = null);
    try {
      await journal.add(
        content: _text.text,
        moodScore: _mood,
        tags: [
          for (final t in journalTags)
            if (_tags.contains(t)) t,
        ],
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Entry saved.')));
      if (mounted) nav.pop();
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<JournalProvider>().saving;
    final today = saToday(DateTime.now());
    return PopScope(
      canPop: _text.text.trim().isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmDiscard();
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: SkyBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              PageHeader(actions: const [NotificationBell()], onBack: _cancel),
              const SizedBox(height: 16),
              const Text(
                'Journal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 30),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text('${formatLongDate(today)} ${today.year}'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your thoughts',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _text,
                      enabled: !saving,
                      maxLength: journalMaxLength,
                      minLines: 6,
                      maxLines: 10,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() => _error = null),
                      decoration: InputDecoration(
                        hintText:
                            "Write about what's on your mind...\n(You can be as detailed or brief as you like)",
                        filled: true,
                        fillColor: Colors.white.withAlpha(90),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(150),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'How are you feeling right now? (optional)',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    MoodFaceRow(
                      value: _mood,
                      enabled: !saving,
                      onChanged: (v) => setState(() => _mood = v),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add tags (optional)',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final t in journalTags)
                          FilterChip(
                            label: Text('#$t'),
                            selected: _tags.contains(t),
                            selectedColor: AppColors.navy,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _tags.contains(t)
                                  ? Colors.white
                                  : AppColors.navy,
                            ),
                            checkmarkColor: Colors.white,
                            onSelected: saving
                                ? null
                                : (on) => setState(
                                    () => on ? _tags.add(t) : _tags.remove(t),
                                  ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_error != null) ...[
                      ErrorBanner(_error!),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Cancel',
                            style: AppButtonStyle.outlined,
                            onPressed: saving ? null : _cancel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: 'Save entry',
                            loading: saving,
                            onPressed: _save,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
