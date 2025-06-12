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

    test('initial state is correct (empty phone, form invalid)', () {
      expect(
        loginPhoneCubit.state,
        const BaseFormState(
          fields: {
            LoginPhoneCubit.phoneKey: BaseFormFieldState(value: '', isValid: false, error: null),
          },
          isFormValid: false, // Because the phoneKey field is isValid: false by default in initializeFormFields
          isSubmitting: false,
          isSuccess: false,
          isFailure: false,
          apiError: null,
        ),
      );
    });

    group('Phone Number Validation', () {
      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits error when phone number is empty (re-validating empty field)',
        build: () => loginPhoneCubit,
        act: (cubit) => cubit.updateField(LoginPhoneCubit.phoneKey, ''), // "Update" to empty, triggers validation
        expect: () => [
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '',
                error: 'Phone number is required.', // Validator provides the error
                isValid: false,
              ),
            },
            isFormValid: false,
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
            isFormValid: true, // Form becomes valid due to this field
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
        'emits [valid, submitting, success] when submit is called with valid data',
        build: () => loginPhoneCubit, // Starts invalid
        act: (cubit) async {
          cubit.updateField(LoginPhoneCubit.phoneKey, '1234567890'); // Make it valid
          // await Future.delayed(Duration.zero); // Ensure updateField state is processed if needed by blocTest
          cubit.submit();
        },
        expect: () => [
          // 1. After updateField makes it valid
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
            isSuccess: false,
            isFailure: false,
            apiError: null,
          ),
          // 2. When submitting (isSubmitting true)
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '1234567890',
                isValid: true,
                error: null,
              ),
            },
            isFormValid: true,
            isSubmitting: true,
            isSuccess: false,
            isFailure: false,
            apiError: null,
          ),
          // 3. After successful submission
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
            isFailure: false,
            apiError: null,
          ),
        ],
      );

      blocTest<LoginPhoneCubit, BaseFormState>(
        'emits [failure with error] when submit is called with invalid data (initial empty state)',
        build: () => loginPhoneCubit, // Starts invalid (empty phone)
        act: (cubit) => cubit.submit(),
        expect: () => [
          const BaseFormState(
            fields: {
              LoginPhoneCubit.phoneKey: BaseFormFieldState(
                value: '', // Remains empty
                isValid: false,
                error: 'Phone number is required.', // Error set by submit validation
              ),
            },
            isFormValid: false,
            isSubmitting: false,
            isSuccess: false,
            isFailure: true, // isFailure is true
          ),
        ],
      );
    });
  });
}
