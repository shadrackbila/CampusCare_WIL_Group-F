import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../viewModels/resources_provider.dart';
import 'resources_screen.dart';

class ResourceCategoryScreen extends StatefulWidget {
  const ResourceCategoryScreen({super.key, required this.categoryId});

  final int categoryId;

  @override
  State<ResourceCategoryScreen> createState() => _ResourceCategoryScreenState();
}

class _ResourceCategoryScreenState extends State<ResourceCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ResourcesProvider>().loadCategory(widget.categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.watch<ResourcesProvider>();
    final category = r.categoryById(widget.categoryId);
    final items = r.inCategory(widget.categoryId);
    final error = r.categoryError(widget.categoryId);
    return SkyBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const PageHeader(actions: [NotificationBell()]),
            const SizedBox(height: 16),
            Text(
              category?.name ?? 'Resources',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (category?.code == 'crisis_support')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.of(context).push(AppRoutes.sos()),
                  child: const GlassCard(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.health_and_safety, color: Color(0xFF7A1020)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'In an emergency, use Emergency SOS for immediate help.',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            if (error != null) ...[
              ErrorBanner(error),
              TextButton(
                onPressed: () => context.read<ResourcesProvider>().loadCategory(
                  widget.categoryId,
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            if (r.categoryLoading(widget.categoryId) && items == null)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (items != null && items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'No resources here yet. Please check back soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              )
            else if (items != null)
              for (final item in items) ResourceCard(resource: item),
          ],
        ),
      ),
    );
  }
}
