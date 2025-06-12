import 'package:bloc_test/bloc_test.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/login_phone/cubit/login_phone_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginPhoneCubit', () {
    late LoginPhoneCubit loginPhoneCubit;

    setUp(() {
      loginPhoneCubit = LoginPhoneCubit();
    });

    tearDown(() {
      loginPhoneCubit.close();
    });

    test('initial state is correct with pre-filled phone number', () {
      const initialPhoneNumber = '9000000000';
      // Helper to determine initial validation state based on cubit's logic
      String? initialError;
      if (initialPhoneNumber.isEmpty) {
        initialError = 'Phone number is required.';
      } else if (initialPhoneNumber.length > 10) {
        initialError = 'Phone number cannot exceed 10 digits.';
      } else if (!RegExp(r'^[0-9]+$').hasMatch(initialPhoneNumber)) {
        initialError = 'Phone number can only contain digits.';
      }
      final isInitialValid = initialError == null;

      expect(
        loginPhoneCubit.state,
        BaseFormState( // Use non-const because initialError can change
          fields: {
            LoginPhoneCubit.phoneKey: BaseFormFieldState(
              value: initialPhoneNumber,
              isValid: isInitialValid,
              error: initialError, // Should be null for '9000000000'
            ),
          },
          isFormValid: isInitialValid, // Should be true for '9000000000'
          isSubmitting: false,
          isSuccess: false,
          isFailure: false,
          apiError: null,
        ),
      );
    });

    group('Phone Number Validation', () {
      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits error when phone number is empty (after initially being valid)',
        setUp: () {
          // The cubit now starts with a valid number.
          // We don't need to do anything special here for this test,
          // as `act` will overwrite the initial state.
        },
        build: () => loginPhoneCubit,
        act: (cubit) => cubit.updateField(LoginPhoneCubit.phoneKey, ''),
        expect: () => [
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '',
                error: 'Phone number is required.',
                isValid: false,
              ),
            },
            isFormValid: false, // Form becomes invalid
            // other flags should remain default or explicitly set if they change
            isSubmitting: false,
            isSuccess: false,
            isFailure: false,
            apiError: null,
          ),
        ],
      );

      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits error when phone number is too long (> 10 digits)',
        build: () => loginPhoneCubit,
        act: (cubit) => cubit.updateField(LoginPhoneCubit.phoneKey, '12345678901'),
        expect: () => [
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '12345678901',
                error: 'Phone number cannot exceed 10 digits.',
                isValid: false,
              ),
            },
            isFormValid: false,
          ),
        ],
      );

      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits error when phone number contains non-numeric characters',
        build: () => loginPhoneCubit,
        act: (cubit) => cubit.updateField(LoginPhoneCubit.phoneKey, '123a567890'),
        expect: () => [
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '123a567890',
                error: 'Phone number can only contain digits.',
                isValid: false,
              ),
            },
            isFormValid: false,
          ),
        ],
      );

      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits no error and sets isValid to true for valid phone number (10 digits)',
        build: () => loginPhoneCubit,
        act: (cubit) => cubit.updateField(LoginPhoneCubit.phoneKey, '1234567890'),
        expect: () => [
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '1234567890',
                error: null,
                isValid: true,
              ),
            },
            isFormValid: true,
            isSubmitting: false,
            isSuccess: false,
            isFailure: false,
            apiError: null,
          ),
        ],
      );

      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits no error and sets isValid to true for valid phone number (< 10 digits, e.g. 5 digits)',
        build: () => loginPhoneCubit,
        act: (cubit) => cubit.updateField(LoginPhoneCubit.phoneKey, '12345'),
        expect: () => [
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '12345',
                error: null,
                isValid: true,
              ),
            },
            isFormValid: true,
            isSubmitting: false,
            isSuccess: false,
            isFailure: false,
            apiError: null,
          ),
        ],
      );
    });

    group('Form Submission', () {
      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits [submitting, success] when submit is called (cubit starts with valid data)',
        build: () {
          // Cubit constructor now pre-fills with a valid number '9000000000'
          // So, no need to call updateField here to make it valid.
          return loginPhoneCubit;
        },
        act: (cubit) => cubit.submit(),
        skip: 0, // Cubit's initial state is already valid.
        expect: () => [
          // State when submitting
          BaseFormState( // Non-const because initial value is dynamic from constructor for comparison
            fields: {
              LoginPhoneCubit.phoneKey: const BaseFormFieldState( // this field part is const
                value: '9000000000',
                isValid: true,
                error: null,
              ),
            },
            isFormValid: true,
            isSubmitting: true, // This is the first change expected
            isSuccess: false,
            isFailure: false,
            apiError: null,
          ),
          // State after successful submission
          BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '1234567890',
                isValid: true,
                error: null,
              ),
            },
            isFormValid: true,
            isSubmitting: true,
          ),
          // State after successful submission
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '1234567890',
                isValid: true,
                error: null,
              ),
            },
            isFormValid: true,
            isSubmitting: false,
            isSuccess: true,
          ),
        ],
      );

      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits [failure] when submit is called with invalid data',
        build: () {
          loginPhoneCubit.updateField(LoginPhoneCubit.phoneKey, '');
          return loginPhoneCubit;
        },
        act: (cubit) => cubit.submit(),
        expect: () => [
           // State after updateField with empty string
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '',
                isValid: false,
                error: 'Phone number is required.',
              ),
            },
            isFormValid: false,
          ),
          // State after submit attempt with invalid data
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '',
                isValid: false,
                error: 'Phone number is required.',
              ),
            },
            isFormValid: false, // Form is not valid
            isFailure: true,    // isFailure should be true
          ),
        ],
      );
    });
  });
}
