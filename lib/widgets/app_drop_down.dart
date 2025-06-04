import 'package:custom_form/core/data/drop_down_dm.dart';
import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final DropdownItem? value;
  final List<DropdownItem> items;
  final String? errorText;
  final void Function(DropdownItem?)? onChanged;

  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DropdownItem>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<DropdownItem>(
          value: item,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(item.subTitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
