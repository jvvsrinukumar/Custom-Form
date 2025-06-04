import 'package:flutter/material.dart';

class AppCheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final String? errorText;
  final ValueChanged<bool?> onChanged;

  const AppCheckboxField({
    super.key,
    required this.label,
    required this.value,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(child: Text(label)),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
