import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Five numbered circles (1-5). Used by the emotional check-in.
class RatingScale extends StatelessWidget {
  const RatingScale({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Spoken by screen readers, e.g. "Stress level".
  final String label;
  final int? value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 1; i <= 5; i++)
          Semantics(
            button: true,
            selected: value == i,
            label: '$label, $i of 5',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? () => onChanged(i) : null,
              child: Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value == i ? AppColors.navy : Colors.white.withAlpha(110),
                  border: Border.all(color: Colors.white.withAlpha(180)),
                ),
                child: ExcludeSemantics(
                  child: Text(
                    '$i',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: value == i ? Colors.white : AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
