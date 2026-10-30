import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../viewModels/profile_provider.dart';

/// Shared layout for the read-only profile pages: header, title, loading/error handling, and a
/// fresh load each time the page opens.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title, required this.builder});

  final String title;
  final List<Widget> Function(BuildContext context, ProfileProvider profile)
  builder;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    return SkyBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<ProfileProvider>().load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              const PageHeader(actions: [NotificationBell()]),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (p.error != null) ...[
                ErrorBanner(p.error!),
                TextButton(
                  onPressed: () => context.read<ProfileProvider>().load(),
                  child: const Text(
                    'Try again',
                    style: TextStyle(color: Colors.white),
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
              else if (p.loaded)
                ...widget.builder(context, p),
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled card of label/value lines. Empty values show "Not provided".
class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.title,
    required this.rows,
    this.onEdit,
  });

  final String title;

  /// When set, an Edit button is shown in the card header.
  final VoidCallback? onEdit;
  final List<(String, String?)> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(215),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text('Edit', semanticsLabel: 'Edit $title'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      (value == null || value.trim().isEmpty)
                          ? 'Not provided'
                          : value,
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
