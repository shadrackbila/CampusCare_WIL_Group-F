import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../models/appointment.dart';
import '../viewModels/appointment_provider.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  AppointmentTab _tab = AppointmentTab.upcoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = context.read<AppointmentProvider>();
      p.load(silent: p.loaded);
    });
  }

  void _book() => Navigator.of(context).push(AppRoutes.book());

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _ask(String title, String body, String yes, String no) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(no),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(yes),
          ),
        ],
      ),
    );
    return r == true;
  }

  Future<void> _cancel(Appointment a) async {
    final provider = context.read<AppointmentProvider>();
    final ok = await _ask(
      'Cancel this appointment?',
      'Your slot will be released for other students.',
      'Cancel appointment',
      'Keep it',
    );
    if (!ok || !mounted) return;
    try {
      await provider.cancel(a.id);
      if (!mounted) return;
      await _showCancelled();
    } on AppException catch (e) {
      if (mounted) _toast(e.message);
    }
  }

  Future<void> _showCancelled() {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.event_busy, size: 40),
        title: const Text('Appointment Canceled'),
        content: const Text(
          'Your appointment has been canceled successfully.\n\n'
          'Your wellbeing matters. Do not hesitate to book again when you need support. We are here for you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _book();
            },
            child: const Text('Rebook Appointment'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(Appointment a) async {
    final provider = context.read<AppointmentProvider>();
    try {
      await provider.confirm(a.id);
      if (mounted) _toast('Appointment confirmed.');
    } on AppException catch (e) {
      if (mounted) _toast(e.message);
    }
  }

  /// "Rebook" on a moved appointment: release the proposed time, then pick a new one.
  Future<void> _rebook(Appointment a) async {
    final provider = context.read<AppointmentProvider>();
    final ok = await _ask(
      'Choose a different time?',
      'The proposed time will be cancelled and you can pick a new one.',
      'Continue',
      'Back',
    );
    if (!ok || !mounted) return;
    try {
      await provider.cancel(a.id);
      if (mounted) _book();
    } on AppException catch (e) {
      if (mounted) _toast(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppointmentProvider>();
    final items = p.forTab(_tab);
    final now = p.nowSa;

    return SkyBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<AppointmentProvider>().load(silent: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              const PageHeader(actions: [NotificationBell()], showBack: false),
              const SizedBox(height: 16),
              const Text(
                'Appointments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final t in AppointmentTab.values) ...[
                    Expanded(
                      child: _TabPill(
                        label: switch (t) {
                          AppointmentTab.upcoming => 'Upcoming',
                          AppointmentTab.past => 'Past',
                          AppointmentTab.cancelled => 'Cancelled',
                        },
                        selected: _tab == t,
                        onTap: () => setState(() => _tab = t),
                      ),
                    ),
                    if (t != AppointmentTab.cancelled) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              if (p.error != null) ...[
                ErrorBanner(p.error!),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.read<AppointmentProvider>().load(),
                    child: const Text(
                      'Try again',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
              if (p.loading && !p.loaded)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (items.isEmpty && p.error == null)
                _Empty(tab: _tab, onBook: _book)
              else
                for (final a in items)
                  AppointmentCard(
                    appointment: a,
                    nowSa: now,
                    busy: p.isBusy(a.id),
                    onCancel: () => _cancel(a),
                    onConfirm: () => _confirm(a),
                    onRebook: () => _rebook(a),
                  ),
              if (_tab == AppointmentTab.cancelled && items.isNotEmpty) ...[
                const SizedBox(height: 4),
                AppButton(
                  label: 'Rebook Appointment',
                  style: AppButtonStyle.outlined,
                  onPressed: _book,
                ),
              ],
              if (_tab != AppointmentTab.cancelled && items.isNotEmpty) ...[
                const SizedBox(height: 4),
                AppButton(label: 'Book an appointment', onPressed: _book),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label appointments',
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: selected ? AppColors.blue : Colors.white.withAlpha(110),
              border: Border.all(color: Colors.white.withAlpha(130)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: selected ? Colors.white : AppColors.navy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.tab, required this.onBook});

  final AppointmentTab tab;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final text = switch (tab) {
      AppointmentTab.upcoming => 'You have no upcoming appointments.',
      AppointmentTab.past => 'Your past appointments will appear here.',
      AppointmentTab.cancelled =>
        'Here you will find a list of appointments that have been canceled.',
    };
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, textAlign: TextAlign.center),
          if (tab != AppointmentTab.past) ...[
            const SizedBox(height: 16),
            AppButton(label: 'Book an appointment', onPressed: onBook),
          ],
        ],
      ),
    );
  }
}
