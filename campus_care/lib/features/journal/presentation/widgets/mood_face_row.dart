import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/mood_level.dart';
import '../../../../shared/widgets/mood_style.dart';

/// Optional 5-level mood picker (tap again to clear). Used by the journal.
class MoodFaceRow extends StatelessWidget {
  const MoodFaceRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final int? value;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in MoodLevel.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Semantics(
                button: true,
                selected: value == m.score,
                label: 'Mood: ${m.label}',
                child: ExcludeSemantics(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: enabled
                        ? () => onChanged(value == m.score ? null : m.score)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withAlpha(
                          value == m.score ? 170 : 90,
                        ),
                        border: Border.all(
                          color: value == m.score
                              ? AppColors.navy
                              : Colors.white.withAlpha(130),
                          width: value == m.score ? 2.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            MoodStyle.icon(m.score),
                            size: 30,
                            color: MoodStyle.color(m.score),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
