import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/platform/external_launcher.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../models/safe_web_uri.dart';
import '../../models/wellness_resource.dart';
import '../viewModels/resources_provider.dart';

class ResourceDetailScreen extends StatelessWidget {
  const ResourceDetailScreen({super.key, required this.resourceId});

  final String resourceId;

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<ExternalLauncher>().openWeb(uri);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('We could not open that link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resource = context.select<ResourcesProvider, WellnessResource?>(
      (r) => r.byId(resourceId),
    );
    final link = safeWebUri(resource?.externalUrl);
    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()]),
            const SizedBox(height: 16),
            GlassCard(
              child: resource == null
                  ? const Text('This resource is not available right now.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          resource.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (resource.summary != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            resource.summary!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                        if (resource.body != null &&
                            resource.body!.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          SelectableText(resource.body!),
                        ],
                        if (link != null) ...[
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Open link',
                            onPressed: () => _open(context, link),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
