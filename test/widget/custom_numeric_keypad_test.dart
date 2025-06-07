import 'package:custom_form/widgets/custom_numeric_keypad.dart'; // Adjust import path if necessary
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomNumericKeypad Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    Future<void> pumpKeypad(WidgetTester tester, {int? maxLength}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomNumericKeypad(
              controller: controller,
              maxLength: maxLength,
            ),
          ),
        ),
      );
    }

    testWidgets('tapping number button appends to controller', (WidgetTester tester) async {
      await pumpKeypad(tester);

      await tester.tap(find.text('1'));
      await tester.pump();
      expect(controller.text, '1');

      await tester.tap(find.text('5'));
      await tester.pump();
      expect(controller.text, '15');
    });

    testWidgets('tapping backspace button removes last character', (WidgetTester tester) async {
      await pumpKeypad(tester);
      controller.text = '123';

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(controller.text, '12');

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(controller.text, '1');
    });

    testWidgets('backspace does nothing on empty controller', (WidgetTester tester) async {
      await pumpKeypad(tester);
      expect(controller.text, '');

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(controller.text, '');
    });

    testWidgets('respects maxLength when appending digits', (WidgetTester tester) async {
      await pumpKeypad(tester, maxLength: 3);

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(controller.text, '123');

      // Try to append another digit
      await tester.tap(find.text('4'));
      await tester.pump();
      expect(controller.text, '123'); // Should not change
    });

    testWidgets('allows appending if maxLength is null', (WidgetTester tester) async {
      await pumpKeypad(tester, maxLength: null); // Or simply omit maxLength

      controller.text = "1234567890"; // 10 digits

      await tester.tap(find.text('1')); // Try to add 11th
      await tester.pump();
      expect(controller.text, '12345678901');
    });
  });
}
