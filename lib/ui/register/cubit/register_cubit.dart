import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart'; // Required for BaseFormFieldState
import 'package:custom_form/core/data/drop_down_dm.dart';

class RegisterCubit extends BaseFormCubit {
  static const String emailKey = 'email';
  static const String passwordKey = 'password';
  static const String confirmPasswordKey = 'confirmPassword';
  static const String firstNameKey = 'firstName';
  static const String lastNameKey = 'lastName';
  static const String termsKey = 'terms';
  static const String categoryKey = 'category';
  static const String usernameKey = 'username'; // Assuming this should also be initialized
  static const String obscurePasswordKey = 'obscurePassword';
  static const String obscureConfirmPasswordKey = 'obscureConfirmPassword';

  static final List<DropdownItem> categoryItems = [
    const DropdownItem(id: 1, title: "One", subTitle: "Sub One"),
    const DropdownItem(id: 2, title: "Two", subTitle: "Sub Two"),
  ];

  // Store validators map for the getter
  final Map<String, FieldValidator> _fieldValidators;

  RegisterCubit() :
    _fieldValidators = { // Initialize _fieldValidators before super() or in initializer list if not final
      emailKey: _validateEmail,
      passwordKey: _validatePassword,
      confirmPasswordKey: _validateConfirmPassword,
      firstNameKey: _validateFirstName,
      lastNameKey: _validateLastName,
      termsKey: _validateTerms,
      categoryKey: _validateCategory,
      usernameKey: (value, _) { // Added basic validator for usernameKey
        if (value == null || value.toString().isEmpty) return "Username is required";
        return null;
      },
      // obscurePasswordKey and obscureConfirmPasswordKey are for UI state, no validation needed
    },
    super() { // Call no-arg constructor

    initializeFormFields({
      emailKey: const BaseFormFieldState(value: '', initialValue: ''),
      passwordKey: const BaseFormFieldState(value: '', initialValue: ''),
      confirmPasswordKey: const BaseFormFieldState(value: '', initialValue: ''),
      firstNameKey: const BaseFormFieldState(value: '', initialValue: ''),
      lastNameKey: const BaseFormFieldState(value: '', initialValue: ''),
      usernameKey: const BaseFormFieldState(value: '', initialValue: ''), // Initialize usernameKey
      termsKey: const BaseFormFieldState(value: false, initialValue: false),
      categoryKey: const BaseFormFieldState(value: null, initialValue: null), // Corrected: Removed type argument
      obscurePasswordKey: const BaseFormFieldState(value: true, initialValue: true),
      obscureConfirmPasswordKey: const BaseFormFieldState(value: true, initialValue: true),
    });
  }

  @override
  Map<String, FieldValidator> get validators => _fieldValidators;

  // Validator functions (static as they don't depend on instance state)
  static String? _validateEmail(dynamic value, Map<String, dynamic> values) {
    if (value == null || value.toString().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.toString())) return "Enter a valid email";
    return null;
  }

  static String? _validatePassword(dynamic value, Map<String, dynamic> values) {
    if (value == null || value.toString().isEmpty) return "Password is required";
    if (value.toString().length < 6) return "Password must be at least 6 characters";
    return null;
  }

  static String? _validateConfirmPassword(dynamic value, Map<String, dynamic> values) {
    if (value == null || value.toString().isEmpty) return "Confirm password is required";
    if (value.toString() != values[passwordKey]?.toString()) return "Passwords do not match";
    return null;
  }

  static String? _validateFirstName(dynamic value, Map<String, dynamic> values) {
    if (value == null || value.toString().isEmpty) return "First name is required";
    return null;
  }

  static String? _validateLastName(dynamic value, Map<String, dynamic> values) {
    if (value == null || value.toString().isEmpty) return "Last name is required";
    return null;
  }

  static String? _validateTerms(dynamic value, Map<String, dynamic> values) {
    if (value != true) return "You must accept the terms and conditions";
    return null;
  }

  static String? _validateCategory(dynamic value, Map<String, dynamic> values) {
    // Value for dropdown will be DropdownItem's ID or the DropdownItem itself.
    // BaseFormFieldState for categoryKey is set to DropdownItem?
    // So, value here could be null or a DropdownItem.
    // If storing ID, then adjust logic. Assuming it's the DropdownItem or its ID.
    if (value == null) return "Category selection is required";
    return null;
  }

  // Override updateField if specific logic is needed, e.g., for confirmPassword
  // The BaseFormCubit's updateField should handle most cases.
  // The existing override re-validates confirmPassword when password changes.
  // This logic should be preserved.
  @override
  void updateField(String name, dynamic value) {
    super.updateField(name, value); // Call base class method first
    if (name == passwordKey) {
      // Trigger re-validation of confirmPasswordKey if password changes
      // The value of confirmPasswordKey itself doesn't change here, but its validity might.
      final confirmPasswordValue = state.fields[confirmPasswordKey]?.value;
      // Only re-validate if confirmPassword has a value, to avoid clearing its error state prematurely if it's empty
      // and password is changed. The base updateField would have already validated confirmPasswordValue if it changed.
      // This ensures it re-validates against the *new* password value.
      super.updateField(confirmPasswordKey, confirmPasswordValue);
    }
  }

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // BaseFormCubit's submit() method already sets isSubmitting to true and clears previous errors.
    // emit(state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false, apiError: null));
    await Future.delayed(const Duration(seconds: 2));

    final email = values[emailKey] as String?;

    try {
      if (email == "error@example.com") {
        // throw Exception("This email is already registered. Please try another.");
        // To align with how BaseFormCubit expects errors for UI display:
        emit(state.copyWith(isSubmitting: false, isFailure: true, apiError: "This email is already registered. Please try another."));
        return;
      } else if (email == "networkerror@example.com") {
        // throw Exception("A network error occurred. Please try again later.");
        emit(state.copyWith(isSubmitting: false, isFailure: true, apiError: "A network error occurred. Please try again later."));
        return;
      }

      // Simulate success
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) { // Catch any other unexpected errors
        emit(state.copyWith(isSubmitting: false, isFailure: true, apiError: e.toString()));
    }
  }

  void togglePasswordVisibility() {
    final currentObscureState = state.fields[obscurePasswordKey]?.value as bool? ?? true;
    updateField(obscurePasswordKey, !currentObscureState);
  }

  void toggleConfirmPasswordVisibility() {
    final currentObscureState = state.fields[obscureConfirmPasswordKey]?.value as bool? ?? true;
    updateField(obscureConfirmPasswordKey, !currentObscureState);
  }
}
