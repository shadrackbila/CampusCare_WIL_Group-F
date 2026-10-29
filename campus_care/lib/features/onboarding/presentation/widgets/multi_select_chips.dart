import 'package:flutter/material.dart';

/// Pick-many chips (e.g. "Other languages").
class MultiSelectChips extends StatelessWidget {
  const MultiSelectChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.disabled = const {},
    this.enabled = true,
  });

  final String label;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final Set<String> disabled;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final o in options)
              FilterChip(
                label: Text(o),
                selected: selected.contains(o),
                onSelected: (enabled && !disabled.contains(o))
                    ? (on) {
                        final next = {...selected};
                        on ? next.add(o) : next.remove(o);
                        onChanged(next);
                      }
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}
