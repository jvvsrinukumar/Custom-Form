import 'package:bloc_test/bloc_test.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneNumberCubit', () {
    late PhoneNumberCubit phoneNumberCubit;

    setUp(() {
      phoneNumberCubit = PhoneNumberCubit();
    });

    tearDown(() {
      phoneNumberCubit.close();
    });

    test('initial state is correct', () {
      expect(
        phoneNumberCubit.state,
        const BaseFormState(
          fields: {
            PhoneNumberCubit.phoneNumberKey: BaseFormFieldState(value: '', initialValue: ''),
          },
          isFormValid: false, // Initially false due to empty phone number
          isKeypadVisible: true, // Add this
        ),
      );
    });

    group('Phone Number Validation', () {
      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits error when phone number is empty',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.updateField(PhoneNumberCubit.phoneNumberKey, ''),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Phone number is required')
              .having((s) => s.isFormValid, 'isFormValid', false)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits error when phone number is too short',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.updateField(PhoneNumberCubit.phoneNumberKey, '12345'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '12345')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Enter a valid 10-digit phone number')
              .having((s) => s.isFormValid, 'isFormValid', false)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits error when phone number contains non-digits',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.updateField(PhoneNumberCubit.phoneNumberKey, '123456789a'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '123456789a')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Enter a valid 10-digit phone number')
              .having((s) => s.isFormValid, 'isFormValid', false)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits error when phone number is too long',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.updateField(PhoneNumberCubit.phoneNumberKey, '12345678901'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '12345678901')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Enter a valid 10-digit phone number')
              .having((s) => s.isFormValid, 'isFormValid', false)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits no error and sets isFormValid to true for a valid phone number',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.updateField(PhoneNumberCubit.phoneNumberKey, '1234567890'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '1234567890')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', null)
              .having((s) => s.isFormValid, 'isFormValid', true)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
        ],
      );
    });

    group('Form Submission', () {
      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits [isSubmitting: true, isSuccess: true] when submit is called with valid data',
        build: () {
          // Pre-fill with valid data
          final cubit = PhoneNumberCubit();
          cubit.updateField(PhoneNumberCubit.phoneNumberKey, '1234567890');
          return cubit;
        },
        act: (cubit) => cubit.submit(),
        // Expect multiple states: first with updated errors (none here), then submitting, then success.
        expect: () => [
          isA<BaseFormState>() // Validation pass before submission
              .having((s) => s.isSubmitting, 'isSubmitting before', false)
              .having((s) => s.isFormValid, 'isFormValid before', true)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible before', true),
          isA<BaseFormState>() // isSubmitting = true
              .having((s) => s.isSubmitting, 'isSubmitting during', true)
              .having((s) => s.isSuccess, 'isSuccess during', false)
              .having((s) => s.isFailure, 'isFailure during', false)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible during', true),
          isA<BaseFormState>() // isSuccess = true
              .having((s) => s.isSubmitting, 'isSubmitting after', false)
              .having((s) => s.isSuccess, 'isSuccess after', true)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible after', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits [isFailure: true] when submit is called with invalid data',
        build: () => phoneNumberCubit, // Starts with empty (invalid) phone number
        act: (cubit) => cubit.submit(),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Phone number is required')
              .having((s) => s.isFailure, 'isFailure', true)
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
        ],
      );
    });

    group('Keypad Visibility', () {
      blocTest<PhoneNumberCubit, BaseFormState>(
        'showKeypad emits isKeypadVisible: true when it was false',
        build: () {
          final cubit = PhoneNumberCubit();
          // Manually emit a state where keypad is false to test transition
          cubit.emit(cubit.state.copyWith(isKeypadVisible: false));
          return cubit;
        },
        act: (cubit) => cubit.showKeypad(),
        expect: () => [
          isA<BaseFormState>().having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'showKeypad does not emit new state if isKeypadVisible is already true',
        build: () => phoneNumberCubit, // Initial state has isKeypadVisible = true
        act: (cubit) => cubit.showKeypad(),
        expect: () => [], // No new state emitted
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'hideKeypad emits isKeypadVisible: false when it was true',
        build: () => phoneNumberCubit, // Initial state has isKeypadVisible = true
        act: (cubit) => cubit.hideKeypad(),
        expect: () => [
          isA<BaseFormState>().having((s) => s.isKeypadVisible, 'isKeypadVisible', false),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'hideKeypad does not emit new state if isKeypadVisible is already false',
        build: () {
          final cubit = PhoneNumberCubit();
          cubit.emit(cubit.state.copyWith(isKeypadVisible: false));
          return cubit;
        },
        act: (cubit) => cubit.hideKeypad(),
        expect: () => [], // No new state emitted
      );
    });

  group('Digit Manipulation', () {
    const String phoneNumberKey = PhoneNumberCubit.phoneNumberKey;

    blocTest<PhoneNumberCubit, BaseFormState>(
      'appendDigit adds a digit to the phone number',
      build: () => PhoneNumberCubit(),
      act: (cubit) {
        cubit.appendDigit('1');
        cubit.appendDigit('2');
      },
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[phoneNumberKey]?.value, 'value', '1')
            .having((s) => s.isKeypadVisible, 'isKeypadVisible', true), // Ensure other state aspects are covered
        isA<BaseFormState>()
            .having((s) => s.fields[phoneNumberKey]?.value, 'value', '12')
            .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
      ],
    );

    blocTest<PhoneNumberCubit, BaseFormState>(
      'appendDigit does not add digit if max length (10) is reached',
      build: () {
        final cubit = PhoneNumberCubit();
        // Pre-fill to max length
        cubit.emit(cubit.state.copyWith(
          fields: {
            phoneNumberKey: const BaseFormFieldState(value: '1234567890', initialValue: '1234567890'),
          },
          isFormValid: true, // Assuming '1234567890' is valid
        ));
        return cubit;
      },
      act: (cubit) => cubit.appendDigit('1'), // Try to add 11th digit
      expect: () => [], // No state change as max length reached
    );

    blocTest<PhoneNumberCubit, BaseFormState>(
      'appendDigit still allows up to 10 digits',
      build: () {
        final cubit = PhoneNumberCubit();
        // Pre-fill to 9 digits
        cubit.emit(cubit.state.copyWith(
          fields: {
            phoneNumberKey: const BaseFormFieldState(value: '123456789', initialValue: '123456789'),
          },
        ));
        return cubit;
      },
      act: (cubit) => cubit.appendDigit('0'), // Add 10th digit
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[phoneNumberKey]?.value, 'value', '1234567890')
            .having((s) => s.isFormValid, 'isFormValid', true) // Should become valid
            .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
      ],
    );

    blocTest<PhoneNumberCubit, BaseFormState>(
      'deleteDigit removes the last digit',
      build: () {
        final cubit = PhoneNumberCubit();
        cubit.emit(cubit.state.copyWith(
          fields: {
            phoneNumberKey: const BaseFormFieldState(value: '123', initialValue: '123'),
          },
        ));
        return cubit;
      },
      act: (cubit) => cubit.deleteDigit(),
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[phoneNumberKey]?.value, 'value', '12')
            .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
      ],
    );

    blocTest<PhoneNumberCubit, BaseFormState>(
      'deleteDigit does nothing if phone number is empty',
      build: () => PhoneNumberCubit(), // Initial state has empty phone number
      act: (cubit) => cubit.deleteDigit(),
      expect: () => [], // No state change
    );

    blocTest<PhoneNumberCubit, BaseFormState>(
      'deleteDigit updates validation (e.g., from valid to invalid)',
      build: () {
        final cubit = PhoneNumberCubit();
        // Pre-fill with a valid 10-digit number
        cubit.emit(cubit.state.copyWith(
          fields: {
            phoneNumberKey: const BaseFormFieldState(value: '1234567890', initialValue: '1234567890'),
          },
          isFormValid: true, // Explicitly set as valid for test setup
        ));
        return cubit;
      },
      act: (cubit) => cubit.deleteDigit(), // Delete one digit, making it 9 digits (invalid by current rules)
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[phoneNumberKey]?.value, 'value', '123456789')
            .having((s) => s.fields[phoneNumberKey]?.error, 'error', 'Enter a valid 10-digit phone number')
            .having((s) => s.isFormValid, 'isFormValid', false)
            .having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
      ],
    );
  });
  // Removed Digit Manipulation group as appendDigit/deleteDigit were removed from cubit
  // });
}
