import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:custom_form/core/data/user_model.dart';
import 'cubit/profile_page_cubit.dart';
import 'cubit/profile_form_state.dart'; // Contains ProfileFieldKeys

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfilePageCubit, ProfileFormState>(
      listenWhen: (prev, curr) =>
          prev.baseState.isSubmitting != curr.baseState.isSubmitting ||
          prev.baseState.isSuccess != curr.baseState.isSuccess ||
          prev.baseState.isFailure != curr.baseState.isFailure ||
          prev.baseState.apiError != curr.baseState.apiError,
      listener: (context, state) {
        if (state.baseState.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Profile saved successfully!')),
            );
        } else if (state.baseState.isFailure && state.baseState.apiError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.baseState.apiError!)),
            );
        }
      },
      builder: (context, state) {
        final profileCubit = context.read<ProfilePageCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              if (state.isEditMode)
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save',
                  onPressed: state.baseState.isSubmitting ? null : () {
                    profileCubit.submit();
                  },
                ),
              IconButton(
                icon: Icon(state.isEditMode ? Icons.cancel : Icons.edit),
                tooltip: state.isEditMode ? 'Cancel Edits' : 'Edit Profile',
                onPressed: () {
                  profileCubit.toggleEditMode();
                },
              ),
            ],
          ),
          body: Stack( // For overlay loading indicator
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        child: Text(
                          state.user.firstName.isNotEmpty
                              ? state.user.firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // First Name Field
                      BlocBuilder<ProfilePageCubit, ProfileFormState>(
                        buildWhen: (prev, curr) =>
                            prev.baseState.fields[ProfileFieldKeys.firstName] != curr.baseState.fields[ProfileFieldKeys.firstName] ||
                            prev.isEditMode != curr.isEditMode,
                        builder: (context, fieldState) {
                          return AppTextField(
                            label: 'First Name',
                            value: fieldState.baseState.fields[ProfileFieldKeys.firstName]?.value?.toString() ?? '',
                            errorText: fieldState.baseState.fields[ProfileFieldKeys.firstName]?.error,
                            enabled: fieldState.isEditMode,
                            onChanged: (value) {
                              profileCubit.updateField(ProfileFieldKeys.firstName, value);
                            },
                            suffixIcon: fieldState.isEditMode ? const Icon(Icons.edit) : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Last Name Field
                      BlocBuilder<ProfilePageCubit, ProfileFormState>(
                        buildWhen: (prev, curr) =>
                            prev.baseState.fields[ProfileFieldKeys.lastName] != curr.baseState.fields[ProfileFieldKeys.lastName] ||
                            prev.isEditMode != curr.isEditMode,
                        builder: (context, fieldState) {
                          return AppTextField(
                            label: 'Last Name',
                            value: fieldState.baseState.fields[ProfileFieldKeys.lastName]?.value?.toString() ?? '',
                            errorText: fieldState.baseState.fields[ProfileFieldKeys.lastName]?.error,
                            enabled: fieldState.isEditMode,
                            onChanged: (value) {
                              profileCubit.updateField(ProfileFieldKeys.lastName, value);
                            },
                            suffixIcon: fieldState.isEditMode ? const Icon(Icons.edit) : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      BlocBuilder<ProfilePageCubit, ProfileFormState>(
                        buildWhen: (prev, curr) =>
                            prev.baseState.fields[ProfileFieldKeys.email] != curr.baseState.fields[ProfileFieldKeys.email] ||
                            prev.isEditMode != curr.isEditMode,
                        builder: (context, fieldState) {
                          return AppTextField(
                            label: 'Email',
                            value: fieldState.baseState.fields[ProfileFieldKeys.email]?.value?.toString() ?? '',
                            errorText: fieldState.baseState.fields[ProfileFieldKeys.email]?.error,
                            enabled: fieldState.isEditMode,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              profileCubit.updateField(ProfileFieldKeys.email, value);
                            },
                            suffixIcon: fieldState.isEditMode ? const Icon(Icons.edit) : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field - wrapped for consistency, though simpler buildWhen could apply
                      BlocBuilder<ProfilePageCubit, ProfileFormState>(
                         buildWhen: (prev, curr) =>
                            prev.baseState.fields[ProfileFieldKeys.password] != curr.baseState.fields[ProfileFieldKeys.password] ||
                            prev.isEditMode != curr.isEditMode, // isEditMode won't change enabled, but for consistency
                         builder: (context, fieldState) {
                            return AppTextField(
                              label: 'Password',
                              value: fieldState.baseState.fields[ProfileFieldKeys.password]?.value?.toString() ?? '',
                              obscureText: true,
                              enabled: false, // Always disabled
                            );
                         }
                      ),
                      const SizedBox(height: 24),
                      // Inline feedback messages removed, handled by SnackBar in listener
                    ],
                  ),
                ),
              ),
              // Overlay Loading Indicator
              if (state.baseState.isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
