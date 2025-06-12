import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_state.dart'; // For DontDisturb
import 'package:custom_form/widgets/app_phone_field_with_keypad.dart'; // Import the new widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneNumberPage extends StatelessWidget { // Changed to StatelessWidget
  const PhoneNumberPage({super.key});

  // Removed initState, dispose, _phoneNumberController, _clearPhoneNumber, etc.

  @override
  Widget build(BuildContext context) {
    // It's good practice to provide the Cubit at a level where all
    // widgets that need it can access it. If NavigationPage pushes this,
    // it might be provided there or here. For standalone use, providing here is fine.
    return BlocProvider(
      create: (_) => PhoneNumberCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Enter Phone Number')),
        body: BlocConsumer<PhoneNumberCubit, BaseFormState>(
          listenWhen: (prev, curr) {
            if (curr is DontDisturb) return true;
            return prev.isSubmitting != curr.isSubmitting ||
                prev.isSuccess != curr.isSuccess ||
                prev.isFailure != curr.isFailure ||
                prev.apiError != curr.apiError;
          },
          listener: (context, state) {
            final cubit = context.read<PhoneNumberCubit>(); // Get cubit for clearing
            if (state is DontDisturb) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('DND Active for: ${state.name}')),
                );
              // Clear the field via cubit. AppPhoneFieldWithKeypad will update via didUpdateWidget.
              cubit.onPhoneNumberChanged("");
            } else if (state.isSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Phone Number Submitted!')),
                );
              cubit.onPhoneNumberChanged("");
            } else if (state.isFailure && state.apiError != null) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text("Error"),
                  content: Text(state.apiError!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<PhoneNumberCubit>();

            return Stack( // Using Stack to potentially overlay messages or loaders if needed by page
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppPhoneFieldWithKeypad(
                        label: "Phone Number",
                        value: state.fields[PhoneNumberCubit.phoneNumberKey]?.value as String? ?? '',
                        errorText: state.fields[PhoneNumberCubit.phoneNumberKey]?.error,
                        onChanged: (newValue) {
                          cubit.onPhoneNumberChanged(newValue);
                        },
                        // If AppPhoneFieldWithKeypad handled its own keypad visibility entirely,
                        // then cubit.showKeypad/hideKeypad calls might not be needed from here.
                        // The current AppPhoneFieldWithKeypad manages its own keypad visibility.
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: state.isFormValid && !state.isSubmitting
                            ? () => cubit.submit()
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          // minimumSize: const Size(double.infinity, 50), // Ensure button stretches if needed
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Next', style: TextStyle(fontSize: 18)),
                      ),
                      // The CustomNumericKeypad is now inside AppPhoneFieldWithKeypad
                      // So no need to conditionally display it here based on state.isKeypadVisible
                      // unless AppPhoneFieldWithKeypad exposes a way to control it externally AND
                      // the cubit state `isKeypadVisible` is still the source of truth.
                      // For now, AppPhoneFieldWithKeypad manages this internally.
                    ],
                  ),
                ),
                // Global loader for page-level submission if needed, though button has its own.
                if (state.isSubmitting && state.isFormValid) // Show general loader if form is valid and submitting
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator()),
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
