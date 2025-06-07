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

    // Example of success
    emit(state.copyWith(isSubmitting: false, isSuccess: true));

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
