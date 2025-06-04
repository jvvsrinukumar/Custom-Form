import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/data/drop_down_dm.dart';

class RegisterCubit extends BaseFormCubit {
  static const String emailKey = 'email';
  static const String passwordKey = 'password';
  static const String confirmPasswordKey = 'confirmPassword';
  static const String firstNameKey = 'firstName';
  static const String lastNameKey = 'lastName';
  static const String termsKey = 'terms';
  static const String categoryKey = 'category';
  static const String usernameKey = 'username';
  static const String obscurePasswordKey = 'obscurePassword';
  static const String obscureConfirmPasswordKey = 'obscureConfirmPassword';

  static final List<DropdownItem> categoryItems = [
    DropdownItem(id: 1, title: "One", subTitle: "Sub One"),
    DropdownItem(id: 2, title: "Two", subTitle: "Sub Two"),
  ];

  RegisterCubit()
      : super(
          {
            emailKey: '',
            passwordKey: '',
            confirmPasswordKey: '',
            firstNameKey: '',
            lastNameKey: '',
            usernameKey: '',
            termsKey: false,
            categoryKey: null,
            obscurePasswordKey: true,
            obscureConfirmPasswordKey: true,
          },
          validators: {
            emailKey: _validateEmail,
            passwordKey: _validatePassword,
            confirmPasswordKey: _validateConfirmPassword,
            firstNameKey: _validateFirstName,
            lastNameKey: _validateLastName,
            termsKey: _validateTerms,
            categoryKey: _validateCategory,
          },
        );

  static String? _validateEmail(dynamic value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  static String? _validatePassword(dynamic value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  static String? _validateConfirmPassword(
      dynamic value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) return "Confirm password is required";
    if (value != values[passwordKey]) return "Passwords do not match";
    return null;
  }

  static String? _validateFirstName(
      dynamic value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) return "First name is required";
    return null;
  }

  static String? _validateLastName(dynamic value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) return "Last name is required";
    return null;
  }

  static String? _validateTerms(dynamic value, Map<String, dynamic> values) {
    if (value != true) return "You must accept the terms and conditions";
    return null;
  }

  static String? _validateCategory(dynamic value, Map<String, dynamic> values) {
    if (value == null) return "Category selection is required";
    return null;
  }

  @override
  void updateField(String name, dynamic value) {
    super.updateField(name, value);
    if (name == passwordKey) {
      final confirmPasswordValue = currentValues[confirmPasswordKey];
      super.updateField(confirmPasswordKey, confirmPasswordValue);
    }
  }

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    await Future.delayed(Duration(seconds: 2));

    final email = values[emailKey] as String?;

    if (email == "error@example.com") {
      throw Exception("This email is already registered. Please try another.");
    } else if (email == "networkerror@example.com") {
      throw Exception("A network error occurred. Please try again later.");
    } else {
      // Simulate success
      return;
    }
  }

  void togglePasswordVisibility() {
    final currentObscureState =
        state.fields[obscurePasswordKey]?.value as bool? ?? true;
    updateField(obscurePasswordKey, !currentObscureState);
  }

  void toggleConfirmPasswordVisibility() {
    final currentObscureState =
        state.fields[obscureConfirmPasswordKey]?.value as bool? ?? true;
    updateField(obscureConfirmPasswordKey, !currentObscureState);
  }
}
