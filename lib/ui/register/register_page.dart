import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/drop_down_dm.dart';
import 'package:custom_form/ui/register/cubit/register_cubit.dart';
import 'package:custom_form/widgets/app_check_box.dart';
import 'package:custom_form/widgets/app_drop_down.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(),
      child: Builder(
        builder: (context) {
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
                            // First Name
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[RegisterCubit.firstNameKey] !=
                                  curr.fields[RegisterCubit.firstNameKey],
                              builder: (context, fieldState) {
                                return AppTextField(
                                  label: "First Name",
                                  value: fieldState.fields[RegisterCubit.firstNameKey]?.value,
                                  errorText: fieldState
                                      .fields[RegisterCubit.firstNameKey]
                                      ?.error,
                                  onChanged: (value) => cubit.updateField(
                                      RegisterCubit.firstNameKey, value),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Last Name
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[RegisterCubit.lastNameKey] !=
                                  curr.fields[RegisterCubit.lastNameKey],
                              builder: (context, fieldState) {
                                return AppTextField(
                                  label: "Last Name",
                                  value: fieldState.fields[RegisterCubit.lastNameKey]?.value,
                                  errorText: fieldState
                                      .fields[RegisterCubit.lastNameKey]?.error,
                                  onChanged: (value) => cubit.updateField(
                                      RegisterCubit.lastNameKey, value),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Username (optional)
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[RegisterCubit.usernameKey] !=
                                  curr.fields[RegisterCubit.usernameKey],
                              builder: (context, fieldState) {
                                return AppTextField(
                                  label: "Username (Optional)",
                                  value: fieldState.fields[RegisterCubit.usernameKey]?.value,
                                  onChanged: (value) => cubit.updateField(
                                      RegisterCubit.usernameKey, value),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Category Dropdown
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[RegisterCubit.categoryKey] !=
                                  curr.fields[RegisterCubit.categoryKey],
                              builder: (context, fieldState) {
                                final selectedCategory = fieldState
                                    .fields[RegisterCubit.categoryKey]
                                    ?.value as DropdownItem?;
                                final errorText = fieldState
                                    .fields[RegisterCubit.categoryKey]?.error;

                                return DropdownField(
                                  label: "Category",
                                  value: selectedCategory,
                                  items: RegisterCubit.categoryItems,
                                  onChanged: (item) => cubit.updateField(
                                      RegisterCubit.categoryKey, item),
                                  errorText: errorText,
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[RegisterCubit.emailKey] !=
                                  curr.fields[RegisterCubit.emailKey],
                              builder: (context, fieldState) {
                                return AppTextField(
                                  label: "Email",
                                  keyboardType: TextInputType.emailAddress,
                                  value: fieldState.fields[RegisterCubit.emailKey]?.value,
                                  errorText: fieldState
                                      .fields[RegisterCubit.emailKey]?.error,
                                  onChanged: (value) => cubit.updateField(
                                      RegisterCubit.emailKey, value),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[RegisterCubit.passwordKey] !=
                                  curr.fields[RegisterCubit.passwordKey],
                              builder: (context, fieldState) {
                                final obscurePass = state
                                        .fields[
                                            RegisterCubit.obscurePasswordKey]
                                        ?.value as bool? ??
                                    true;
                                return AppTextField(
                                  label: "Password",
                                  obscureText: obscurePass,
                                  value: fieldState.fields[RegisterCubit.passwordKey]?.value,
                                  errorText: fieldState
                                      .fields[RegisterCubit.passwordKey]?.error,
                                  onChanged: (value) => cubit.updateField(
                                      RegisterCubit.passwordKey, value),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePass
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () =>
                                        cubit.togglePasswordVisibility(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[
                                      RegisterCubit.confirmPasswordKey] !=
                                  curr.fields[RegisterCubit.confirmPasswordKey],
                              builder: (context, state) { // Corrected: Uses 'state' as per subtask for this field
                                final obscureConfirmPass = state
                                        .fields[RegisterCubit
                                            .obscureConfirmPasswordKey]
                                        ?.value as bool? ??
                                    true;
                                return AppTextField(
                                  label: "Confirm Password",
                                  obscureText: obscureConfirmPass,
                                  value: state.fields[RegisterCubit.confirmPasswordKey]?.value, // Corrected: Uses 'state'
                                  errorText: state
                                      .fields[RegisterCubit.confirmPasswordKey]
                                      ?.error,
                                  onChanged: (value) => cubit.updateField(
                                      RegisterCubit.confirmPasswordKey, value),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscureConfirmPass
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () =>
                                        cubit.toggleConfirmPasswordVisibility(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Terms and Conditions Checkbox
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[RegisterCubit.termsKey] !=
                                  curr.fields[RegisterCubit.termsKey],
                              builder: (context, fieldState) {
                                final field =
                                    fieldState.fields[RegisterCubit.termsKey];
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

                            // Submit Button
                            BlocBuilder<RegisterCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.isFormValid != curr.isFormValid ||
                                  prev.isSubmitting != curr.isSubmitting,
                              builder: (context, buttonState) {
                                return ElevatedButton(
                                  onPressed: buttonState.isFormValid &&
                                          !buttonState.isSubmitting
                                      ? cubit.submit
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
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
