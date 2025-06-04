import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/drop_down_dm.dart';

class RegisterCubit extends BaseFormCubit {
  static const String emailKey = 'email';
  static const String passwordKey = 'password';
  static const String confirmPasswordKey = 'confirmPassword';
  static const String firstNameKey = 'firstName';
  static const String lastNameKey = 'lastName';
  static const String termsKey = 'terms';
  static const String categoryKey = 'category'; // Added key

  static final List<DropdownItem> categoryItems = [ // Added sample data
    DropdownItem(id: 1, title: "One", subTitle: "Sub One"),
    DropdownItem(id: 2, title: "Two", subTitle: "Sub Two"),
  ];

  RegisterCubit()
      : super(
          initialValues: {
            emailKey: '',
            passwordKey: '',
            confirmPasswordKey: '',
            firstNameKey: '',
            lastNameKey: '',
            termsKey: false,
            categoryKey: null, // Initialize category field with null
          },
          validators: {
            emailKey: _validateEmail,
            passwordKey: _validatePassword,
            confirmPasswordKey: (value, values) =>
                _validateConfirmPassword(value, values[passwordKey]),
            firstNameKey: _validateFirstName,
            lastNameKey: _validateLastName,
            termsKey: _validateTerms,
            categoryKey: (value, values) { // Added category validator
              // The value here will be DropdownItem? because BaseFormCubit stores the raw value.
              if (value == null) return "Category is required";
              return null;
            },
          },
        );

  static String? _validateEmail(String? value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    // Basic email regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? _validatePassword(String? value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  static String? _validateConfirmPassword(String? value, String? passwordValue) {
    if (value == null || value.isEmpty) {
      return "Confirm password is required";
    }
    if (value != passwordValue) {
      return "Passwords do not match";
    }
    return null;
  }

  static String? _validateFirstName(String? value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) {
      return "First name is required";
    }
    return null;
  }

  static String? _validateLastName(String? value, Map<String, dynamic> values) {
    if (value == null || value.isEmpty) {
      return "Last name is required";
    }
    return null;
  }

  static String? _validateTerms(bool? value, Map<String, dynamic> values) {
    if (value != true) {
      return "You must accept the terms and conditions";
    }
    return null;
  }

  @override
  void updateField(String name, dynamic value) {
    super.updateField(name, value);
    if (name == passwordKey) {
      final confirmPasswordValue = state.values[confirmPasswordKey];
      // Re-trigger validation for confirmPasswordKey
      super.updateField(confirmPasswordKey, confirmPasswordValue);
    }
  }

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final email = values[RegisterCubit.emailKey] as String?;

    // **Static API Simulation Logic:**
    if (email == "error@example.com") {
      // Simulate an API error response by throwing an exception
      // BaseFormCubit's catch block will handle this and set apiError
      throw Exception("This email is already registered. Please try another.");
    } else if (email == "networkerror@example.com") {
       throw Exception("A network error occurred. Please try again later.");
    }
    else {
      // Simulate a successful registration
      // For success, we just complete normally. BaseFormCubit will set isSuccess.
      // If you needed to pass a success message or specific data, you'd handle it differently,
      // but for this case, normal completion signifies success.
      return;
    }
  }
}
