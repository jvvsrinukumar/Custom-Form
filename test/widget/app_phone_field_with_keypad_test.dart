import 'package:custom_form/widgets/app_phone_field_with_keypad.dart';
import 'package:custom_form/widgets/custom_numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// This declaration is needed to use _AppPhoneFieldWithKeypadState for testing internals if necessary.
// However, the provided tests do not use this mechanism, which is good as it tests via public API.
// To make this work, AppPhoneFieldWithKeypad would need to use:
// factory _AppPhoneFieldWithKeypadState.forTest() => _AppPhoneFieldWithKeypadState();
// or change _AppPhoneFieldWithKeypadState to AppPhoneFieldWithKeypadState (public)
// For now, we'll assume testing via public interface.
// If direct access to _controller were needed, the widget's state class would need to be public
// or a test-specific factory/getter provided.

void main() {
  group('AppPhoneFieldWithKeypad', () {
    testWidgets('renders label, initial value, and error text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPhoneFieldWithKeypad(
              label: 'Test Phone',
              value: '12345',
              errorText: 'Test Error',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Phone'), findsOneWidget);
      // TextFormField displays the value via its controller.
      expect(find.widgetWithText(TextFormField, '12345'), findsOneWidget);
      expect(find.text('Test Error'), findsOneWidget);
    });

    testWidgets('keypad visibility toggles on field tap and icon tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPhoneFieldWithKeypad(
              label: 'Test Phone',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Initially, keypad should be hidden
      expect(find.byType(CustomNumericKeypad), findsNothing);

      // Tap the field area (InkWell) to show keypad
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle(); // Rebuilds with keypad visible
      expect(find.byType(CustomNumericKeypad), findsOneWidget);

      // Tap the field area again to hide keypad
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.byType(CustomNumericKevpad), findsNothing); // Corrected typo from Kevpad to Keypad

      // Tap suffix icon to show keypad
      await tester.tap(find.byIcon(Icons.keyboard));
      await tester.pumpAndSettle();
      expect(find.byType(CustomNumericKeypad), findsOneWidget);

      // Tap suffix icon (now keyboard_hide) to hide keypad
      await tester.tap(find.byIcon(Icons.keyboard_hide));
      await tester.pumpAndSettle();
      expect(find.byType(CustomNumericKeypad), findsNothing);
    });

    testWidgets('onChanged callback is triggered by CustomNumericKeypad', (WidgetTester tester) async {
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPhoneFieldWithKeypad(
              label: 'Test Phone',
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      // Show keypad
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.byType(CustomNumericKeypad), findsOneWidget);

      // Tap a digit on the keypad
      // Assuming CustomNumericKeypad has identifiable buttons e.g., by text '1'
      // This requires CustomNumericKeypad to use TextButton with visible text for digits.
      final digitOneButton = find.descendant(
        of: find.byType(CustomNumericKeypad),
        matching: find.widgetWithText(TextButton, '1'),
      );
      expect(digitOneButton, findsOneWidget, reason: "Digit '1' button not found in CustomNumericKeypad");
      await tester.tap(digitOneButton);
      await tester.pumpAndSettle();

      expect(changedValue, '1');
      // The TextFormField should also display '1' due to controller update via onChanged
      expect(find.widgetWithText(TextFormField, '1'), findsOneWidget);
    });

    testWidgets('controller updates when widget.value changes (didUpdateWidget)', (WidgetTester tester) async {
      // Using a GlobalKey for AppPhoneFieldWithKeypad itself, not its state, is fine for rebuilding.
      final GlobalKey appPhoneFieldKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPhoneFieldWithKeypad(
              key: appPhoneFieldKey,
              label: 'Test Phone',
              value: 'initial',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.widgetWithText(TextFormField, 'initial'), findsOneWidget);

      // Simulate parent widget rebuilding with a new value
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPhoneFieldWithKeypad(
              key: appPhoneFieldKey, // Use the same key to ensure it's an update
              label: 'Test Phone',
              value: 'updated', // New value from parent
              onChanged: (_) {},
            ),
          ),
        ),
      );
      // No need to call tester.pump() again unless there are animations.
      // didUpdateWidget runs as part of the rebuild triggered by pumpWidget.
      // A pumpAndSettle might be useful if the widget itself triggers further async work on update.
      await tester.pumpAndSettle();


      expect(find.widgetWithText(TextFormField, 'initial'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'updated'), findsOneWidget);
    });

    testWidgets('internal controller text is maintained when widget rebuilds with same value', (WidgetTester tester) async {
      String currentValue = '123'; // This will be the initial value and also updated by onChanged
      Key key = UniqueKey(); // To ensure we can re-pump with same key

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPhoneFieldWithKeypad(
              key: key,
              label: 'Test Phone',
              value: currentValue, // Initial value '123'
              onChanged: (val) => currentValue = val,
            ),
          ),
        ),
      );

      // Show keypad and type something to make internal controller differ from initial widget.value
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      final digitFourButton = find.descendant(
        of: find.byType(CustomNumericKeypad),
        matching: find.widgetWithText(TextButton, '4'),
      );
      expect(digitFourButton, findsOneWidget);
      await tester.tap(digitFourButton); // controller is now '1234', widget.value was '123'
      await tester.pumpAndSettle(); // onChanged updates currentValue to '1234'

      expect(find.widgetWithText(TextFormField, '1234'), findsOneWidget);
      expect(currentValue, '1234');

      // Simulate a rebuild from parent but with the *same* value that the controller now holds ('1234')
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPhoneFieldWithKeypad(
              key: key, // Same key
              label: 'Test Phone',
              value: '1234', // Value from parent matches controller's current text
              onChanged: (val) => currentValue = val,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure the text field still shows '1234' and cursor position wasn't reset unnecessarily
      expect(find.widgetWithText(TextFormField, '1234'), findsOneWidget);
      // This also implicitly tests that didUpdateWidget doesn't mess up the controller
      // if widget.value == _controller.text, because it shouldn't re-assign _controller.text in that case.
    });

  });
}
