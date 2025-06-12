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
    // REMOVED: _phoneNumberController.addListener(_onPhoneNumberControllerChanged);
    // The CustomNumericKeypad's onChanged callback handles cubit updates.
  }

  @override
  void dispose() {
    // REMOVED: _phoneNumberController.removeListener(_onPhoneNumberControllerChanged);
    _phoneNumberController.dispose();
    super.dispose();
  }

  // REMOVED: _onPhoneNumberControllerChanged method as it's no longer needed here.
  // The keypad's onChanged callback is the primary way to update the cubit.

  void _clearPhoneNumber(BuildContext context) { // context here is from the builder
    _phoneNumberController.clear();
    // Also update the cubit state when clearing directly
    context.read<PhoneNumberCubit>().onPhoneNumberChanged("");
  }

  @override
  Widget build(BuildContext context) {
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
          listener: (context, state) { // This 'context' is a descendant and valid
            if (state is DontDisturb) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('DND Active for: ${state.name}')),
                );
              _clearPhoneNumber(context); // Pass the valid context
            } else if (state.isSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Phone Number Submitted!')),
                );
              _clearPhoneNumber(context); // Pass the valid context
            } else if (state.isFailure && state.apiError != null) {
              showDialog(
                context: context, // This context is valid
                builder: (dialogContext) => AlertDialog( // dialogContext is also fine
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
          builder: (context, state) { // This 'context' is a descendant and valid
            final cubit = context.read<PhoneNumberCubit>();

            final expectedText =
                state.fields[PhoneNumberCubit.phoneNumberKey]?.value as String? ?? '';
            if (_phoneNumberController.text != expectedText) {
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
                        builder: (context, fieldState) { // This context is valid
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
                            readOnly: true,
                            onTap: () {
                              // context.read<PhoneNumberCubit>() would also be valid here
                              cubit.showKeypad();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<PhoneNumberCubit, BaseFormState>(
                        builder: (context, buttonState) { // This context is valid
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: buttonState.isFormValid &&
                                      !buttonState.isSubmitting
                                  // context.read<PhoneNumberCubit>() would also be valid here
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
                      const SizedBox(height: 100),
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
                      color: Theme.of(context).colorScheme.surface,
                      child: SafeArea(
                        top: false,
                        child: CustomNumericKeypad(
                          controller: _phoneNumberController,
                          onChanged: (text) {
                            // This context is from the BlocConsumer's builder, which is valid.
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
