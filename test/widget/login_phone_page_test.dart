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
    // STUB THE NEW INITIAL STATE
    when(() => mockLoginPhoneCubit.state).thenReturn(const BaseFormState(
      fields: {
        LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '9000000000', isValid: true, error: null),
      },
      isFormValid: true, // Form is initially valid
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
      apiError: null,
    ));
    when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.empty());
    when(() => mockLoginPhoneCubit.close()).thenAnswer((_) async {});
    // Mock updateField and submit calls that might be used in tests
    // Ensure `any()` matchers are correctly used if arguments vary.
    // For `updateField`, matching specific keys might be better if tests depend on it.
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

  testWidgets('LoginPhonePage renders correctly and shows initial state with pre-filled data', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Verify AppBar title
    expect(find.text('Login with Phone'), findsOneWidget);

    // Verify Phone Number AppTextField is present and shows initial value
    expect(find.byType(AppTextField), findsOneWidget);
    expect(find.widgetWithText(AppTextField, 'Phone Number'), findsOneWidget);
    expect(find.text('9000000000'), findsOneWidget); // Check for initial value

    // Verify Submit Button is present and initially ENABLED
    final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
    expect(submitButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue); // Should be true now
  });

  testWidgets('Submit button becomes disabled if phone number is cleared', (WidgetTester tester) async {
    // Initial state is valid, button enabled (as tested above)
    await tester.pumpWidget(createTestWidget());

    // Simulate clearing the field, cubit updates state to invalid
    final clearedInvalidState = const BaseFormState(
      fields: {
        LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '', isValid: false, error: 'Phone number is required.'),
      },
      isFormValid: false,
    );
    // Configure mock to return this state when updateField is called with empty string
    when(() => mockLoginPhoneCubit.updateField(LoginPhoneCubit.phoneKey, '')).thenAnswer((invocation) {
      when(() => mockLoginPhoneCubit.state).thenReturn(clearedInvalidState);
      // Critical: Make BlocBuilder rebuild by emitting the new state through the stream
      when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(clearedInvalidState));
    });


    final phoneField = find.widgetWithText(AppTextField, 'Phone Number');
    await tester.enterText(phoneField, ''); // Clear the text
    await tester.pumpAndSettle(); // pumpAndSettle to ensure BlocBuilder rebuilds from stream

    final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
    expect(tester.widget<ElevatedButton>(submitButton).enabled, isFalse);
    expect(find.text('Phone number is required.'), findsOneWidget);
  });

  testWidgets('Submit button becomes enabled if an invalid phone number is corrected', (WidgetTester tester) async {
    // 1. Start with an invalid state (e.g., after clearing)
    final initialInvalidState = const BaseFormState(
      fields: {
        LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '', isValid: false, error: 'Phone number is required.'),
      },
      isFormValid: false,
    );
    // Set the initial state of the mock for this specific test
    when(() => mockLoginPhoneCubit.state).thenReturn(initialInvalidState);
    when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(initialInvalidState));

    await tester.pumpWidget(createTestWidget()); // Rebuild with the new initial mock state for this test
    await tester.pumpAndSettle();


    // Verify button is initially disabled
    final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
    expect(tester.widget<ElevatedButton>(submitButton).enabled, isFalse, reason: "Button should be disabled with empty phone");

    // 2. Simulate entering a valid number
    final validState = const BaseFormState(
        fields: {
          LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '1234567890', isValid: true, error: null),
        },
        isFormValid: true,
      );
    when(() => mockLoginPhoneCubit.updateField(LoginPhoneCubit.phoneKey, '1234567890')).thenAnswer((_) {
      when(() => mockLoginPhoneCubit.state).thenReturn(validState);
      when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(validState));
    });

    final phoneField = find.widgetWithText(AppTextField, 'Phone Number');
    await tester.enterText(phoneField, '1234567890');
    await tester.pumpAndSettle();

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
    final submittingState = const BaseFormState(
      fields: {
        // Assuming the initial valid number is still there when submitting starts
        LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '9000000000', isValid: true),
      },
      isFormValid: true,
      isSubmitting: true,
    );
    when(() => mockLoginPhoneCubit.state).thenReturn(submittingState);
    when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(submittingState));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

   testWidgets('Calls submit on cubit when button is pressed', (WidgetTester tester) async {
    // The initial state set in setUp() is already valid and button is enabled.
    // So no need to mock further state changes for updateField for this test.
    // We just need to ensure the mockLoginCubit.state returns the valid state.
     final validInitialState = const BaseFormState(
        fields: {
          LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '9000000000', isValid: true, error: null),
        },
        isFormValid: true,
      );
    when(() => mockLoginPhoneCubit.state).thenReturn(validInitialState);
    // Stream emission can be empty here if not testing BlocBuilder reacting to this specific state,
    // but it's safer to emit if a rebuild is expected or possible.
    when(() => mockLoginPhoneCubit.stream).thenAnswer((_) => Stream.value(validInitialState));
    // Ensure submit is verifiable
    when(() => mockLoginPhoneCubit.submit()).thenAnswer((_) async {});


    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();


    final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
    expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue, reason: "Submit button should be enabled for initial valid state");
    await tester.tap(submitButton);
    await tester.pump(); // Pump after tap to process actions

    verify(() => mockLoginPhoneCubit.submit()).called(1);
  });

  testWidgets('Phone field restricts input to 10 digits and numerics only', (WidgetTester tester) async {
    // This test is independent of the cubit's state, focuses on AppTextField's InputFormatters.
    // However, the initial value from the cubit will be in the field.
    await tester.pumpWidget(createTestWidget());

    final phoneFieldFinder = find.byType(AppTextField);
    expect(phoneFieldFinder, findsOneWidget);

    // Clear initial text to test formatters from scratch
    await tester.enterText(phoneFieldFinder, '');
    await tester.pump();

    // Test max length
    await tester.enterText(phoneFieldFinder, '1234567890123'); // 13 digits
    await tester.pump();
    expect(find.text('1234567890'), findsOneWidget); // Should be truncated to 10

    // Test numeric only
    await tester.enterText(phoneFieldFinder, ''); // Clear again
    await tester.pump();
    await tester.enterText(phoneFieldFinder, '123abc45');
    await tester.pump();
    expect(find.text('12345'), findsOneWidget); // 'abc' should be filtered out
  });

}
