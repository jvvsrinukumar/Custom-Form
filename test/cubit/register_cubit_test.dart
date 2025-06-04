import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:custom_form/core/data/drop_down_dm.dart'; // Added import
import 'package:custom_form/ui/register/cubit/register_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';

void main() {
  group('RegisterCubit', () {
    late RegisterCubit registerCubit;

    setUp(() {
      registerCubit = RegisterCubit();
    });

    tearDown(() {
      registerCubit.close();
    });

    test('initial state is correct', () {
      expect(registerCubit.state.fields[RegisterCubit.emailKey]?.value, '');
      expect(registerCubit.state.fields[RegisterCubit.passwordKey]?.value, '');
      expect(registerCubit.state.fields[RegisterCubit.confirmPasswordKey]?.value, '');
      expect(registerCubit.state.fields[RegisterCubit.firstNameKey]?.value, '');
      expect(registerCubit.state.fields[RegisterCubit.lastNameKey]?.value, '');
      expect(registerCubit.state.fields[RegisterCubit.termsKey]?.value, false);
      // Check category initial state
      expect(registerCubit.state.fields[RegisterCubit.categoryKey]?.value, isNull);
      expect(registerCubit.state.fields[RegisterCubit.categoryKey]?.isValid, isFalse);
      expect(registerCubit.state.fields[RegisterCubit.categoryKey]?.error, 'Category is required');
      expect(registerCubit.state.isFormValid, isFalse);
    });

    // Field Update Tests
    blocTest<RegisterCubit, BaseFormState>(
      'emits updated state for firstName field',
      build: () => RegisterCubit(),
      act: (cubit) => cubit.updateField(RegisterCubit.firstNameKey, 'John'),
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[RegisterCubit.firstNameKey]?.value, 'firstName value', 'John')
            .having((s) => s.fields[RegisterCubit.firstNameKey]?.isValid, 'firstName isValid', isTrue),
      ],
    );

    blocTest<RegisterCubit, BaseFormState>(
      'emits updated state for lastName field',
      build: () => RegisterCubit(),
      act: (cubit) => cubit.updateField(RegisterCubit.lastNameKey, 'Doe'),
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[RegisterCubit.lastNameKey]?.value, 'lastName value', 'Doe')
            .having((s) => s.fields[RegisterCubit.lastNameKey]?.isValid, 'lastName isValid', isTrue),
      ],
    );

    blocTest<RegisterCubit, BaseFormState>(
      'emits updated state for email field',
      build: () => RegisterCubit(),
      act: (cubit) => cubit.updateField(RegisterCubit.emailKey, 'test@example.com'),
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[RegisterCubit.emailKey]?.value, 'email value', 'test@example.com')
            .having((s) => s.fields[RegisterCubit.emailKey]?.isValid, 'email isValid', isTrue),
      ],
    );

    blocTest<RegisterCubit, BaseFormState>(
      'emits updated state for password field',
      build: () => RegisterCubit(),
      act: (cubit) => cubit.updateField(RegisterCubit.passwordKey, 'password123'),
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[RegisterCubit.passwordKey]?.value, 'password value', 'password123')
            .having((s) => s.fields[RegisterCubit.passwordKey]?.isValid, 'password isValid', isTrue),
      ],
    );

    blocTest<RegisterCubit, BaseFormState>(
      'emits updated state for confirmPassword field',
      build: () {
        final cubit = RegisterCubit();
        cubit.updateField(RegisterCubit.passwordKey, 'password123'); // Need password to be set for confirmPassword to be valid
        return cubit;
      },
      act: (cubit) => cubit.updateField(RegisterCubit.confirmPasswordKey, 'password123'),
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[RegisterCubit.confirmPasswordKey]?.value, 'confirmPassword value', 'password123')
            .having((s) => s.fields[RegisterCubit.confirmPasswordKey]?.isValid, 'confirmPassword isValid', isTrue),
      ],
    );

    blocTest<RegisterCubit, BaseFormState>(
      'emits updated state for terms field',
      build: () => RegisterCubit(),
      act: (cubit) => cubit.updateField(RegisterCubit.termsKey, true),
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[RegisterCubit.termsKey]?.value, 'terms value', true)
            .having((s) => s.fields[RegisterCubit.termsKey]?.isValid, 'terms isValid', isTrue),
      ],
    );

    blocTest<RegisterCubit, BaseFormState>(
      'emits updated state for category field when valid item is selected',
      build: () => RegisterCubit(),
      act: (cubit) => cubit.updateField(RegisterCubit.categoryKey, RegisterCubit.categoryItems.first),
      expect: () => [
        isA<BaseFormState>()
            .having((s) => s.fields[RegisterCubit.categoryKey]?.value, 'category value', RegisterCubit.categoryItems.first)
            .having((s) => s.fields[RegisterCubit.categoryKey]?.isValid, 'category isValid', isTrue)
            .having((s) => s.fields[RegisterCubit.categoryKey]?.error, 'category error', isNull),
      ],
    );

    // Validation Tests
    group('Validation', () {
      // First Name
      blocTest<RegisterCubit, BaseFormState>(
        'firstName is invalid if empty',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.firstNameKey, ''),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.firstNameKey]?.isValid, 'isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.firstNameKey]?.error, 'error', 'First name is required'),
        ],
      );

      // Last Name
      blocTest<RegisterCubit, BaseFormState>(
        'lastName is invalid if empty',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.lastNameKey, ''),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.lastNameKey]?.isValid, 'isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.lastNameKey]?.error, 'error', 'Last name is required'),
        ],
      );

      // Email
      blocTest<RegisterCubit, BaseFormState>(
        'email is invalid if empty',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.emailKey, ''),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.emailKey]?.isValid, 'isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.emailKey]?.error, 'error', 'Email is required'),
        ],
      );
      blocTest<RegisterCubit, BaseFormState>(
        'email is invalid if format is incorrect',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.emailKey, 'test'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.emailKey]?.isValid, 'isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.emailKey]?.error, 'error', 'Enter a valid email'),
        ],
      );

      // Password
      blocTest<RegisterCubit, BaseFormState>(
        'password is invalid if empty',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.passwordKey, ''),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.passwordKey]?.isValid, 'isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.passwordKey]?.error, 'error', 'Password is required'),
        ],
      );
      blocTest<RegisterCubit, BaseFormState>(
        'password is invalid if too short',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.passwordKey, '123'),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.passwordKey]?.isValid, 'isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.passwordKey]?.error, 'error', 'Password must be at least 6 characters'),
        ],
      );

      // Confirm Password
      blocTest<RegisterCubit, BaseFormState>(
        'confirmPassword is invalid if empty',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.confirmPasswordKey, ''),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.confirmPasswordKey]?.isValid, 'isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.confirmPasswordKey]?.error, 'error', 'Confirm password is required'),
        ],
      );
      blocTest<RegisterCubit, BaseFormState>(
        'confirmPassword is invalid if not matching password',
        build: () {
          final cubit = RegisterCubit();
          cubit.updateField(RegisterCubit.passwordKey, 'password123');
          return cubit;
        },
        act: (cubit) => cubit.updateField(RegisterCubit.confirmPasswordKey, 'mismatch'),
        // It might emit twice: once for value change, once for error from password re-evaluation.
        // We care about the final state.
        verify: (cubit) {
          final state = cubit.state.fields[RegisterCubit.confirmPasswordKey];
          expect(state?.isValid, isFalse);
          expect(state?.error, 'Passwords do not match');
        }
      );

      blocTest<RegisterCubit, BaseFormState>(
        'updates confirmPassword validation when password changes and confirmPassword was valid',
        build: () {
          final cubit = RegisterCubit();
          cubit.updateField(RegisterCubit.passwordKey, 'password123');
          cubit.updateField(RegisterCubit.confirmPasswordKey, 'password123'); // initially matching
          return cubit;
        },
        act: (cubit) async {
          cubit.updateField(RegisterCubit.passwordKey, 'newpassword'); // Change password
        },
        verify: (cubit) {
           expect(cubit.state.fields[RegisterCubit.confirmPasswordKey]?.isValid, isFalse);
           expect(cubit.state.fields[RegisterCubit.confirmPasswordKey]?.error, 'Passwords do not match');
        }
      );

      blocTest<RegisterCubit, BaseFormState>(
        'confirmPassword becomes valid when password changes to match it',
        build: () {
          final cubit = RegisterCubit();
          cubit.updateField(RegisterCubit.passwordKey, 'oldpassword');
          cubit.updateField(RegisterCubit.confirmPasswordKey, 'password123'); // initially mismatching
          return cubit;
        },
        act: (cubit) async {
          cubit.updateField(RegisterCubit.passwordKey, 'password123'); // Change password to match
        },
        verify: (cubit) {
           expect(cubit.state.fields[RegisterCubit.confirmPasswordKey]?.isValid, isTrue);
           expect(cubit.state.fields[RegisterCubit.confirmPasswordKey]?.error, isNull);
        }
      );

      // Terms
      blocTest<RegisterCubit, BaseFormState>(
        'terms are invalid if false',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.termsKey, false),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.termsKey]?.isValid, 'isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.termsKey]?.error, 'error', 'You must accept the terms and conditions'),
        ],
      );

      // Category Validation
      blocTest<RegisterCubit, BaseFormState>(
        'category is invalid if null (simulating not selected)',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.categoryKey, null),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.categoryKey]?.value, 'category value', isNull)
              .having((s) => s.fields[RegisterCubit.categoryKey]?.isValid, 'category isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.categoryKey]?.error, 'category error', 'Category is required'),
        ],
      );
       blocTest<RegisterCubit, BaseFormState>(
        'category becomes valid when an item is selected',
        build: () => RegisterCubit(),
        act: (cubit) => cubit.updateField(RegisterCubit.categoryKey, RegisterCubit.categoryItems.first),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.fields[RegisterCubit.categoryKey]?.value, 'category value', RegisterCubit.categoryItems.first)
              .having((s) => s.fields[RegisterCubit.categoryKey]?.isValid, 'category isValid', isTrue)
              .having((s) => s.fields[RegisterCubit.categoryKey]?.error, 'category error', null),
        ],
      );
    });

    // Form Submission Tests
    group('Form Submission', () {
      RegisterCubit _buildValidCubit() {
        final cubit = RegisterCubit();
        cubit.updateField(RegisterCubit.firstNameKey, 'John');
        cubit.updateField(RegisterCubit.lastNameKey, 'Doe');
        cubit.updateField(RegisterCubit.emailKey, 'john.doe@example.com');
        cubit.updateField(RegisterCubit.passwordKey, 'password123');
        cubit.updateField(RegisterCubit.confirmPasswordKey, 'password123');
        cubit.updateField(RegisterCubit.termsKey, true);
        cubit.updateField(RegisterCubit.categoryKey, RegisterCubit.categoryItems.first); // Added category
        return cubit;
      }

      blocTest<RegisterCubit, BaseFormState>(
        'emits [submitting, success] when form is valid and submission succeeds',
        build: _buildValidCubit,
        act: (cubit) => cubit.submit(),
        expect: () => [
          isA<BaseFormState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<BaseFormState>()
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.isSuccess, 'isSuccess', true)
              .having((s) => s.isFailure, 'isFailure', false)
              .having((s) => s.apiError, 'apiError', null),
        ],
      );

      blocTest<RegisterCubit, BaseFormState>(
        'emits [submitting, failure with apiError] for "error@example.com"',
        build: () {
          final cubit = _buildValidCubit(); // _buildValidCubit now sets category
          cubit.updateField(RegisterCubit.emailKey, 'error@example.com');
          return cubit;
        },
        act: (cubit) => cubit.submit(),
        expect: () => [
          isA<BaseFormState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<BaseFormState>()
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.isFailure, 'isFailure', true)
              .having((s) => s.isSuccess, 'isSuccess', false)
              .having((s) => s.apiError, 'apiError', "This email is already registered. Please try another."),
        ],
      );

      blocTest<RegisterCubit, BaseFormState>(
        'emits [submitting, failure with apiError] for "networkerror@example.com"',
        build: () {
          final cubit = _buildValidCubit(); // _buildValidCubit now sets category
          cubit.updateField(RegisterCubit.emailKey, 'networkerror@example.com');
          return cubit;
        },
        act: (cubit) => cubit.submit(),
        expect: () => [
          isA<BaseFormState>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<BaseFormState>()
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.isFailure, 'isFailure', true)
              .having((s) => s.isSuccess, 'isSuccess', false)
              .having((s) => s.apiError, 'apiError', "A network error occurred. Please try again later."),
        ],
      );

      blocTest<RegisterCubit, BaseFormState>(
        'emits [failure] with field errors when form is invalid and submit is called',
        build: () => RegisterCubit(), // Start with an empty, invalid form
        act: (cubit) => cubit.submit(),
        expect: () => [
          isA<BaseFormState>()
              .having((s) => s.isFailure, 'isFailure', true)
              .having((s) => s.isSubmitting, 'isSubmitting', false) // Should not be submitting
              .having((s) => s.fields[RegisterCubit.emailKey]?.isValid, 'email isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.emailKey]?.error, 'email error', 'Email is required')
              .having((s) => s.fields[RegisterCubit.firstNameKey]?.error, 'firstName error', 'First name is required')
              .having((s) => s.fields[RegisterCubit.categoryKey]?.isValid, 'category isValid', isFalse)
              .having((s) => s.fields[RegisterCubit.categoryKey]?.error, 'category error', 'Category is required'),
        ],
         verify: (cubit) {
          // Ensure isFormValid is false and specific errors are present
          expect(cubit.state.isFormValid, isFalse);
          expect(cubit.state.fields[RegisterCubit.passwordKey]?.error, 'Password is required');
          expect(cubit.state.fields[RegisterCubit.termsKey]?.error, 'You must accept the terms and conditions');
          expect(cubit.state.fields[RegisterCubit.categoryKey]?.error, 'Category is required');
        }
      );
    });
  });
}
