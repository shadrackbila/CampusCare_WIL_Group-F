import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum AppButtonStyle { filled, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.style = AppButtonStyle.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final filled = style == AppButtonStyle.filled;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: filled ? Colors.white : AppColors.navy,
            ),
          )
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16));
    final action = loading ? null : onPressed;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: filled
          ? FilledButton(
              onPressed: action,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: shape,
              ),
              child: child,
            )
          : OutlinedButton(
              onPressed: action,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy),
                shape: shape,
              ),
              child: child,
            ),
    );
  }
}
