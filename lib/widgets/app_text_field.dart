import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? value; // New: To set text from outside and reflect cubit state
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)? onChanged; // This will be called when the text actually changes
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
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the value passed to the widget changes externally (e.g., from cubit state),
    // and it's different from the controller's current text, update the controller.
    // This ensures the field reflects programmatic changes.
    final newValue = widget.value ?? '';
    if (newValue != _controller.text) {
      _controller.text = newValue;
      // Move cursor to the end after programmatic change
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
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
