import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';

// typedef FieldValidator = String? Function(dynamic value);

class LoginCubit extends BaseFormCubit {
  static const String emailKey = 'email';
  static const String passwordKey = 'password';
  static const String checkoutKey = 'checkout';

  LoginCubit()
      : super(
          {
            emailKey: '',
            passwordKey: '',
            checkoutKey: false,
          },
          validators: {
            emailKey: (value, _) {
              if (value == null || value.isEmpty) return "Email required";
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) return "Enter valid email";
              return null;
            },
            passwordKey: (value, _) {
              if (value == null || value.isEmpty) return "Password required";
              if (value.length < 6) return "Min 6 characters";
              return null;
            },
            checkoutKey: (value, _) {
              if (value != true) return "Must accept terms";
              return null;
            },
          },
        );

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      // Access form values
      final email = values[emailKey];
      final password = values[passwordKey];
      final checkout = values[checkoutKey];

      // Here you would call your API with these values.
      print("Logging in with $email / $password / $checkout");

      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        isFailure: true,
        apiError: "Login failed. Try again.",
      ));
    }
  }
}
