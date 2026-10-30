import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/sky_background.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../models/wellness_resource.dart';
import '../viewModels/resources_provider.dart';

IconData resourceIcon(String? code) {
  switch (code) {
    case 'brain':
      return Icons.psychology;
    case 'tree':
      return Icons.park;
    case 'book':
      return Icons.menu_book;
    case 'heart':
      return Icons.favorite;
    case 'run':
      return Icons.directions_run;
    case 'crisis':
      return Icons.crisis_alert;
    default:
      return Icons.article_outlined;
  }
}

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final r = context.read<ResourcesProvider>();
      r.loadHub(silent: r.loaded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.watch<ResourcesProvider>();
    return SkyBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<ResourcesProvider>().loadHub(silent: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              const PageHeader(actions: [NotificationBell()]),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Your wellbeing matters',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Explore resources, tools and support to help you feel your best.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (r.error != null) ...[
                ErrorBanner(r.error!),
                TextButton(
                  onPressed: () => context.read<ResourcesProvider>().loadHub(),
                  child: const Text(
                    'Try again',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              if (r.loading && !r.loaded)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else ...[
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: [
                    for (final c in r.categories) _CategoryTile(category: c),
                  ],
                ),
                if (r.featured.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Featured Resources',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final item in r.featured) ResourceCard(resource: item),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final ResourceCategory category;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: category.name,
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(
            context,
          ).push(AppRoutes.resourceCategory(category.id)),
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  resourceIcon(category.icon),
                  size: 32,
                  color: AppColors.navy,
                ),
                const SizedBox(height: 6),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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

class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.resource});

  final WellnessResource resource;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: '${resource.title}. ${resource.summary ?? ''}',
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () =>
                Navigator.of(context).push(AppRoutes.resourceItem(resource.id)),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.volunteer_activism,
                    color: AppColors.blue,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (resource.summary != null &&
                            resource.summary!.isNotEmpty)
                          Text(resource.summary!),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
