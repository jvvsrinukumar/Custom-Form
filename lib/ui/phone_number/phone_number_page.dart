import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:custom_form/widgets/custom_numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  late final TextEditingController _phoneNumberController;
  // bool _isKeypadVisible = true; // Removed

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    _phoneNumberController.addListener(_onPhoneNumberChanged); // Add listener
  }

  void _onPhoneNumberChanged() {
    // Call updateField on the cubit when the controller's text changes.
    // Need access to cubit here. Can use context.read if initState is too early or pass cubit.
    // However, cubit is not available in initState directly.
    // A common pattern is to trigger this from the build method or use a StatefulWidget property if cubit is available early.
    // For simplicity and directness, let's ensure the cubit is accessed safely.
    // The listener will be called AFTER initState.
    // We can use context.read inside the listener method.
    if (mounted) { // Ensure widget is still in the tree
      context.read<PhoneNumberCubit>().updateField(
            PhoneNumberCubit.phoneNumberKey,
            _phoneNumberController.text,
          );
    }
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_onPhoneNumberChanged); // Remove listener
    _phoneNumberController.dispose();
    super.dispose();
  }

  // void _onNumberPressed(String number, PhoneNumberCubit cubit) {
  //   // Could add length limit here if desired, e.g. if (_phoneNumberController.text.length < 10)
  //   _phoneNumberController.text += number;
  //   cubit.updateField(PhoneNumberCubit.phoneNumberKey, _phoneNumberController.text);
  // }

  // void _onBackspacePressed(PhoneNumberCubit cubit) {
  //   if (_phoneNumberController.text.isNotEmpty) {
  //     _phoneNumberController.text = _phoneNumberController.text
  //         .substring(0, _phoneNumberController.text.length - 1);
  //     cubit.updateField(PhoneNumberCubit.phoneNumberKey, _phoneNumberController.text);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhoneNumberCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Enter Phone Number')),
        body: BlocConsumer<PhoneNumberCubit, BaseFormState>(
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
                  const SnackBar(content: Text('Phone Number Submitted!')),
                );
              // Potentially navigate to next page here
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
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column( // This main Column
                    children: [
                      Expanded( // Wrap existing content to push keypad down
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the text field and button
                          children: [
                            // Phone Number Field (BlocBuilder) - existing code
                            BlocBuilder<PhoneNumberCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.fields[PhoneNumberCubit.phoneNumberKey] != curr.fields[PhoneNumberCubit.phoneNumberKey] ||
                                  prev.isKeypadVisible != curr.isKeypadVisible, // Also rebuild if keypad visibility changes, just in case.
                              builder: (context, fieldState) { // 'fieldState' here is the full BaseFormState from the cubit
                                final newPhoneNumberValue = fieldState.fields[PhoneNumberCubit.phoneNumberKey]?.value?.toString() ?? '';
                                if (_phoneNumberController.text != newPhoneNumberValue) {
                                  _phoneNumberController.text = newPhoneNumberValue;
                                  // Move cursor to the end
                                  _phoneNumberController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _phoneNumberController.text.length),
                                  );
                                }
                                return TextFormField(
                                  controller: _phoneNumberController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    hintText: 'Enter your phone number',
                                    errorText: fieldState.fields[PhoneNumberCubit.phoneNumberKey]?.error,
                                    border: const OutlineInputBorder(),
                                  ),
                                  readOnly: true,
                                  showCursor: true,
                                  keyboardType: TextInputType.none,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20),
                                  onTap: () {
                                    context.read<PhoneNumberCubit>().showKeypad();
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Next Button (BlocBuilder) - existing code
                            BlocBuilder<PhoneNumberCubit, BaseFormState>(
                              buildWhen: (prev, curr) =>
                                  prev.isFormValid != curr.isFormValid ||
                                  prev.isSubmitting != curr.isSubmitting,
                              builder: (context, buttonState) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: buttonState.isFormValid && !buttonState.isSubmitting
                                        ? () {
                                            context.read<PhoneNumberCubit>().hideKeypad(); // Call cubit method
                                            cubit.submit(); // cubit is already available in this scope from BlocBuilder
                                          }
                                        : null,
                                    child: const Text('Next', style: TextStyle(fontSize: 18)),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Conditionally display Custom Numeric Keypad
                      if (state.isKeypadVisible) // Use state from BlocBuilder
                        CustomNumericKeypad(
                          controller: _phoneNumberController,
                          maxLength: 10, // Example max length
                        ),
                      const SizedBox(height: 20), // Padding at the bottom
                    ],
                  ),
                ),
                if (state.isSubmitting) // Loader - existing code
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
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
