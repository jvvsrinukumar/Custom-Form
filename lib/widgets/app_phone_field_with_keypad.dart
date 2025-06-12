import 'package:custom_form/widgets/custom_numeric_keypad.dart';
import 'package:flutter/material.dart';

class AppPhoneFieldWithKeypad extends StatefulWidget {
  final String label;
  final String? value;
  final String? errorText;
  final Function(String) onChanged;
  final VoidCallback? onSubmit; // Optional: if submit button is part of this widget
  final bool isSubmitting; // Optional: to show loading state if submit is here

  const AppPhoneFieldWithKeypad({
    super.key,
    required this.label,
    this.value,
    this.errorText,
    required this.onChanged,
    this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  _AppPhoneFieldWithKeypadState createState() => _AppPhoneFieldWithKeypadState();
}

class _AppPhoneFieldWithKeypadState extends State<AppPhoneFieldWithKeypad> {
  late TextEditingController _controller;
  bool _isKeypadVisible = false; // Internal state for keypad visibility

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    // No listener on controller needed here if keypad directly calls widget.onChanged
  }

  @override
  void didUpdateWidget(covariant AppPhoneFieldWithKeypad oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the external value changes, update the controller,
    // but only if it's different from the controller's current text
    // to avoid interrupting user input or causing loops.
    if (widget.value != null && widget.value != _controller.text) {
      _controller.text = widget.value!;
      // Move cursor to end after programmatic change
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleKeypadVisibility() {
    setState(() {
      _isKeypadVisible = !_isKeypadVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Important for Column containing Positioned Stack
      children: [
        InkWell( // Wrap TextFormField in InkWell to handle tap for keypad
          onTap: _toggleKeypadVisibility,
          child: IgnorePointer( // Makes TextFormField itself not directly interactive via touch
            child: TextFormField(
              controller: _controller,
              readOnly: true, // Text is only changed by keypad
              decoration: InputDecoration(
                labelText: widget.label,
                errorText: widget.errorText,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton( // Using suffixIcon for keypad toggle
                  icon: Icon(_isKeypadVisible ? Icons.keyboard_hide : Icons.keyboard),
                  onPressed: _toggleKeypadVisibility,
                ),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        if (_isKeypadVisible)
          Padding(
            padding: const EdgeInsets.only(top: 8.0), // Add some space
            child: Material( // Ensure keypad has a background
              elevation: 4,
              color: Theme.of(context).colorScheme.surface,
              child: CustomNumericKeypad(
                controller: _controller,
                onChanged: widget.onChanged, // Directly call the passed onChanged
              ),
            ),
          ),
        // Example of including a submit button if needed within this component
        // if (widget.onSubmit != null)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 16.0),
        //     child: ElevatedButton(
        //       onPressed: widget.onSubmit,
        //       child: widget.isSubmitting ? CircularProgressIndicator() : Text("Submit"),
        //     ),
        //   ),
      ],
    );
  }
}
