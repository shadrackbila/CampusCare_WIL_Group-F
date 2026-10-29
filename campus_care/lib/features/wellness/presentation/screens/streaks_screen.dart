import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../models/weekly_mood.dart';
import '../viewModels/wellness_provider.dart';
import '../widgets/mood_chart.dart';

class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});

  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WellnessProvider>().load(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WellnessProvider>();
    final weeks = w.fourWeeks;
    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()]),
            const SizedBox(height: 16),
            const GlassCard(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 36,
                    color: AppColors.blue,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Streaks',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Stay consistent, build better habits and keep showing up for yourself.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (w.error != null) ...[
              ErrorBanner(w.error!),
              const SizedBox(height: 12),
            ],
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mood & Emotional Tracker. Last 4 weeks',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Average mood each week: 1 = Very Low, 5 = Very Good',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  MoodChart(weeks: weeks),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble, color: AppColors.blue),
                      const SizedBox(width: 10),
                      Expanded(child: Text(WeeklyMood.trendMessage(weeks))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Streaks',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _StreakRow(
              icon: Icons.local_fire_department,
              title: 'Current Streak',
              subtitle: 'Check-ins in a row',
              days: w.checkinStreak,
            ),
            _StreakRow(
              icon: Icons.calendar_month,
              title: 'Login Streak',
              subtitle: "Days you've logged in",
              days: w.loginStreak,
            ),
            _StreakRow(
              icon: Icons.check_circle,
              title: 'Check-In Streak',
              subtitle: "Days you've completed a check-in",
              days: w.streaks.totalCheckinDays,
            ),
            const _StreakRow(
              icon: Icons.star,
              title: 'Keep It Going!',
              subtitle:
                  "Small steps make a big difference. You're building healthier habits.",
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.days,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int? days;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        label: days == null
            ? '$title. $subtitle'
            : '$title. $subtitle: $days ${days == 1 ? 'day' : 'days'}',
        child: ExcludeSemantics(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white70,
                  child: Icon(icon, color: AppColors.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(subtitle, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                if (days != null)
                  Column(
                    children: [
                      Text(
                        '$days',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(days == 1 ? 'day' : 'days'),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
