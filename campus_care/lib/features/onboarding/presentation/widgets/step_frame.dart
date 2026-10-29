import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/auth_scaffold.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../viewModels/onboarding_provider.dart';

/// Common layout for every onboarding step: back button, progress, title, error, primary button.
class StepFrame extends StatelessWidget {
  const StepFrame({
    super.key,
    required this.title,
    required this.children,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.loading = false,
    this.error,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool loading;
  final String? error;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OnboardingProvider>();
    final text = Theme.of(context).textTheme;
    final number = p.step.index + 1;

    return AuthScaffold(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (showBack || p.editing)
                  IconButton.filledTonal(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: loading
                        ? null
                        : (p.editing
                              ? () => Navigator.of(context).maybePop()
                              : p.back),
                  ),
                const Spacer(),
                if (!p.editing)
                  Text(
                    'Step $number of ${p.stepCount}',
                    style: text.labelLarge,
                  ),
              ],
            ),
            if (!p.editing) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: number / p.stepCount,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              title,
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: text.bodyLarge),
            ],
            const SizedBox(height: 20),
            if (error != null) ...[
              ErrorBanner(error!),
              const SizedBox(height: 16),
            ],
            ...children,
            const SizedBox(height: 24),
            AppButton(
              label: p.editing ? 'Save changes' : primaryLabel,
              loading: loading,
              onPressed: onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
