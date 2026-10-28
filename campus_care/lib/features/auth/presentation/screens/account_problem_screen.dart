import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/auth_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../viewModels/auth_provider.dart';

/// Logged in but no usable student profile: staff accounts, or the profile failed to load.
class AccountProblemScreen extends StatelessWidget {
  const AccountProblemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loadFailed = auth.status == AuthStatus.profileError;
    final text = Theme.of(context).textTheme;

    return AuthScaffold(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loadFailed
                  ? "We couldn't load your profile"
                  : 'No student profile found',
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              loadFailed
                  ? 'Check your connection and try again.'
                  : 'This account is not linked to a student profile. If you are a student, '
                        'please contact the CUT Wellness Centre. This app is for students only.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (loadFailed) ...[
              AppButton(label: 'Retry', onPressed: auth.refreshStudent),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: 'Log out',
              style: AppButtonStyle.outlined,
              onPressed: auth.signOut,
            ),
          ],
        ),
      ),
    );
  }
}
