import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  const AppTextField({
    super.key,
    required this.label,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
