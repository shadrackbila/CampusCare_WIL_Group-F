import 'package:flutter/material.dart';

/// Dark-blue sky used behind the signed-in screens (Figma home/check-in pages).
/// Opaque, so page transitions never show the previous page through it.
class SkyBackground extends StatelessWidget {
  const SkyBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A2A5E), Color(0xFF1E5AAE), Color(0xFF7FB0E6)],
        ),
      ),
      child: child,
    );
  }
}
