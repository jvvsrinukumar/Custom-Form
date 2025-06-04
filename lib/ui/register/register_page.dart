import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/drop_down_dm.dart';
import 'package:custom_form/widgets/app_check_box.dart';
import 'package:custom_form/widgets/app_drop_down.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/register_cubit.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: BlocConsumer<RegisterCubit, BaseFormState>(
        listenWhen: (prev, curr) =>
            prev.isSubmitting != curr.isSubmitting ||
            prev.isSuccess != curr.isSuccess ||
            prev.isFailure != curr.isFailure ||
            prev.apiError != curr.apiError,
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text("Registration Successful!")),
              );
            // Optionally navigate: Navigator.of(context).pop();
          } else if (state.isFailure && state.apiError != null) {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text("Registration Error"),
                content: Text(state.apiError!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BlocBuilder<RegisterCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[RegisterCubit.firstNameKey] !=
                            curr.fields[RegisterCubit.firstNameKey],
                        builder: (context, fieldState) {
                          return AppTextField(
                            label: "First Name",
                            errorText: fieldState
                                .fields[RegisterCubit.firstNameKey]?.error,
                            onChanged: (value) =>
                                cubit.updateField(RegisterCubit.firstNameKey, value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<RegisterCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[RegisterCubit.categoryKey] !=
                            curr.fields[RegisterCubit.categoryKey],
                        builder: (context, fieldState) {
                          final DropdownItem? selectedCategory = fieldState
                              .fields[RegisterCubit.categoryKey]?.value as DropdownItem?;
                          final String? errorText =
                              fieldState.fields[RegisterCubit.categoryKey]?.error;

                          return DropdownField(
                            label: "Category",
                            value: selectedCategory,
                            items: RegisterCubit.categoryItems,
                            onChanged: (DropdownItem? newValue) {
                              cubit.updateField(
                                  RegisterCubit.categoryKey, newValue);
                            },
                            errorText: errorText,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<RegisterCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[RegisterCubit.lastNameKey] !=
                            curr.fields[RegisterCubit.lastNameKey],
                        builder: (context, fieldState) {
                          return AppTextField(
                            label: "Last Name",
                            errorText: fieldState
                                .fields[RegisterCubit.lastNameKey]?.error,
                            onChanged: (value) =>
                                cubit.updateField(RegisterCubit.lastNameKey, value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<RegisterCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[RegisterCubit.emailKey] !=
                            curr.fields[RegisterCubit.emailKey],
                        builder: (context, fieldState) {
                          return AppTextField(
                            label: "Email",
                            keyboardType: TextInputType.emailAddress,
                            errorText:
                                fieldState.fields[RegisterCubit.emailKey]?.error,
                            onChanged: (value) =>
                                cubit.updateField(RegisterCubit.emailKey, value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<RegisterCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[RegisterCubit.passwordKey] !=
                            curr.fields[RegisterCubit.passwordKey],
                        builder: (context, fieldState) {
                          return AppTextField(
                            label: "Password",
                            obscureText: true,
                            errorText: fieldState
                                .fields[RegisterCubit.passwordKey]?.error,
                            onChanged: (value) =>
                                cubit.updateField(RegisterCubit.passwordKey, value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<RegisterCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[RegisterCubit.confirmPasswordKey] !=
                            curr.fields[RegisterCubit.confirmPasswordKey],
                        builder: (context, fieldState) {
                          return AppTextField(
                            label: "Confirm Password",
                            obscureText: true,
                            errorText: fieldState
                                .fields[RegisterCubit.confirmPasswordKey]?.error,
                            onChanged: (value) => cubit.updateField(
                                RegisterCubit.confirmPasswordKey, value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<RegisterCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[RegisterCubit.termsKey] !=
                            curr.fields[RegisterCubit.termsKey],
                        builder: (context, fieldState) {
                          final field = fieldState.fields[RegisterCubit.termsKey];
                          return AppCheckboxField(
                            label: "I accept the terms and conditions.",
                            value: field?.value ?? false,
                            errorText: field?.error,
                            onChanged: (value) => cubit.updateField(
                                RegisterCubit.termsKey, value ?? false),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<RegisterCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.isFormValid != curr.isFormValid ||
                            prev.isSubmitting != curr.isSubmitting,
                        builder: (context, buttonState) {
                          return ElevatedButton(
                            onPressed: buttonState.isFormValid && !buttonState.isSubmitting
                                ? () => cubit.submit()
                                : null,
                            child: const Text("Register"),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (state.isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
