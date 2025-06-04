import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart'; // Required for BaseFormFieldState

class LoginCubit extends BaseFormCubit {
  static const String emailKey = 'email';
  static const String passwordKey = 'password';
  static const String checkoutKey = 'checkout';

  // Store validators map for the getter
  final Map<String, FieldValidator> _fieldValidators = {
    emailKey: (value, _) {
      if (value == null || value.isEmpty) return "Email required";
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value.toString())) return "Enter valid email"; // Ensure value is string for regex
      return null;
    },
    passwordKey: (value, _) {
      if (value == null || value.toString().isEmpty) return "Password required"; // Ensure value is string for length check
      if (value.toString().length < 6) return "Min 6 characters";
      return null;
    },
    checkoutKey: (value, _) {
      if (value != true) return "Must accept terms";
      return null;
    },
  };

  LoginCubit() : super() { // Call no-arg constructor
    // Initialize fields
    initializeFormFields({
      emailKey: const BaseFormFieldState(value: '', initialValue: ''),
      passwordKey: const BaseFormFieldState(value: '', initialValue: ''),
      checkoutKey: const BaseFormFieldState(value: false, initialValue: false),
    });
  }

  @override
  Map<String, FieldValidator> get validators => _fieldValidators;

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // Current submitForm implementation seems compatible.
    // It already uses the 'values' map passed to it.
    // No changes needed here unless BaseFormCubit's submit() flow has further implications.

    // Simulate API call - this part is fine
    // BaseFormCubit's submit() method already sets isSubmitting to true.
    // emit(state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false, apiError: null)); // Ensure apiError is cleared
    // Clearing apiError and setting isFailure/isSuccess to false is good practice before a new attempt.
    // This might already be handled by BaseFormCubit's submit method when it starts.
    // If not, it's good to have:
    if (state.isFailure || state.apiError != null) {
       emit(state.copyWith(isFailure: false, apiError: null, isSuccess: false));
    }
    // isSubmitting is already true from base class.

    await Future.delayed(const Duration(seconds: 2));

    try {
      // Access form values from the argument, not state.fields directly if submit() in base class provides them this way.
      final email = values[emailKey];
      final password = values[passwordKey];
      final checkout = values[checkoutKey];

      print("Logging in with $email / $password / $checkout");

      // Example of a successful login
      emit(state.copyWith(isSubmitting: false, isSuccess: true));

      // Example of a login failure (e.g. wrong credentials)
      // emit(state.copyWith(isSubmitting: false, isFailure: true, apiError: "Invalid credentials."));

    } catch (e) {
      // Handle other errors, e.g. network
      emit(state.copyWith(
        isSubmitting: false,
        isFailure: true,
        apiError: "Login failed. Try again. Error: ${e.toString()}",
      ));
    }
  }
}
