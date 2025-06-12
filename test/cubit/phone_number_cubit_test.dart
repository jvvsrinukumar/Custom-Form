import 'package:bloc_test/bloc_test.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_state.dart'; // For DontDisturb
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneNumberCubit', () {
    late PhoneNumberCubit phoneNumberCubit;

    setUp(() {
      phoneNumberCubit = PhoneNumberCubit();
    });

    test('initial state is BaseFormState with phoneNumber field initialized', () {
      expect(phoneNumberCubit.state, isA<BaseFormState>());
      // From BaseFormCubit constructor, fields are initialized.
      // Then PhoneNumberCubit constructor calls initializeFormFields.
      // The default BaseFormFieldState from initializeFormFields will have value: '', isValid: false (due to validator)
      final initialFieldState = phoneNumberCubit.state.fields[PhoneNumberCubit.phoneNumberKey];
      expect(initialFieldState?.value, '');
      // The validator for empty string returns "Phone number cannot be empty."
      // So isValid should be false, and error should be present after initialization if validators run on init.
      // BaseFormCubit runs validateAllFields which runs validators after initializeFormFields.
      expect(initialFieldState?.isValid, false);
      expect(initialFieldState?.error, 'Phone number cannot be empty.');
      expect(phoneNumberCubit.state.isFormValid, false); // Form is not valid due to the error
      expect(phoneNumberCubit.state.isKeypadVisible, true); // Default from BaseFormState or Cubit's choice
    });

    group('onPhoneNumberChanged (via updateField)', () {
      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits state with updated phone number and no error for valid input',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.onPhoneNumberChanged('1234567890'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '1234567890')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', isNull)
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.isValid, 'isValid', true)
              .having((s) => s.isFormValid, 'isFormValid', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits state with error for empty phone number',
        build: () => phoneNumberCubit,
        // Need to set a non-empty value first so change to empty is detected and validator runs
        seed: () => phoneNumberCubit.state.copyWith(
          fields: {
            PhoneNumberCubit.phoneNumberKey: const BaseFormFieldState(value: '123', error: null, isValid: false)
          },
          isFormValid: false
        ),
        act: (cubit) => cubit.onPhoneNumberChanged(''),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Phone number cannot be empty.')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.isValid, 'isValid', false)
              .having((s) => s.isFormValid, 'isFormValid', false),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits state with error for short phone number',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.onPhoneNumberChanged('123'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '123')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Phone number must be at least 10 digits.')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.isValid, 'isValid', false)
              .having((s) => s.isFormValid, 'isFormValid', false),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits state with error for phone number with invalid characters (non-digit)',
        // The validator used is r'^[0-9]{10,15}$'
        // "Invalid characters or format in phone number."
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.onPhoneNumberChanged('123456789x'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '123456789x')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Invalid characters or format in phone number.')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.isValid, 'isValid', false)
              .having((s) => s.isFormValid, 'isFormValid', false),
        ],
      );

       blocTest<PhoneNumberCubit, BaseFormState>(
        'emits state with error for phone number too long',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.onPhoneNumberChanged('1234567890123456'), // 16 digits
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '1234567890123456')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Phone number is too long (max 15 digits).')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.isValid, 'isValid', false)
              .having((s) => s.isFormValid, 'isFormValid', false),
        ],
      );
    });

    group('submit (calling submitForm)', () {
      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits submitting then DontDisturb state for DND number',
        build: () => phoneNumberCubit,
        act: (cubit) async {
          cubit.onPhoneNumberChanged('1234567890');
          // await Future.delayed(Duration.zero); // blocTest handles async act
          await cubit.submit();
        },
        expect: () => [
          // State after onPhoneNumberChanged
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '1234567890')
              .having((s) => s.isFormValid, 'isFormValid', true),
          // State when BaseFormCubit.submit() sets isSubmitting = true (before calling submitForm)
          isA<BaseFormState>()
              .having((s) => s.isSubmitting, 'isSubmitting', true)
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.isValid, 'isValid', true),
          // Final DontDisturb state from submitForm
          isA<DontDisturb>()
              .having((s) => s.name, 'name', 'Test User DND')
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.isSuccess, 'isSuccess', true)
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '1234567890'),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits submitting then success for valid non-DND number',
        build: () => phoneNumberCubit,
        act: (cubit) async {
          cubit.onPhoneNumberChanged('0987654321');
          await cubit.submit();
        },
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '0987654321')
              .having((s) => s.isFormValid, 'isFormValid', true),
          isA<BaseFormState>()
              .having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<BaseFormState>()
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.isSuccess, 'isSuccess', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits submitting then failure for specific blocked number',
        build: () => phoneNumberCubit,
        act: (cubit) async {
          cubit.onPhoneNumberChanged('0000000000');
          await cubit.submit();
        },
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '0000000000')
              .having((s) => s.isFormValid, 'isFormValid', true),
          isA<BaseFormState>()
              .having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<BaseFormState>()
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.isFailure, 'isFailure', true)
              .having((s) => s.apiError, 'apiError', "This phone number is blocked."),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'emits validation failure and does not call submitForm if form is invalid',
        build: () => phoneNumberCubit,
        act: (cubit) async {
          cubit.onPhoneNumberChanged('123');
          await cubit.submit();
        },
        expect: () => [
           isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.value, 'value', '123')
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Phone number must be at least 10 digits.')
              .having((s) => s.isFormValid, 'isFormValid', false),
          isA<BaseFormState>()
              .having((s) => s.fields[PhoneNumberCubit.phoneNumberKey]?.error, 'error', 'Phone number must be at least 10 digits.')
              .having((s) => s.isFailure, 'isFailure', true)
              .having((s) => s.isSubmitting, 'isSubmitting', false),
        ],
      );
    });

    group('Keypad Visibility', () {
      blocTest<PhoneNumberCubit, BaseFormState>(
        'showKeypad sets isKeypadVisible to true',
        build: () {
          phoneNumberCubit.emit(phoneNumberCubit.state.copyWith(isKeypadVisible: false));
          return phoneNumberCubit;
        },
        act: (cubit) => cubit.showKeypad(),
        expect: () => [
          isA<BaseFormState>().having((s) => s.isKeypadVisible, 'isKeypadVisible', true),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'hideKeypad sets isKeypadVisible to false',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.hideKeypad(),
        expect: () => [
          isA<BaseFormState>().having((s) => s.isKeypadVisible, 'isKeypadVisible', false),
        ],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'showKeypad does not emit if already visible',
        build: () => phoneNumberCubit,
        act: (cubit) => cubit.showKeypad(),
        expect: () => [],
      );

      blocTest<PhoneNumberCubit, BaseFormState>(
        'hideKeypad does not emit if already hidden',
        build: () {
           phoneNumberCubit.emit(phoneNumberCubit.state.copyWith(isKeypadVisible: false));
           return phoneNumberCubit;
        },
        act: (cubit) => cubit.hideKeypad(),
        expect: () => [],
      );
    });
  });
}
