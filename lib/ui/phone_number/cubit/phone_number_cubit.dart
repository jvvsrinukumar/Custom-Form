import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_state.dart'; // For DontDisturb state

class PhoneNumberCubit extends BaseFormCubit {
  static const String phoneNumberKey = 'phoneNumber';

  PhoneNumberCubit() : super() {
    initializeFormFields({
      phoneNumberKey: const BaseFormFieldState(value: '', isValid: false),
    });
    // BaseFormState defaults isKeypadVisible to true.
  }

  @override
  Map<String, FieldValidator> get validators => {
        phoneNumberKey: (value, _) {
          final sVal = value as String?;
          if (sVal == null || sVal.isEmpty) {
            return 'Phone number cannot be empty.';
          }
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

  void onPhoneNumberChanged(String value) {
    updateField(phoneNumberKey, value);
    // If user starts typing, ensure keypad is visible.
    // This might be redundant if UI calls showKeypad on field tap,
    // but can be a safeguard.
    if (value.isNotEmpty && !state.isKeypadVisible) {
      showKeypad();
    }
  }

  // --- Re-added Keypad Methods ---
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

  void toggleKeypad() {
    emit(state.copyWith(isKeypadVisible: !state.isKeypadVisible));
  }
  // --- End Re-added Keypad Methods ---

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    final phoneNumber = values[phoneNumberKey] as String?;
    await Future.delayed(const Duration(seconds: 1)); // Simulate API

    if (phoneNumber == '1234567890') {
      emit(DontDisturb(
        name: "Test User DND",
        fields: state.fields,
        isSubmitting: false,
        isSuccess: true,
        isKeypadVisible: false, // Hide keypad on DND state
      ));
    } else if (phoneNumber == '0000000000') {
       emit(state.copyWith(
        isSubmitting: false,
        isFailure: true,
        apiError: "This phone number is blocked.",
        isKeypadVisible: false, // Hide keypad on failure
      ));
    }
    else {
      emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        isKeypadVisible: false, // Hide keypad on success
      ));
    }
  }
}
