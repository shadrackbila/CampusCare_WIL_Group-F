import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Sky-gradient background + scrollable, keyboard-safe body used by all auth screens.
/// Swap the gradient for the Figma background image once it is exported.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.showBack = false});

  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.skyTop, AppColors.skyBottom],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showBack)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton.filledTonal(
                          tooltip: 'Back',
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
