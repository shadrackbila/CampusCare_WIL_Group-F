import 'package:flutter/material.dart';

import '../../../../core/utils/date_format.dart';

class AppDateField extends FormField<DateTime> {
  AppDateField({
    super.key,
    required String label,
    required DateTime firstDate,
    required DateTime lastDate,
    super.initialValue,
    ValueChanged<DateTime?>? onChanged,
    super.validator,
    super.enabled,
  }) : super(
          builder: (state) {
            Future<void> pick() async {
              final fallback = DateTime(DateTime.now().year - 20, 1, 1);
              var start = state.value ?? fallback;
              if (start.isBefore(firstDate)) start = firstDate;
              if (start.isAfter(lastDate)) start = lastDate;
              final picked = await showDatePicker(
                context: state.context,
                initialDate: start,
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked != null) {
                state.didChange(picked);
                onChanged?.call(picked);
              }
            }

            return InkWell(
              onTap: enabled ? pick : null,
              child: InputDecorator(
                isEmpty: state.value == null,
                decoration: InputDecoration(
                  labelText: label,
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(state.value == null ? '' : formatDate(state.value!)),
              ),
            );
          },
        );
}
