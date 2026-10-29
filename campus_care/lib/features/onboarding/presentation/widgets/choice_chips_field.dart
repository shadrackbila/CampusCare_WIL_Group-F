import 'package:flutter/material.dart';

import '../../../../core/constants/options.dart';
import '../../../../core/theme/app_theme.dart';

/// Pick-one chips that work inside a Form (supports validation).
class ChoiceChipsField<T> extends FormField<T> {
  ChoiceChipsField({
    super.key,
    required String label,
    required List<Option<T>> options,
    super.initialValue,
    ValueChanged<T?>? onChanged,
    bool isRequired = true,
    super.enabled,
    String requiredMessage = 'Please choose an option',
  }) : super(
          validator: isRequired ? (v) => v == null ? requiredMessage : null : null,
          builder: (state) {
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
                      ChoiceChip(
                        label: Text(o.label),
                        selected: state.value == o.value,
                        onSelected: enabled
                            ? (selected) {
                                final v = selected ? o.value : null;
                                state.didChange(v);
                                onChanged?.call(v);
                              }
                            : null,
                      ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
}
