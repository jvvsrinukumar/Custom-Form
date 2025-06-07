import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';

class PhoneNumberCubit extends BaseFormCubit {
  static const String phoneNumberKey = 'phoneNumber';

  final Map<String, FieldValidator> _fieldValidators = {
    phoneNumberKey: (value, _) {
      if (value == null || value.toString().isEmpty) {
        return "Phone number is required";
      }
      final phoneRegex = RegExp(r'^[0-9]{10}$'); // Example: 10 digit number
      if (!phoneRegex.hasMatch(value.toString())) {
        return "Enter a valid 10-digit phone number";
      }
      return null;
    },
  };

  PhoneNumberCubit() : super() {
    initializeFormFields({
      phoneNumberKey: const BaseFormFieldState(value: '', initialValue: ''),
    });
  }

  @override
  Map<String, FieldValidator> get validators => _fieldValidators;

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // Simulate API call or processing
    print("Submitting phone number: \${values[phoneNumberKey]}");
    await Future.delayed(const Duration(seconds: 1));

    // Get the current state of the phone number field, or create a default if somehow missing
    final currentPhoneNumberFieldState = state.fields[phoneNumberKey] ?? const BaseFormFieldState(value: ''); // Added default value for BaseFormFieldState

    // Ensure the value from the 'values' map (which was validated) is used.
    // Also, explicitly mark it as valid and clear any prior error from the submission validation pass,
    // as this is a successful submission.
    final successPhoneNumberFieldState = currentPhoneNumberFieldState.copyWith(
      value: values[phoneNumberKey], // Use the submitted value
      error: null, // Clear any error
      isValid: true, // Mark as valid because submission was successful
      clearError: true, // Explicitly clear error
    );

    // Create an updated fields map
    final updatedFields = Map<String, BaseFormFieldState>.from(state.fields);
    updatedFields[phoneNumberKey] = successPhoneNumberFieldState;

    emit(state.copyWith(
      fields: updatedFields, // Pass the explicitly updated fields
      isSubmitting: false,
      isSuccess: true,
    ));

    // Example of failure:
    // emit(state.copyWith(isSubmitting: false, isFailure: true, apiError: "Failed to submit phone number."));
  }

  void showKeypad() {
    if (!state.isKeypadVisible) {
      emit(state.copyWith(isKeypadVisible: true));
    }
  }

  void hideKeypad() {
    if (state.isKeypadVisible) {
      emit(state.copyWith(isKeypadVisible: false));
    }
  }

  void onPhoneNumberChangedByUI(String newPhoneNumber) {
    updateField(phoneNumberKey, newPhoneNumber);
  }
}
