import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/screens/account_problem_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/viewModels/auth_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import 'main_tabs.dart';

/// The app's first screen. It picks what to show from the login state, so no route
/// table or redirects are needed. When the state changes (log in, log out...), any
/// page left open on top (like the login form) is closed.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Object? _lastKey;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboarded = auth.student?.onboardingComplete ?? false;
    final key = (auth.status, onboarded);

    if (_lastKey != null && _lastKey != key) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).popUntil((r) => r.isFirst);
        if (auth.status != AuthStatus.signedIn) {
          context.read<MainTabs>().reset();
        }
      });
    }
    _lastKey = key;

    switch (auth.status) {
      case AuthStatus.unknown:
        return const SplashScreen();
      case AuthStatus.signedOut:
        return const WelcomeScreen();
      case AuthStatus.passwordRecovery:
        return const ResetPasswordScreen();
      case AuthStatus.noProfile:
      case AuthStatus.profileError:
        return const AccountProblemScreen();
      case AuthStatus.signedIn:
        return onboarded ? const MainShell() : const OnboardingScreen();
    }
  }
}
