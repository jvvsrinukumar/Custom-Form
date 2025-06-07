import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';

typedef FieldValidator = String? Function(
    dynamic value, Map<String, dynamic> allValues);

class PhoneNumberCubit extends BaseFormCubit {
  static const String phoneNumberKey = 'phoneNumber';

  final Map<String, FieldValidator> _fieldValidators = {
    phoneNumberKey: (value, _) {
      if (value == null || value.toString().isEmpty)
        return "Phone number is required";
      final phoneRegex = RegExp(r'^[0-9]{10}$');
      if (!phoneRegex.hasMatch(value.toString()))
        return "Enter a valid 10-digit phone number";
      return null;
    },
  };

  PhoneNumberCubit() : super() {
    initializeFormFields({
      phoneNumberKey:
          const BaseFormFieldState(value: '', initialValue: '', isValid: false),
    });
    // Keypad visible initially if you want:
    emit(state.copyWith(isKeypadVisible: true));
  }

  @override
  Map<String, FieldValidator> get validators => _fieldValidators;

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    emit(state.copyWith(isSubmitting: true));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(isSubmitting: false, isSuccess: true));
    hideKeypad();
  }

  void onPhoneNumberChangedByUI(String newPhoneNumber) {
    updateField(phoneNumberKey, newPhoneNumber);
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
}
