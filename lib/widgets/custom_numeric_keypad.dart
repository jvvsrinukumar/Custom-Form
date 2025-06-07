import 'package:flutter/material.dart';

class CustomNumericKeypad extends StatelessWidget {
  final TextEditingController controller;
  final int? maxLength;

  const CustomNumericKeypad({
    super.key,
    required this.controller,
    this.maxLength,
  });

  void _handleDigitPress(String digit) {
    final currentText = controller.text;
    if (maxLength == null || currentText.length < maxLength!) {
      controller.text = currentText + digit;
      // Move cursor to the end if necessary (usually handled by controller itself)
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  void _handleBackspacePress() {
    final currentText = controller.text;
    if (currentText.isNotEmpty) {
      controller.text = currentText.substring(0, currentText.length - 1);
      // Move cursor to the end
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  Widget _buildButton(String text, {bool isBackspace = false}) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 2 / 1.2, // Adjust aspect ratio for button size
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (isBackspace) {
              _handleBackspacePress();
            } else {
              _handleDigitPress(text);
            }
          },
          child: isBackspace
              ? const Icon(Icons.backspace_outlined, color: Colors.black, size: 28)
              : Text(
                  text,
                  style: const TextStyle(fontSize: 28, color: Colors.black),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildButton('1'),
              const SizedBox(width: 8),
              _buildButton('2'),
              const SizedBox(width: 8),
              _buildButton('3'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildButton('4'),
              const SizedBox(width: 8),
              _buildButton('5'),
              const SizedBox(width: 8),
              _buildButton('6'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildButton('7'),
              const SizedBox(width: 8),
              _buildButton('8'),
              const SizedBox(width: 8),
              _buildButton('9'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Container()), // Empty space for alignment
              const SizedBox(width: 8),
              _buildButton('0'),
              const SizedBox(width: 8),
              _buildButton('', isBackspace: true),
            ],
          ),
        ],
      ),
    );
  }
}
