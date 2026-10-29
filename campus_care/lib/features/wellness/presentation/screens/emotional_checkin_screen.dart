import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../viewModels/wellness_provider.dart';
import '../widgets/rating_scale.dart';

class EmotionalCheckinScreen extends StatefulWidget {
  const EmotionalCheckinScreen({super.key, this.moodEntryId});

  /// The mood entry saved just before, so the two can be linked.
  final String? moodEntryId;

  @override
  State<EmotionalCheckinScreen> createState() => _EmotionalCheckinScreenState();
}

class _EmotionalCheckinScreenState extends State<EmotionalCheckinScreen> {
  int? _stress;
  int? _coping;
  int? _support;
  String? _error;

  bool get _complete => _stress != null && _coping != null && _support != null;

  Future<void> _save() async {
    if (!_complete) return;
    final wellness = context.read<WellnessProvider>();
    final nav = Navigator.of(context);
    setState(() => _error = null);
    try {
      await wellness.submitEmotional(
        stress: _stress!,
        coping: _coping!,
        support: _support!,
        moodEntryId: widget.moodEntryId,
      );
      if (!mounted) return;
      nav.pushReplacement(AppRoutes.streaks());
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<WellnessProvider>().saving;
    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()]),
            const SizedBox(height: 16),
            const GlassCard(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Center(
                child: Text(
                  'Emotional Check-In',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How do you feel in this moment?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please rate the following areas on a scale from 1 (very low) to 5 (very high).',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Question(
              icon: Icons.bolt,
              title: 'Stress Level',
              question: 'How would you rate your current stress level?',
              value: _stress,
              enabled: !saving,
              onChanged: (v) => setState(() => _stress = v),
            ),
            const SizedBox(height: 12),
            _Question(
              icon: Icons.accessibility_new,
              title: 'Coping',
              question:
                  'How well do you feel you are coping with things at the moment?',
              value: _coping,
              enabled: !saving,
              onChanged: (v) => setState(() => _coping = v),
            ),
            const SizedBox(height: 12),
            _Question(
              icon: Icons.groups,
              title: 'Support',
              question: 'How supported do you feel at the moment?',
              value: _support,
              enabled: !saving,
              onChanged: (v) => setState(() => _support = v),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              ErrorBanner(_error!),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: 'Next',
              loading: saving,
              onPressed: _complete ? _save : null,
            ),
            if (!_complete)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Please answer all three questions to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.icon,
    required this.title,
    required this.question,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final IconData icon;
  final String title;
  final String question;
  final int? value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(question),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RatingScale(
            label: title,
            value: value,
            onChanged: onChanged,
            enabled: enabled,
          ),
        ],
      ),
    );
  }
}
