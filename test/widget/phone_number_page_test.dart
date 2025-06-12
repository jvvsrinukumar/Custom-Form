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
  const initialPhoneNumberFieldValue = ''; // Default value for the phone number field
  const initialPhoneNumberField = BaseFormFieldState(value: initialPhoneNumberFieldValue, error: null, isValid: false);
  // Define a more complete initialBaseFormState that matches what the cubit would provide after its init.
  // Specifically, the validator for an empty string will set an error.
  final initialBaseFormStateWithValidation = BaseFormState(
    fields: {PhoneNumberCubit.phoneNumberKey: initialPhoneNumberField.copyWith(error: 'Phone number cannot be empty.')},
    isFormValid: false, // Since the phone number is empty and has an error
    isSubmitting: false,
    isSuccess: false,
    isFailure: false,
    apiError: null,
    isKeypadVisible: true, // Default for page
  );


  setUpAll(() {
    registerFallbackValue(initialBaseFormStateWithValidation);
  });

  setUp(() {
    mockPhoneNumberCubit = MockPhoneNumberCubit();
    // When cubit.state is accessed, return the detailed initial state.
    when(() => mockPhoneNumberCubit.state).thenReturn(initialBaseFormStateWithValidation);
    when(() => mockPhoneNumberCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockPhoneNumberCubit.submit()).thenAnswer((_) async {});
    when(() => mockPhoneNumberCubit.onPhoneNumberChanged(any())).thenAnswer((_) {});
  });

  Widget createTestWidget({PhoneNumberCubit? cubit}) {
    return MaterialApp(
      home: BlocProvider<PhoneNumberCubit>.value(
        value: cubit ?? mockPhoneNumberCubit,
        child: const PhoneNumberPage(),
      ),
    );
  }

  group('PhoneNumberPage Widget Tests (Stateful)', () {
    testWidgets('renders TextFormField and initially visible CustomNumericKeypad', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      // Wait for any initial frame rendering or state settling if needed, esp. due to BlocProvider.create
      await tester.pumpAndSettle();


      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
       // Check initial error text due to empty phone number
      expect(find.text('Phone number cannot be empty.'), findsOneWidget);
    });

    testWidgets('TextFormField displays initial value from cubit', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(
        BaseFormState(fields: {
          PhoneNumberCubit.phoneNumberKey: const BaseFormFieldState(value: '123', error: null, isValid: false),
        }, isKeypadVisible: true, isFormValid: false), // Assuming '123' is not valid yet by itself
      );
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, '123'), findsOneWidget);
    });

    testWidgets('keypad visibility toggles on suffix icon tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CustomNumericKeypad), findsOneWidget);

      await tester.tap(find.byIcon(Icons.keyboard_hide));
      await tester.pumpAndSettle();
      expect(find.byType(CustomNumericKeypad), findsNothing);

      await tester.tap(find.byIcon(Icons.keyboard));
      await tester.pumpAndSettle();
      expect(find.byType(CustomNumericKeypad), findsOneWidget);
    });

    testWidgets('tapping TextFormField shows keypad if hidden', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(
         initialBaseFormStateWithValidation.copyWith(isKeypadVisible: false),
      );
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CustomNumericKeypad), findsNothing);

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      expect(find.byType(CustomNumericKeypad), findsOneWidget);
    });

    testWidgets('input via CustomNumericKeypad updates TextFormField and calls cubit.onPhoneNumberChanged', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Mock the state change that would happen in the cubit after '7' is entered.
      // The listener in PhoneNumberPage calls onPhoneNumberChanged, then the cubit would emit a new state.
      // The builder in PhoneNumberPage would then use that new state to update the TextFormField.
      when(() => mockPhoneNumberCubit.state).thenReturn(
        initialBaseFormStateWithValidation.copyWith(
          fields: {PhoneNumberCubit.phoneNumberKey: initialPhoneNumberField.copyWith(value: '7', error: 'Phone number must be at least 10 digits.', isValid: false)},
          isFormValid: false,
        )
      );

      await tester.tap(find.widgetWithText(TextButton, '7'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, '7'), findsOneWidget);
      verify(() => mockPhoneNumberCubit.onPhoneNumberChanged('7')).called(1);

      // Mock state change for '78'
       when(() => mockPhoneNumberCubit.state).thenReturn(
        initialBaseFormStateWithValidation.copyWith(
          fields: {PhoneNumberCubit.phoneNumberKey: initialPhoneNumberField.copyWith(value: '78', error: 'Phone number must be at least 10 digits.', isValid: false)},
          isFormValid: false,
        )
      );

      await tester.tap(find.widgetWithText(TextButton, '8'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, '78'), findsOneWidget);
      verify(() => mockPhoneNumberCubit.onPhoneNumberChanged('78')).called(1);
    });

    testWidgets('tapping submit button calls cubit.submit when form is valid', (WidgetTester tester) async {
      when(() => mockPhoneNumberCubit.state).thenReturn(
        const BaseFormState(
          fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '1234567890', error: null, isValid: true)},
          isFormValid: true, isSubmitting: false, isKeypadVisible: true,
        ),
      );
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pump(); // Process tap
      verify(() => mockPhoneNumberCubit.submit()).called(1);
    });

    testWidgets('submit button is disabled when form is invalid or submitting', (WidgetTester tester) async {
      // Test for invalid form
      when(() => mockPhoneNumberCubit.state).thenReturn(
        initialBaseFormStateWithValidation.copyWith(isFormValid: false) // Already has error for empty
      );
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      ElevatedButton button = tester.widget(find.widgetWithText(ElevatedButton, 'Next'));
      expect(button.onPressed, isNull);

      // Test for submitting state
      when(() => mockPhoneNumberCubit.state).thenReturn(
        const BaseFormState(
          fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '1234567890', error: null, isValid: true)},
          isFormValid: true, isSubmitting: true, isKeypadVisible: true,
        ),
      );
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      button = tester.widget(find.widgetWithText(ElevatedButton, 'Next'));
      expect(button.onPressed, isNull);
    });

    testWidgets('BlocListener: DontDisturb state shows SnackBar, clears field, hides keypad', (WidgetTester tester) async {
      final cubit = MockPhoneNumberCubit();
      final validStateBeforeDND = const BaseFormState(fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '1234567890', isValid: true)}, isFormValid: true, isKeypadVisible: true);
      final dndState = DontDisturb(name: "Test DND", fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '1234567890', isValid: true)}, isKeypadVisible: false, isSuccess: true);

      when(() => cubit.state).thenReturn(validStateBeforeDND);
      when(() => cubit.stream).thenAnswer((_) => Stream.value(dndState));
      // After controller.clear(), listener calls onPhoneNumberChanged(""). Cubit then emits new state with empty field.
      when(() => cubit.onPhoneNumberChanged('')).thenAnswer((_) {
         when(() => cubit.state).thenReturn(initialBaseFormStateWithValidation.copyWith(isKeypadVisible: false)); // Reflect empty field and hidden keypad
      });


      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle(); // Process the emitted DND state and subsequent rebuilds

      expect(find.text('DND Active for: Test DND'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, ''), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsNothing);
      verify(() => cubit.onPhoneNumberChanged('')).called(1);
    });

    testWidgets('BlocListener: Success state shows SnackBar, clears field, hides keypad', (WidgetTester tester) async {
      final cubit = MockPhoneNumberCubit();
      final validStateBeforeSuccess = const BaseFormState(fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '0987654321', isValid: true)}, isFormValid: true, isKeypadVisible: true);
      final successState = const BaseFormState(fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '0987654321', isValid: true)}, isFormValid: true, isSuccess: true, isKeypadVisible: false);

      when(() => cubit.state).thenReturn(validStateBeforeSuccess);
      when(() => cubit.stream).thenAnswer((_) => Stream.value(successState));
      when(() => cubit.onPhoneNumberChanged('')).thenAnswer((_) {
         when(() => cubit.state).thenReturn(initialBaseFormStateWithValidation.copyWith(isKeypadVisible: false));
      });

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('Phone Number Submitted!'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, ''), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsNothing);
      verify(() => cubit.onPhoneNumberChanged('')).called(1);
    });

    testWidgets('BlocListener: Failure state shows AlertDialog, hides keypad', (WidgetTester tester) async {
      final cubit = MockPhoneNumberCubit();
      final validStateBeforeFailure = const BaseFormState(fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '111', isValid: true)}, isFormValid: true, isKeypadVisible: true);
      final failureState = const BaseFormState(fields: {PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '111', isValid: true)}, isFailure: true, apiError: 'Network Error', isKeypadVisible: false);

      when(() => cubit.state).thenReturn(validStateBeforeFailure);
      when(() => cubit.stream).thenAnswer((_) => Stream.value(failureState));
      // No onPhoneNumberChanged("") call expected here as field isn't cleared on general failure.

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);
      expect(find.byType(CustomNumericKeypad), findsNothing);
    });
  });
}
