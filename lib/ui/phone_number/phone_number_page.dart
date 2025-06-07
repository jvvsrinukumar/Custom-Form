import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
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
    _phoneNumberController.addListener(_onPhoneNumberChanged);
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_onPhoneNumberChanged);
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _onPhoneNumberChanged() {
    if (!mounted) return;
    context
        .read<PhoneNumberCubit>()
        .onPhoneNumberChangedByUI(_phoneNumberController.text);
  }

  void _clearPhoneNumber(BuildContext context) {
    _phoneNumberController.clear();
    // The listener will update the cubit as well
  }

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
            final expectedText =
                state.fields[PhoneNumberCubit.phoneNumberKey]?.value ?? '';
            if (_phoneNumberController.text != expectedText) {
              _phoneNumberController.text = expectedText;
              _phoneNumberController.selection = TextSelection.fromPosition(
                TextPosition(offset: _phoneNumberController.text.length),
              );
            }
            return Stack(
              children: [
                // Main content with padding at bottom for keypad
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocBuilder<PhoneNumberCubit, BaseFormState>(
                        buildWhen: (prev, curr) =>
                            prev.fields[PhoneNumberCubit.phoneNumberKey]
                                    ?.value !=
                                curr.fields[PhoneNumberCubit.phoneNumberKey]
                                    ?.value ||
                            prev.fields[PhoneNumberCubit.phoneNumberKey]
                                    ?.error !=
                                curr.fields[PhoneNumberCubit.phoneNumberKey]
                                    ?.error,
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
                            keyboardType:
                                TextInputType.none, // Prevent default keyboard
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                            maxLength: 10,
                            readOnly: true, // Only editable via keypad
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
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Keypad aligned bottom and on top of all other widgets
                if (state.isKeypadVisible)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Material(
                      elevation: 8,
                      color: Colors.white,
                      child: SafeArea(
                        top: false,
                        child: CustomNumericKeypad(
                          controller: _phoneNumberController,
                          maxLength: 10,
                          onChanged: (text) {
                            context
                                .read<PhoneNumberCubit>()
                                .onPhoneNumberChangedByUI(text);
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
