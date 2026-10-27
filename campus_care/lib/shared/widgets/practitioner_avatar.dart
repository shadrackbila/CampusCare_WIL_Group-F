import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Round avatar: the practitioner's photo if there is one, otherwise a person icon.
class PractitionerAvatar extends StatelessWidget {
  const PractitionerAvatar({super.key, this.photoUrl, this.seed = '', this.size = 56});

  final String? photoUrl;

  /// Picks a stable pastel colour (e.g. the practitioner id).
  final String seed;
  final double size;

  static const _tints = [
    Color(0xFFC9A98B), Color(0xFFB8B3D9), Color(0xFFA9CDBF), Color(0xFFD3B7D8), Color(0xFFB7C9E2),
  ];

  @override
  Widget build(BuildContext context) {
    final tint = _tints[seed.hashCode.abs() % _tints.length];
    final fallback = Icon(Icons.person, color: AppColors.navy, size: size * 0.55);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: tint.withAlpha(200)),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: (photoUrl == null || photoUrl!.isEmpty)
          ? fallback
          : Image.network(
              photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}
