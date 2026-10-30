import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/platform/external_launcher.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/presentation/viewModels/auth_provider.dart';
import '../../../messaging/presentation/open_peer_chat.dart';
import '../../data/safety_repository.dart';
import '../viewModels/sos_provider.dart';

/// Emergency SOS (Figma page 16). Full screen, no tab bar, so nothing competes with the call button.
class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = context.read<AuthProvider>().student?.id;
    if (studentId == null) {
      return const Scaffold(body: Center(child: Text('Please log in again.')));
    }
    return ChangeNotifierProvider<SosProvider>(
      create: (ctx) => SosProvider(
        ctx.read<SafetyRepository>(),
        ctx.read<ExternalLauncher>(),
        studentId: studentId,
      )..load(),
      child: const _SosView(),
    );
  }
}

class _SosView extends StatelessWidget {
  const _SosView();

  Future<void> _dial(
    BuildContext context,
    Future<CallResult> Function() action,
  ) async {
    final result = await action();
    if (result.started || !context.mounted) return;
    // The phone could not open the dialler: show the number so it can still be dialled by hand.
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Please call this number'),
        content: SelectableText(
          'We could not open your phone app.\n\nPlease dial ${result.number} yourself.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sos = context.watch<SosProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8E1B2B), Color(0xFFD9606B), Color(0xFFF2B8BD)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Back',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Emergency SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.health_and_safety,
                      size: 72,
                      color: Color(0xFF8E1B2B),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Emergency SOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Need immediate help?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the button below to connect with emergency support. You are not alone.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: () => _dial(
                          context,
                          context.read<SosProvider>().callEmergency,
                        ),
                        icon: const Icon(Icons.call),
                        label: const Text(
                          'Call Emergency Support',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calls ${sos.emergencyNumber}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Other options',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _OptionTile(
                      icon: Icons.call,
                      title: sos.wellnessLabel,
                      subtitle: 'Call ${sos.wellnessNumber}',
                      onTap: () => _dial(
                        context,
                        context.read<SosProvider>().callWellnessCentre,
                      ),
                    ),
                    for (final c in sos.otherPhoneContacts)
                      _OptionTile(
                        icon: Icons.call,
                        title: c.label,
                        subtitle: 'Call ${c.phone}',
                        onTap: () => _dial(
                          context,
                          () => context.read<SosProvider>().callOther(c),
                        ),
                      ),
                    _OptionTile(
                      icon: Icons.chat_bubble,
                      title: sos.peerChatLabel,
                      subtitle: sos.peerChatDescription,
                      onTap: () {
                        context.read<SosProvider>().logPeerChat();
                        openPeerChat(context);
                      },
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

class _OptionTile extends StatelessWidget {
  const _OptionTile({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: '$title. $subtitle',
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(110),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.blue),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(subtitle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
