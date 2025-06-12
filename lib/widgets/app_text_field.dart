import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? value; // New: To set text from outside and reflect cubit state
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)?
      onChanged; // This will be called when the text actually changes
  final Widget? suffixIcon;
  // The existing 'controller' property is removed.

  const AppTextField({
    super.key,
    required this.label,
    this.value,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the internal controller with the initial value from the widget.
    _controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    // The TextField now always uses the internal _controller.
    // Its onChanged callback will propagate to widget.onChanged.
    return TextField(
      controller: _controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged, // Propagate changes upwards
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: widget.suffixIcon,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the internal controller
    super.dispose();
  }
}
