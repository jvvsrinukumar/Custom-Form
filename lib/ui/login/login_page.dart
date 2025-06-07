import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/login/cubit/login_cubit.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:custom_form/ui/phone_number/phone_number_page.dart';
import 'package:custom_form/ui/register/register_page.dart';
import 'package:custom_form/widgets/app_check_box.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: BlocConsumer<LoginCubit, BaseFormState>(
          listenWhen: (prev, curr) =>
              prev.isSubmitting != curr.isSubmitting ||
              prev.isSuccess != curr.isSuccess ||
              prev.isFailure != curr.isFailure ||
              prev.apiError != curr.apiError,
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login Success!')),
              );
            } else if (state.isFailure && state.apiError != null) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Error"),
                  content: Text(state.apiError!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<LoginCubit>();

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Email Field
                      BlocBuilder<LoginCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[LoginCubit.emailKey] !=
                            curr.fields[LoginCubit.emailKey],
                        builder: (context, state) {
                          return AppTextField(
                            label: "Email",
                            keyboardType: TextInputType.emailAddress,
                            errorText: state.fields[LoginCubit.emailKey]?.error,
                            onChanged: (v) =>
                                cubit.updateField(LoginCubit.emailKey, v),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      BlocBuilder<LoginCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[LoginCubit.passwordKey] !=
                            curr.fields[LoginCubit.passwordKey],
                        builder: (context, state) {
                          return AppTextField(
                            label: "Password",
                            obscureText: true,
                            errorText:
                                state.fields[LoginCubit.passwordKey]?.error,
                            onChanged: (v) =>
                                cubit.updateField(LoginCubit.passwordKey, v),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Checkbox Field
                      BlocBuilder<LoginCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[LoginCubit.checkoutKey] !=
                            curr.fields[LoginCubit.checkoutKey],
                        builder: (context, state) {
                          final value =
                              state.fields[LoginCubit.checkoutKey]?.value ??
                                  false;
                          final error =
                              state.fields[LoginCubit.checkoutKey]?.error;

                          return AppCheckboxField(
                            label: "Accept checkout",
                            value: value,
                            errorText: error,
                            onChanged: (v) =>
                                cubit.updateField(LoginCubit.checkoutKey, v),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      BlocBuilder<LoginCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.isFormValid != curr.isFormValid ||
                            prev.isSubmitting != curr.isSubmitting,
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  state.isFormValid && !state.isSubmitting
                                      ? () => cubit.submit()
                                      : null,
                              child: const Text('Login'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        child: const Text("Don't have an account? Register"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                      create: (context) => PhoneNumberCubit(),
                                      child: const PhoneNumberPage(),
                                    )),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Loader
                if (state.isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
