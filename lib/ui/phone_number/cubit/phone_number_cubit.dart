import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_state.dart'; // For DontDisturb state

class PhoneNumberCubit extends BaseFormCubit {
  static const String phoneNumberKey = 'phoneNumber';

  PhoneNumberCubit() : super() {
    // Initialize form fields specific to this cubit
    initializeFormFields({
      phoneNumberKey: const BaseFormFieldState(value: '', isValid: false),
    });
  }

  @override
  Map<String, FieldValidator> get validators => {
        phoneNumberKey: (value, _) {
          final sVal = value as String?;
          if (sVal == null || sVal.isEmpty) {
            return 'Phone number cannot be empty.';
          }
          // Regex for 10 to 15 digits, allowing for international numbers without specific country codes yet
          // For more specific validation like 10-digits only: r'^[0-9]{10}$'
          if (!RegExp(r'^[0-9]{10,15}$').hasMatch(sVal)) {
            if (sVal.length < 10) {
              return 'Phone number must be at least 10 digits.';
            }
            if (sVal.length > 15) {
              return 'Phone number is too long (max 15 digits).';
            }
            return 'Invalid characters or format in phone number.';
          }
          return null; // No error
        },
      };

  // Method to be called by UI when text field changes for phone number
  void onPhoneNumberChanged(String value) {
    updateField(phoneNumberKey, value);
  }

  // Controls keypad visibility - example methods
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

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // This method is called by BaseFormCubit's submit() after validation
    // state.isSubmitting is already true here.

    final phoneNumber = values[phoneNumberKey] as String?;

    // Simulate API call or specific logic
    await Future.delayed(const Duration(seconds: 1));

    if (phoneNumber == '1234567890') { // Example: specific number for DND check
      // When emitting a custom state, ensure all BaseFormState fields are appropriately set.
      emit(DontDisturb(
        name: "Test User DND", // Example name
        fields: state.fields, // Preserve current field states
        isSubmitting: false, // Explicitly set isSubmitting to false
        isSuccess: true, // DND is a form of success
        isKeypadVisible: state.isKeypadVisible, // Preserve keypad state or set as needed
        // apiError and isFailure should be default or explicitly set if needed
      ));
    } else if (phoneNumber == '0000000000') { // Example: specific number for failure
       emit(state.copyWith(
        isSubmitting: false,
        isFailure: true,
        apiError: "This phone number is blocked.",
      ));
    }
    else {
      // Generic success
      emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      ));
    }
  }
}
