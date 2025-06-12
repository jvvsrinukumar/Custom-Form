import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
// flutter/services.dart import can be removed if not used elsewhere in this file after changes.
// For now, keeping it doesn't harm, but it's not strictly needed for this version of the cubit.

class LoginPhoneCubit extends BaseFormCubit {
  static const String phoneKey = 'phone';

  LoginPhoneCubit() {
    // Initialize with an empty phone field.
    // The BaseFormCubit's default constructor creates a state with isFormValid: false.
    // initializeFormFields then emits a new state with the specified fields.
    // If a field is marked isValid: false, and it's the only field, isFormValid should resolve to false.
    initializeFormFields({
      phoneKey: const BaseFormFieldState(value: '', isValid: false, error: null),
    });
  }

  @override
  Map<String, FieldValidator> get validators => {
        phoneKey: (value, _) {
          // Ensure value is treated as a string for validation logic.
          final val = value?.toString() ?? '';
          if (val.isEmpty) {
            return 'Phone number is required.';
          }
          if (val.length > 10) {
            return 'Phone number cannot exceed 10 digits.';
          }
          // Regex for numeric check
          if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
            return 'Phone number can only contain digits.';
          }
          return null; // Return null if valid
        },
      };

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Assuming submission is successful if it passes client-side validation for this example
    emit(state.copyWith(isSuccess: true, isSubmitting: false));
  }
}
