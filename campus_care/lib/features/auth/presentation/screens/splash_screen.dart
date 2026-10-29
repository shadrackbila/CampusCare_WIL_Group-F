import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Shown while the app restores the session. The artwork already carries the
/// CUT logo, the app name and the tagline, so only a spinner is drawn on top.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FD),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            // Falls back to a plain gradient if the asset is missing.
            errorBuilder: (_, __, ___) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.skyTop, AppColors.skyBottom],
                ),
              ),
            ),
          ),
          const SafeArea(
            child: Align(
              alignment: Alignment(0, 1.00),
              child: CircularProgressIndicator(color: AppColors.skyTop),
            ),
          ),
        ],
      ),
    );
  }
}
