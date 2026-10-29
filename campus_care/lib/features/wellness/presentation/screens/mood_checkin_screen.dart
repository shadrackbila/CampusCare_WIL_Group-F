import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/mood_level.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/mood_style.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../viewModels/wellness_provider.dart';

class MoodCheckinScreen extends StatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  int? _score;
  String? _error;

  Future<void> _save({required bool continueToEmotional}) async {
    final score = _score;
    if (score == null) return;
    final wellness = context.read<WellnessProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _error = null);
    try {
      final entry = await wellness.submitMood(score);
      if (!mounted) return;
      if (continueToEmotional) {
        nav.pushReplacement(AppRoutes.emotionalCheckin(entry.id));
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Check-in saved. Well done for checking in!'),
            ),
          );
        nav.pop();
      }
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WellnessProvider>();
    final saving = w.saving;
    final today = w.todayMood;

    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()]),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mood Check-In',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'How are you feeling right now?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your mental health matters. Take a moment to check in with yourself. '
                    'There is no right or wrong answer.',
                  ),
                  if (today != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "You've already checked in today (${MoodLevel.fromScore(today.score).label}). "
                      'Check in again if things have changed.',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final tileW = (c.maxWidth - 24) / 3;
                Widget tile(MoodLevel m) => SizedBox(
                  width: tileW,
                  child: _MoodTile(
                    level: m,
                    selected: _score == m.score,
                    enabled: !saving,
                    onTap: () => setState(() => _score = m.score),
                  ),
                );
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final m in MoodLevel.values.take(3)) tile(m),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final m in MoodLevel.values.skip(3)) ...[
                          tile(m),
                          if (m != MoodLevel.veryGood)
                            const SizedBox(width: 12),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
            if (_score == 1) ...[
              const SizedBox(height: 16),
              const GlassCard(
                padding: EdgeInsets.all(16),
                child: Text(
                  "We're sorry you're feeling this way, and we're glad you checked in. "
                  'You are not alone: you can chat with a peer educator, book an appointment, '
                  'or use Emergency SOS on the Home screen if you need urgent help.',
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_error != null) ...[
              ErrorBanner(_error!),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: "Continue to emotional check-in",
              loading: saving,
              onPressed: _score == null
                  ? null
                  : () => _save(continueToEmotional: true),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Save and finish',
              style: AppButtonStyle.outlined,
              onPressed: (_score == null || saving)
                  ? null
                  : () => _save(continueToEmotional: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.level,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final MoodLevel level;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Mood: ${level.label}',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: enabled ? onTap : null,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(selected ? 170 : 90),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? AppColors.navy : Colors.white.withAlpha(130),
                width: selected ? 3 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  MoodStyle.icon(level.score),
                  size: 52,
                  color: MoodStyle.color(level.score),
                ),
                const SizedBox(height: 8),
                Text(
                  level.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
