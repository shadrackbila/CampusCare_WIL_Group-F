import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  static List<DropdownMenuItem<String>> stringItems(List<String> values) => [
        for (final v in values) DropdownMenuItem(value: v, child: Text(v)),
      ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      isExpanded: true,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
