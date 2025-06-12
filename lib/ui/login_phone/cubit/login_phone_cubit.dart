import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter

class LoginPhoneCubit extends BaseFormCubit {
  static const String phoneKey = 'phone';

  LoginPhoneCubit() {
    initializeFormFields({
      phoneKey: const BaseFormFieldState(value: '', isValid: false),
    });
  }

  @override
  Map<String, FieldValidator> get validators => {
        phoneKey: (value, _) {
          if (value == null || value.toString().isEmpty) {
            return 'Phone number is required.';
          }
          if (value.toString().length > 10) {
            return 'Phone number cannot exceed 10 digits.';
          }
          if (!RegExp(r'^[0-9]+$').hasMatch(value.toString())) {
            return 'Phone number can only contain digits.';
          }
          return null;
        },
      };

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success/failure based on some condition if needed
    // For now, let's assume success
    emit(state.copyWith(isSuccess: true, isSubmitting: false));

    // Example of failure:
    // emit(state.copyWith(isFailure: true, apiError: "Invalid phone number", isSubmitting: false));
  }

  // It's good practice to also provide the input formatters if the cubit is responsible for validation logic
  // However, AppTextField doesn't directly support passing InputFormatters through this BaseFormCubit structure easily.
  // For now, the validation will catch issues, but direct input restriction would be a UI concern.
  // We will add the input formatter directly in the AppTextField in the page file later.
}
