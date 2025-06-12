import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_state.dart'; // For DontDisturb
import 'package:custom_form/ui/phone_number/phone_number_page.dart';
import 'package:custom_form/widgets/custom_numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock PhoneNumberCubit
class MockPhoneNumberCubit extends Mock implements PhoneNumberCubit {}

void main() {
  late MockPhoneNumberCubit mockPhoneNumberCubit;
  // const initialPhoneNumberField = BaseFormFieldState(value: '', isValid: false); // Not used directly, part of createState

  // Helper to create initial state, now more complete
  BaseFormState createInitialState({
    bool keypadVisible = true,
    String phoneNumber = '',
    String? error,
    bool isValid = false, // Field validity
    bool isFormValid = false, // Overall form validity
    bool isSubmitting = false,
    bool isSuccess = false,
    bool isFailure = false,
    String? apiError,
  }) {
    return BaseFormState(
      fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: phoneNumber, error: error, isValid: isValid)},
      isKeypadVisible: keypadVisible,
      isFormValid: isFormValid,
      isSubmitting: isSubmitting,
      isSuccess: isSuccess,
      isFailure: isFailure,
      apiError: apiError,
    );
  }

  setUpAll(() {
    registerFallbackValue(const BaseFormState(fields: {}));
  });

  setUp(() {
    mockPhoneNumberCubit = MockPhoneNumberCubit();
    // Default state: keypad visible, empty field, which will have an error by default validator
    when(() => mockPhoneNumberCubit.state).thenReturn(
      createInitialState(
        keypadVisible: true,
        phoneNumber: '',
        error: 'Phone number cannot be empty.', // Cubit init runs validators
        isValid: false,
        isFormValid: false
      )
    );
    when(() => mockPhoneNumberCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockPhoneNumberCubit.submit()).thenAnswer((_) async {});
    when(() => mockPhoneNumberCubit.onPhoneNumberChanged(any())).thenAnswer((_) {});
    when(() => mockPhoneNumberCubit.showKeypad()).thenAnswer((_) {});
    when(() => mockPhoneNumberCubit.hideKeypad()).thenAnswer((_) {});
    when(() => mockPhoneNumberCubit.toggleKeypad()).thenAnswer((_) {});
  });

  Widget createTestWidget({PhoneNumberCubit? cubit}) {
    return MaterialApp(
      home: BlocProvider<PhoneNumberCubit>.value(
        value: cubit ?? mockPhoneNumberCubit,
        child: const PhoneNumberPage(),
      ),
    );
  }

  group('PhoneNumberPage Widget Tests (Cubit-Driven Keypad Visibility)', () {
    testWidgets('renders TextFormField and keypad based on cubit state.isKeypadVisible (true)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Allow controller listener and builder to run

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_hide), findsOneWidget);
    });

    testWidgets('renders TextFormField and no keypad if cubit state.isKeypadVisible is false', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(createInitialState(keypadVisible: false, error: 'Phone number cannot be empty.'));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();


      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsNothing);
      expect(find.byIcon(Icons.keyboard), findsOneWidget);
    });

    testWidgets('tapping TextFormField calls cubit.showKeypad', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextFormField));
      // No pumpAndSettle here, just verify the call
      verify(() => mockPhoneNumberCubit.showKeypad()).called(1);
    });

    testWidgets('tapping suffix icon calls cubit.toggleKeypad', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(createInitialState(keypadVisible: true, error: 'Phone number cannot be empty.'));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.keyboard_hide));
      verify(() => mockPhoneNumberCubit.toggleKeypad()).called(1);

      when(() => mockPhoneNumberCubit.state).thenReturn(createInitialState(keypadVisible: false, error: 'Phone number cannot be empty.'));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.keyboard));
      verify(() => mockPhoneNumberCubit.toggleKeypad()).called(1); // This will be the second overall call if same mock instance logic, but test means 1 per setup.
                                                                  // Let's assume it's a fresh verify for this specific setup.
                                                                  // Corrected: verify counts calls on the mock instance.
    });

    testWidgets('input via CustomNumericKeypad calls cubit.onPhoneNumberChanged', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(createInitialState(keypadVisible: true, error: 'Phone number cannot be empty.'));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // This simulates the keypad's onChanged callback.
      // The controller's listener will also fire. For this test, we care about the keypad's direct call.
      await tester.tap(find.widgetWithText(TextButton, '7'));
      // No pumpAndSettle here as the direct call to cubit is what we're verifying from keypad's onChanged.
      verify(() => mockPhoneNumberCubit.onPhoneNumberChanged('7')).called(1);
    });

    testWidgets('TextFormField displays value from cubit state', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(createInitialState(phoneNumber: '987', keypadVisible: true, error: 'Phone number must be at least 10 digits.'));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, '987'), findsOneWidget);
    });

    testWidgets('submit button calls cubit.submit when form is valid', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(
        createInitialState(phoneNumber: '1234567890', isValid: true, isFormValid: true, keypadVisible: true)
      );
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      verify(() => mockPhoneNumberCubit.submit()).called(1);
    });

    testWidgets('BlocListener: DontDisturb state shows SnackBar, clears field, keypad hidden by cubit state', (WidgetTester tester) async {
      final cubit = MockPhoneNumberCubit();
      final initialStateForTest = createInitialState(phoneNumber: '1234567890', isValid: true, isFormValid: true, keypadVisible: true);
      final dndState = DontDisturb(name: "Test DND", fields: {PhoneNumberCubit.phoneNumberKey: const BaseFormFieldState(value: '1234567890', isValid: true)}, isKeypadVisible: false, isSuccess: true);

      when(() => cubit.state).thenReturn(initialStateForTest);
      when(() => cubit.stream).thenAnswer((_) => Stream.value(dndState));
      // After controller.clear(), listener calls onPhoneNumberChanged(""). Cubit then emits new state with empty field.
      when(() => cubit.onPhoneNumberChanged('')).thenAnswer((_) {
         when(() => cubit.state).thenReturn(createInitialState(keypadVisible: false, phoneNumber: '', error: 'Phone number cannot be empty.'));
      });

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      // The stream emits, listener reacts, controller clears, listener calls onPhoneNumberChanged(""), cubit state updates, builder rebuilds.
      await tester.pumpAndSettle();

      expect(find.text('DND Active for: Test DND'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, ''), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsNothing);
      verify(() => cubit.onPhoneNumberChanged('')).called(1);
    });

    testWidgets('BlocListener: Success state hides keypad via cubit state', (WidgetTester tester) async {
      final cubit = MockPhoneNumberCubit();
      final initialStateForTest = createInitialState(phoneNumber: '1234567890', isValid: true, isFormValid: true, keypadVisible: true);
      final successState = createInitialState(phoneNumber: '1234567890', isValid: true, isFormValid: true, keypadVisible: false).copyWith(isSuccess: true);

      when(() => cubit.state).thenReturn(initialStateForTest);
      when(() => cubit.stream).thenAnswer((_) => Stream.value(successState));
      when(() => cubit.onPhoneNumberChanged('')).thenAnswer((_) {
         when(() => cubit.state).thenReturn(createInitialState(keypadVisible: false, phoneNumber: '', error: 'Phone number cannot be empty.'));
      });

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('Phone Number Submitted!'), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsNothing);
      expect(find.widgetWithText(TextFormField, ''), findsOneWidget);
      verify(() => cubit.onPhoneNumberChanged('')).called(1);
    });

    testWidgets('BlocListener: Failure state hides keypad via cubit state', (WidgetTester tester) async {
      final cubit = MockPhoneNumberCubit();
      final initialStateForTest = createInitialState(phoneNumber: '1234567890', isValid: true, isFormValid: true, keypadVisible: true);
      final failureState = createInitialState(phoneNumber: '1234567890', isValid: true, isFormValid: true, keypadVisible: false).copyWith(isFailure: true, apiError: "Test Error");

      when(() => cubit.state).thenReturn(initialStateForTest);
      when(() => cubit.stream).thenAnswer((_) => Stream.value(failureState));
      // No onPhoneNumberChanged("") call expected here as field isn't typically cleared on general failure.

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      // Cubit state needs to reflect the failure state for the builder too
      when(() => cubit.state).thenReturn(failureState);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Test Error'), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsNothing);
    });

  });
}
