import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Icon + bold title + value line(s), as used on the booking and appointment cards.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;

  /// When set, the row is tappable and shows a chevron.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(130)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.navy.withAlpha(50),
            child: Icon(icon, color: AppColors.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(value),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right),
        ],
      ),
    );
    return Semantics(
      button: onTap != null,
      label: '$title: ${value.replaceAll('\n', ', ')}',
      child: ExcludeSemantics(
        child: onTap == null
            ? content
            : InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: content),
      ),
    );
  }
}
