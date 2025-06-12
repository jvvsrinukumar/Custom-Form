import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/login_phone/cubit/login_phone_cubit.dart';
import 'package:custom_form/ui/login_phone/login_phone_page.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock LoginPhoneCubit
class MockLoginPhoneCubit extends Mock implements LoginPhoneCubit {}

void main() {
  late MockLoginPhoneCubit mockLoginPhoneCubit;

  setUp(() {
    mockLoginPhoneCubit = MockLoginPhoneCubit();
    // STUB THE REVERTED INITIAL STATE (EMPTY, INVALID)
    when(() => mockLoginPhoneCubit.state).thenReturn(const BaseFormState(
      fields: {
        LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '', isValid: false, error: null),
      },
      isFormValid: false, // Form is initially invalid
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
      apiError: null,
    ));
    when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.empty());
    when(() => mockLoginPhoneCubit.close()).thenAnswer((_) async {});
    when(() => mockLoginPhoneCubit.updateField(any(that: equals(LoginPhoneCubit.phoneKey)), any())).thenAnswer((_) {});
    when(() => mockLoginPhoneCubit.submit()).thenAnswer((_) async {});
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<LoginPhoneCubit>.value(
        value: mockLoginPhoneCubit,
        child: const LoginPhonePage(),
      ),
    );
  }

  testWidgets('LoginPhonePage renders correctly and shows initial empty state', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Verify AppBar title
    expect(find.text('Login with Phone'), findsOneWidget);

    // Verify Phone Number AppTextField is present and shows initial empty value
    final phoneAppTextField = find.widgetWithText(AppTextField, 'Phone Number');
    expect(phoneAppTextField, findsOneWidget);

    // Check that the TextField within AppTextField is empty
    final textField = tester.widget<TextField>(find.descendant(of: phoneAppTextField, matching: find.byType(TextField)));
    expect(textField.controller!.text, isEmpty);


    // Verify Submit Button is present and initially DISABLED
    final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
    expect(submitButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(submitButton).enabled, isFalse); // Should be false now
  });

  // The test 'Submit button becomes disabled if phone number is cleared' was removed as it's redundant.

  testWidgets('Submit button becomes enabled if a valid phone number is entered', (WidgetTester tester) async {
    // Initial state is invalid, button disabled (as tested above)
    await tester.pumpWidget(createTestWidget());

    // Verify button is initially disabled
    final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
    expect(tester.widget<ElevatedButton>(submitButton).enabled, isFalse, reason: "Button should be disabled with empty phone initially");

    // Simulate entering a valid number
    final validState = const BaseFormState(
        fields: {
          LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '1234567890', isValid: true, error: null),
        },
        isFormValid: true,
      );
    // When updateField is called with a valid number, the cubit should emit the new valid state.
    when(() => mockLoginPhoneCubit.updateField(LoginPhoneCubit.phoneKey, '1234567890')).thenAnswer((_) {
      when(() => mockLoginPhoneCubit.state).thenReturn(validState);
      when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(validState));
    });

    final phoneField = find.widgetWithText(AppTextField, 'Phone Number');
    await tester.enterText(phoneField, '1234567890');
    await tester.pumpAndSettle(); // Allow bloc to process and rebuild

    expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue, reason: "Button should be enabled with valid phone");
  });

  testWidgets('Shows error message for invalid phone number from cubit', (WidgetTester tester) async {
    final errorState = const BaseFormState(
      fields: {
        LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '123', isValid: false, error: 'Too short'),
      },
      isFormValid: false,
    );
    when(() => mockLoginPhoneCubit.state).thenReturn(errorState);
    when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(errorState));


    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Too short'), findsOneWidget);
  });

  testWidgets('Shows loading indicator when submitting', (WidgetTester tester) async {
    // To test loading, the form must be valid and then submit() called.
    // First, set up the cubit to be in a valid state.
    final validState = const BaseFormState(
      fields: {
        LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '1234567890', isValid: true),
      },
      isFormValid: true,
    );
    when(() => mockLoginPhoneCubit.state).thenReturn(validState);
    when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(validState));

    await tester.pumpWidget(createTestWidget()); // Build with initial (now valid) state for this test.
    await tester.pumpAndSettle();

    // Now, simulate the submission process starting
    final submittingState = validState.copyWith(isSubmitting: true);
    when(() => mockLoginPhoneCubit.submit()).thenAnswer((_) async {
      when(() => mockLoginPhoneCubit.state).thenReturn(submittingState);
      when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(submittingState));
    });

    // Tap the submit button (which should be enabled due to validState)
    final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
    await tester.tap(submitButton);
    await tester.pumpAndSettle(); // Process stream emission for isSubmitting

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

   testWidgets('Calls submit on cubit when button is pressed', (WidgetTester tester) async {
    // Set up a valid state so the button is enabled
    final validState = const BaseFormState(
        fields: {
          LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '1234567890', isValid: true, error: null),
        },
        isFormValid: true,
      );
    when(() => mockLoginPhoneCubit.state).thenReturn(validState);
    when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(validState));
    // Ensure submit is verifiable
    when(() => mockLoginPhoneCubit.submit()).thenAnswer((_) async {});


    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();


    final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
    expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue, reason: "Submit button should be enabled for valid state");
    await tester.tap(submitButton);
    await tester.pump();

    verify(() => mockLoginPhoneCubit.submit()).called(1);
  });

  testWidgets('Phone field restricts input to 10 digits and numerics only', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final phoneFieldFinder = find.byType(AppTextField);
    expect(phoneFieldFinder, findsOneWidget);

    await tester.enterText(phoneFieldFinder, '1234567890123');
    await tester.pump();
    // Check the text in the underlying TextField controller
    final textField = tester.widget<TextField>(find.descendant(of: phoneFieldFinder, matching: find.byType(TextField)));
    expect(textField.controller!.text, '1234567890');

    await tester.enterText(phoneFieldFinder, '123abc45');
    await tester.pump();
    expect(textField.controller!.text, '12345');
  });

}
