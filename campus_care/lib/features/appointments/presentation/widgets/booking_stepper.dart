import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The 1 - 2 - 3 progress line at the top of the booking pages.
class BookingStepper extends StatelessWidget {
  const BookingStepper({super.key, required this.step});

  /// 1..3: the steps up to and including this one are filled.
  final int step;

  @override
  Widget build(BuildContext context) {
    Widget dot(int n) => Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: n <= step ? AppColors.navy : AppColors.navy.withAlpha(90),
          ),
          child: Text('$n',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
        );
    return Semantics(
      label: 'Step $step of 3',
      child: ExcludeSemantics(
        child: Row(
          children: [
            dot(1),
            Expanded(child: Container(height: 1.5, color: AppColors.navy.withAlpha(120))),
            dot(2),
            Expanded(child: Container(height: 1.5, color: AppColors.navy.withAlpha(120))),
            dot(3),
          ],
        ),
      ),
    );
  }
}
