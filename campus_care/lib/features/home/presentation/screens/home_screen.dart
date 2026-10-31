import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/main_tabs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sa_time.dart';
import '../../../../shared/models/mood_level.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../auth/presentation/viewModels/auth_provider.dart';
import '../../../messaging/presentation/open_peer_chat.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../wellness/presentation/viewModels/wellness_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WellnessProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final w = context.watch<WellnessProvider>();
    final streak = w.checkinStreak;

    return SkyBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<WellnessProvider>().load(silent: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              PageHeader(
                actions: const [NotificationBell()],
                showBack: false,
                trailing: IconButton.filledTonal(
                  tooltip: 'Profile',
                  icon: const Icon(Icons.person),
                  onPressed: () =>
                      context.read<MainTabs>().select(AppTab.profile),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${greetingFor(DateTime.now())},\n${auth.student?.displayName ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your wellbeing matters,\nYou're not alone.",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  _StreakBadge(
                    days: streak,
                    onTap: () =>
                        Navigator.of(context).push(AppRoutes.streaks()),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (w.error != null) ...[
                ErrorBanner(w.error!),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.read<WellnessProvider>().load(),
                    child: const Text(
                      'Try again',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              _CheckInCard(todayScore: w.todayMood?.score),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Tile(
                        icon: Icons.calendar_month,
                        title: 'Book an appointment',
                        subtitle:
                            'Schedule a session with a psychologist or counsellor.',
                        onTap: () => AppNav.toTab(
                          context,
                          AppTab.appointments,
                          then: AppRoutes.book(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Tile(
                        icon: Icons.chat_bubble,
                        title: 'Peer support',
                        subtitle:
                            'Chat with a peer educator for immediate support.',
                        onTap: () => openPeerChat(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Tile(
                        icon: Icons.menu_book,
                        title: 'Journal',
                        subtitle:
                            'Write down your thoughts and track your progress.',
                        onTap: () =>
                            Navigator.of(context).push(AppRoutes.journal()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Tile(
                        icon: Icons.bookmark,
                        title: 'Wellness Resources',
                        subtitle:
                            'Access helpful articles, tips and resources.',
                        onTap: () =>
                            Navigator.of(context).push(AppRoutes.resources()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SosBanner(
                onTap: () => Navigator.of(context).push(AppRoutes.sos()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days, required this.onTap});

  final int days;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          'Check-in streak: $days ${days == 1 ? 'day' : 'days'}. Open streaks.',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: ExcludeSemantics(
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3E9C8A),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: AppColors.navy,
                    size: 30,
                  ),
                ),
                Text(
                  '$days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  days == 1 ? 'day' : 'days',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.todayScore});

  final int? todayScore;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final done = todayScore != null;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white54,
                child: Icon(
                  Icons.sentiment_satisfied_alt,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      done
                          ? "You've checked in today"
                          : 'How are you feeling today?',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      done
                          ? 'Your latest mood: ${MoodLevel.fromScore(todayScore!).label}. '
                                'You can check in again if things change.'
                          : "Take a quick mood check-in to let us know how you're doing.",
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () =>
                  Navigator.of(context).push(AppRoutes.moodCheckin()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    done ? 'Check in again' : 'Check-In',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: ExcludeSemantics(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.blue),
                    const Spacer(),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SosBanner extends StatelessWidget {
  const _SosBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF7A1020);
    return Semantics(
      button: true,
      label: 'Emergency SOS. Need urgent help? Get assistance now.',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2C9CF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white54),
            ),
            child: const Row(
              children: [
                Icon(Icons.health_and_safety, color: dark),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency SOS',
                        style: TextStyle(
                          color: dark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Need urgent help? Get assistance now.',
                        style: TextStyle(color: dark),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: dark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
