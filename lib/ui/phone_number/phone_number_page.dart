import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_state.dart'; // Import DontDisturb
import 'package:custom_form/widgets/custom_numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  late final TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    // Listener calls cubit.onPhoneNumberChanged, not cubit.updateField directly
    _phoneNumberController.addListener(_onPhoneNumberControllerChanged);
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_onPhoneNumberControllerChanged);
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Renamed to avoid confusion with cubit's method if any existed with same name
  void _onPhoneNumberControllerChanged() {
    if (!mounted) return;
    // Call the cubit's method for handling UI changes
    context
        .read<PhoneNumberCubit>()
        .onPhoneNumberChanged(_phoneNumberController.text);
  }

  void _clearPhoneNumber(BuildContext context) {
    _phoneNumberController.clear();
    // Cubit update will be handled by the listener _onPhoneNumberControllerChanged
    // or directly if preferred: context.read<PhoneNumberCubit>().onPhoneNumberChanged("");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhoneNumberCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Enter Phone Number')),
        body: BlocConsumer<PhoneNumberCubit, BaseFormState>(
          listenWhen: (prev, curr) {
            // Listen for DontDisturb state specifically, or general success/failure
            if (curr is DontDisturb) return true;
            return prev.isSubmitting != curr.isSubmitting ||
                prev.isSuccess != curr.isSuccess ||
                prev.isFailure != curr.isFailure ||
                prev.apiError != curr.apiError;
          },
          listener: (context, state) {
            if (state is DontDisturb) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('DND Active for: ${state.name}')),
                );
              _clearPhoneNumber(context);
            } else if (state.isSuccess) { // Generic success (not DND)
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Phone Number Submitted!')),
                );
              _clearPhoneNumber(context);
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
            final cubit = context.read<PhoneNumberCubit>();
            // Sync controller with cubit state if they diverge
            // This is important if cubit modifies the number (e.g. formatting)
            final expectedText =
                state.fields[PhoneNumberCubit.phoneNumberKey]?.value as String? ?? '';
            if (_phoneNumberController.text != expectedText) {
              // To prevent listener loop, only update if truly different
              // and also consider if the cubit should be the single source of truth for the text field
              // For now, simple update:
              _phoneNumberController.text = expectedText;
              _phoneNumberController.selection = TextSelection.fromPosition(
                TextPosition(offset: _phoneNumberController.text.length),
              );
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocBuilder<PhoneNumberCubit, BaseFormState>(
                        // buildWhen can be more specific if needed
                        buildWhen: (prev, curr) =>
                            prev.fields[PhoneNumberCubit.phoneNumberKey] !=
                                curr.fields[PhoneNumberCubit.phoneNumberKey] ||
                            prev.isKeypadVisible != curr.isKeypadVisible, // Rebuild on keypad visibility change too
                        builder: (context, fieldState) {
                          return TextFormField(
                            controller: _phoneNumberController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Enter your phone number',
                              errorText: fieldState
                                  .fields[PhoneNumberCubit.phoneNumberKey]
                                  ?.error,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.none,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                            // maxLength: 15, // Max length from cubit validator - REMOVED
                            readOnly: true,
                            onTap: () {
                              cubit.showKeypad();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<PhoneNumberCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.isFormValid != curr.isFormValid ||
                            prev.isSubmitting != curr.isSubmitting,
                        builder: (context, buttonState) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: buttonState.isFormValid &&
                                      !buttonState.isSubmitting
                                  ? () => cubit.submit()
                                  : null,
                              child: buttonState.isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Next',
                                      style: TextStyle(fontSize: 18)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 100), // Space for keypad if visible
                    ],
                  ),
                ),
                if (state.isKeypadVisible)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Material(
                      elevation: 8,
                      color: Theme.of(context).colorScheme.surface, // Use theme color
                      child: SafeArea(
                        top: false,
                        child: CustomNumericKeypad(
                          controller: _phoneNumberController,
                          // maxLength: 15, // Match with TextFormField if it has one - REMOVED
                          onChanged: (text) {
                            // Call the cubit's method for handling UI changes from keypad
                            context
                                .read<PhoneNumberCubit>()
                                .onPhoneNumberChanged(text);
                          },
                        ),
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
