import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_state.dart'; // For DontDisturb
import 'package:custom_form/ui/phone_number/phone_number_page.dart';
import 'package:custom_form/widgets/app_phone_field_with_keypad.dart';
import 'package:custom_form/widgets/custom_numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart'; // For mocking cubit

// Mock PhoneNumberCubit
class MockPhoneNumberCubit extends Mock implements PhoneNumberCubit {}

void main() {
  late MockPhoneNumberCubit mockPhoneNumberCubit;

  setUpAll(() {
    // Register fallback values for any types used with mocktail's verify/when
    // For BaseFormState, if it's complex and specific instances are emitted.
    // However, often for state, direct `when(() => cubit.state).thenReturn(yourState)` is enough.
    // If verify uses methods with non-primitive args, they might need fallbacks.
    registerFallbackValue(const BaseFormState(fields: {}));
  });

  setUp(() {
    mockPhoneNumberCubit = MockPhoneNumberCubit();
    // Stub the initial state
    // Ensure all expected fields in BaseFormState are present.
    when(() => mockPhoneNumberCubit.state).thenReturn(
      const BaseFormState(
        fields: {
          PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '', error: null, isValid: false),
        },
        isFormValid: false,
        isSubmitting: false,
        isSuccess: false,
        isFailure: false,
        apiError: null,
        isKeypadVisible: true, // Default initial state from cubit
      ),
    );
    // Stub the stream for BlocConsumer/BlocBuilder
    when(() => mockPhoneNumberCubit.stream).thenAnswer((_) => const Stream.empty());
    // Stub void methods that might be called if necessary, e.g. if they had default implementations
    // For a pure Mock, this is not strictly needed unless testing interactions on the mock itself.
    // when(() => mockPhoneNumberCubit.onPhoneNumberChanged(any())).thenAnswer((_) async {}); // Not needed if just verifying
    when(() => mockPhoneNumberCubit.submit()).thenAnswer((_) async {}); // To prevent null return for Future
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<PhoneNumberCubit>.value(
        value: mockPhoneNumberCubit,
        child: const PhoneNumberPage(),
      ),
    );
  }

  group('PhoneNumberPage Widget Tests', () {
    testWidgets('renders AppPhoneFieldWithKeypad and submit button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppPhoneFieldWithKeypad), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
    });

    testWidgets('AppPhoneFieldWithKeypad receives correct initial value and error from cubit state', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(
        const BaseFormState(
            fields: {
              PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '123', error: 'Test Error', isValid: false),
            },
            isFormValid: false,
            isKeypadVisible: true),
      );
      await tester.pumpWidget(createTestWidget());

      final appPhoneField = tester.widget<AppPhoneFieldWithKeypad>(find.byType(AppPhoneFieldWithKeypad));
      expect(appPhoneField.value, '123');
      expect(appPhoneField.errorText, 'Test Error');
    });

    testWidgets('tapping keypad in AppPhoneFieldWithKeypad calls cubit.onPhoneNumberChanged', (WidgetTester tester) async {
      // Ensure the cubit is set up to handle onPhoneNumberChanged if it returns a future or specific state.
      // For verify, it's often okay if it's just a void method on the mock.

      await tester.pumpWidget(createTestWidget());

      // Open the keypad within AppPhoneFieldWithKeypad
      // AppPhoneFieldWithKeypad uses an InkWell to toggle its internal keypad visibility state.
      final inkWellFinder = find.descendant(of: find.byType(AppPhoneFieldWithKeypad), matching: find.byType(InkWell));
      expect(inkWellFinder, findsOneWidget);
      await tester.tap(inkWellFinder);
      await tester.pumpAndSettle(); // Let AppPhoneFieldWithKeypad rebuild and show CustomNumericKeypad

      expect(find.byType(CustomNumericKeypad), findsOneWidget);

      // Tap a number on the keypad
      final digitButton = find.descendant(of: find.byType(CustomNumericKeypad), matching: find.widgetWithText(TextButton, '7'));
      expect(digitButton, findsOneWidget);
      await tester.tap(digitButton);
      await tester.pumpAndSettle();

      // Verify that cubit.onPhoneNumberChanged was called
      verify(() => mockPhoneNumberCubit.onPhoneNumberChanged('7')).called(1);
    });

    testWidgets('tapping submit button calls cubit.submit when form is valid', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(
        const BaseFormState(
          fields: {
            PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '1234567890', error: null, isValid: true),
          },
          isFormValid: true,
          isSubmitting: false,
          isKeypadVisible: true,
        ),
      );
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pump();

      verify(() => mockPhoneNumberCubit.submit()).called(1);
    });

    testWidgets('submit button is disabled when form is invalid or submitting', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(
        const BaseFormState(
          fields: {
            PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '123', error: 'Too short', isValid: false),
          },
          isFormValid: false,
          isSubmitting: false,
          isKeypadVisible: true,
        ),
      );
      await tester.pumpWidget(createTestWidget());
      ElevatedButton button = tester.widget(find.widgetWithText(ElevatedButton, 'Next'));
      expect(button.onPressed, isNull);

       when(() => mockPhoneNumberCubit.state).thenReturn(
        const BaseFormState(
          fields: {
            PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '1234567890', error: null, isValid: true),
          },
          isFormValid: true,
          isSubmitting: true,
          isKeypadVisible: true,
        ),
      );
      // Important: Need to pump a new widget if we are changing the cubit instance or its initial setup for stream.
      // Here, we are changing the state the existing mock cubit will return.
      await tester.pumpWidget(createTestWidget()); // Re-pump with same widget tree, cubit mock will provide new state.
      button = tester.widget(find.widgetWithText(ElevatedButton, 'Next'));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows SnackBar for DontDisturb state and calls onPhoneNumberChanged("")', (WidgetTester tester) async {
      final initialState = const BaseFormState(
          fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '1234567890', isValid: true)}, isFormValid: true, isKeypadVisible: true);
      final dndState = DontDisturb(
          name: "Test DND User", fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '1234567890', isValid: true)}, isKeypadVisible: false, isSuccess: true);

      when(() => mockPhoneNumberCubit.stream).thenAnswer((_) => Stream.fromIterable([dndState]));
      when(() => mockPhoneNumberCubit.state).thenReturn(initialState);

      await tester.pumpWidget(createTestWidget()); // Build with initial state
      await tester.pump(); // Process the dndState from the stream to trigger BlocListener

      expect(find.text('DND Active for: Test DND User'), findsOneWidget);
      verify(() => mockPhoneNumberCubit.onPhoneNumberChanged("")).called(1);
    });

    testWidgets('shows SnackBar for general success state and calls onPhoneNumberChanged("")', (WidgetTester tester) async {
      final initialState = const BaseFormState(
          fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '0987654321', isValid: true)}, isFormValid: true, isKeypadVisible: true);
      final successState = const BaseFormState(
          fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '0987654321', isValid: true)}, isFormValid: true, isSuccess: true, isKeypadVisible: false);

      when(() => mockPhoneNumberCubit.stream).thenAnswer((_) => Stream.fromIterable([successState]));
      when(() => mockPhoneNumberCubit.state).thenReturn(initialState);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Phone Number Submitted!'), findsOneWidget);
      verify(() => mockPhoneNumberCubit.onPhoneNumberChanged("")).called(1);
    });

    testWidgets('shows AlertDialog for failure state', (WidgetTester tester) async {
       final initialState = const BaseFormState(
           fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '111', isValid: true)}, isFormValid: true, isKeypadVisible: true);
       final failureState = const BaseFormState(
           fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '111', isValid: true)}, isFailure: true, apiError: 'Network Error', isKeypadVisible: false);

      when(() => mockPhoneNumberCubit.stream).thenAnswer((_) => Stream.fromIterable([failureState]));
      when(() => mockPhoneNumberCubit.state).thenReturn(initialState);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);
    });
  });
}
