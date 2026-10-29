import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/error_banner.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/practitioner_avatar.dart';
import '../../viewModels/booking_provider.dart';
import '../../widgets/booking_stepper.dart';

class SelectPractitionerStep extends StatelessWidget {
  const SelectPractitionerStep({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();
    final all = p.filter == GenderFilter.all;
    final title = all
        ? 'Select Practitioner'
        : (p.filter == GenderFilter.male
              ? 'Male Practitioners'
              : 'Female Practitioners');
    final subtitle = all
        ? 'Choose a practitioner or continue with no preference.'
        : 'Select a practitioner.';
    final list = p.visiblePractitioners;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BookingStepper(step: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              const PractitionerAvatar(size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(subtitle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (all && p.hasPractitioners) ...[
            Row(
              children: [
                for (final f in GenderFilter.values) ...[
                  Expanded(
                    child: _FilterPill(filter: f, selected: p.filter == f),
                  ),
                  if (f != GenderFilter.female) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (p.loadingSetup)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (p.setupError != null) ...[
            ErrorBanner(p.setupError!),
            TextButton(
              onPressed: () => context.read<BookingProvider>().loadSetup(),
              child: const Text('Try again'),
            ),
          ] else ...[
            if (all)
              _PersonTile(
                leading: const Icon(
                  Icons.block,
                  size: 36,
                  color: AppColors.navy,
                ),
                title: 'No Preference',
                subtitle: "I don't mind who I see",
                onTap: () =>
                    context.read<BookingProvider>().choosePractitioner(null),
              ),
            for (final pr in list)
              _PersonTile(
                leading: PractitionerAvatar(photoUrl: pr.photoUrl, seed: pr.id),
                title: pr.displayName,
                subtitle: pr.roleLabel,
                onTap: () =>
                    context.read<BookingProvider>().choosePractitioner(pr),
              ),
            if (!p.hasPractitioners)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No practitioners are available to book right now. Please check again later.',
                ),
              )
            else if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No ${p.filter == GenderFilter.male ? 'male' : 'female'} practitioners are available right now.',
                ),
              ),
            if (!all) ...[
              const SizedBox(height: 12),
              Align(
                child: SizedBox(
                  width: 200,
                  child: AppButton(
                    label: 'Return to all',
                    style: AppButtonStyle.outlined,
                    onPressed: () => context.read<BookingProvider>().setFilter(
                      GenderFilter.all,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.filter, required this.selected});

  final GenderFilter filter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      GenderFilter.all => 'All',
      GenderFilter.male => 'Male',
      GenderFilter.female => 'Female',
    };
    return Semantics(
      button: true,
      selected: selected,
      label: '$label practitioners',
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.read<BookingProvider>().setFilter(filter),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected ? AppColors.blue : Colors.white.withAlpha(90),
              border: Border.all(color: Colors.white.withAlpha(130)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: selected ? Colors.white : AppColors.navy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: '$title, $subtitle',
        child: ExcludeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(90),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withAlpha(130)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(child: leading),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(subtitle),
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
