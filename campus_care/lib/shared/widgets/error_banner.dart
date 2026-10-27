import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withAlpha(120)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}
