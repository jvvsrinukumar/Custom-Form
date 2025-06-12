import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/login_phone/cubit/login_phone_cubit.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPhonePage extends StatelessWidget {
  const LoginPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginPhoneCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login with Phone')),
        body: BlocConsumer<LoginPhoneCubit, BaseFormState>(
          listenWhen: (prev, curr) =>
              prev.isSubmitting != curr.isSubmitting ||
              prev.isSuccess != curr.isSuccess ||
              prev.isFailure != curr.isFailure ||
              prev.apiError != curr.apiError,
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Submit Success!')),
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
            final cubit = context.read<LoginPhoneCubit>();

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Phone Number Field
                      BlocBuilder<LoginPhoneCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[LoginPhoneCubit.phoneKey] !=
                            curr.fields[LoginPhoneCubit.phoneKey],
                        builder: (context, state) {
                          return AppTextField(
                            label: "Phone Number",
                            keyboardType: TextInputType.phone,
                            inputFormatters: [ // Add this
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            value: state.fields[LoginPhoneCubit.phoneKey]?.value,
                            errorText: state.fields[LoginPhoneCubit.phoneKey]?.error,
                            onChanged: (v) =>
                                cubit.updateField(LoginPhoneCubit.phoneKey, v),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      BlocBuilder<LoginPhoneCubit, BaseFormState>(
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
                              child: const Text('Submit'),
                            ),
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
