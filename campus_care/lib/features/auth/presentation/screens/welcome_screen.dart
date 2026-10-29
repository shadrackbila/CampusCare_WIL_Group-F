import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/auth_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AuthScaffold(
      child: GlassCard(
        child: Column(
          children: [
            Text('CampusCare',
                style: text.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Your wellbeing. Our priority.', style: text.titleMedium),
            const SizedBox(height: 32),
            Text('Welcome to CampusCare',
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
              'A safe and supportive space for your mental health and wellbeing journey at CUT',
              textAlign: TextAlign.center,
              style: text.bodyLarge,
            ),
            const SizedBox(height: 32),
            AppButton(label: 'Get Started', onPressed: () => Navigator.of(context).push(AppRoutes.register())),
            const SizedBox(height: 12),
            AppButton(
              label: 'Log In',
              style: AppButtonStyle.outlined,
              onPressed: () => Navigator.of(context).push(AppRoutes.login()),
            ),
          ],
        ),
      ),
    );
  }
}
