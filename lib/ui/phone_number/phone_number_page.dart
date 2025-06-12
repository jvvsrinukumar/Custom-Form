import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_cubit.dart';
import 'package:custom_form/ui/phone_number/cubit/phone_number_state.dart'; // For DontDisturb
import 'package:custom_form/widgets/custom_numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  late TextEditingController _phoneNumberController;
  // REMOVED: _isKeypadLocallyVisible state variable. Visibility is now driven by cubit state.

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();

    // Note: context.read<PhoneNumberCubit>() here would be problematic if BlocProvider is in the same build method.
    // Initial text will be set by BlocConsumer's builder for the first time.
    // If cubit needs to be accessed for initial setup not tied to build context (e.g. from arguments),
    // consider passing cubit instance or using BlocProvider.of outside build if structure allows.

    _phoneNumberController.addListener(() {
      if (mounted) {
        // It's important that this context can find PhoneNumberCubit.
        // If BlocProvider is in this widget's build method, this listener's context might be an issue
        // when called BEFORE the first build completes.
        // However, listeners are typically called after initial build / user interaction.
        final cubit = context.read<PhoneNumberCubit>();
        final currentCubitText = cubit.state.fields[PhoneNumberCubit.phoneNumberKey]?.value ?? '';
        if (currentCubitText != _phoneNumberController.text) {
          cubit.onPhoneNumberChanged(_phoneNumberController.text);
        }
      }
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  // REMOVED: _toggleKeypadVisibility and _showKeypad methods that used local setState.
  // UI interactions will now call cubit methods.

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = PhoneNumberCubit();
        // Initial text from cubit's state can be set here if controller is available,
        // but _phoneNumberController is an instance variable.
        // It's generally safer to let the BlocBuilder handle initial text setting.
        // Or, ensure cubit is created before controller is initialized if direct sync is needed in create.
        // For this pattern, builder will handle it.
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Enter Phone Number')),
        body: BlocConsumer<PhoneNumberCubit, BaseFormState>(
          listenWhen: (prev, curr) {
            if (curr is DontDisturb) return true;
            // No need to listen for prev.isKeypadVisible != curr.isKeypadVisible for local setState,
            // as builder will react directly to curr.isKeypadVisible.
            return prev.isSubmitting != curr.isSubmitting ||
                prev.isSuccess != curr.isSuccess ||
                prev.isFailure != curr.isFailure ||
                prev.apiError != curr.apiError;
          },
          listener: (context, state) {
            // Local keypad visibility sync removed.

            if (state is DontDisturb) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('DND Active for: ${state.name}')));
              _phoneNumberController.clear();
            } else if (state.isSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Phone Number Submitted!')));
              _phoneNumberController.clear();
            } else if (state.isFailure && state.apiError != null) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text("Error"),
                  content: Text(state.apiError!),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("OK")),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<PhoneNumberCubit>();

            final cubitPhoneNumber = state.fields[PhoneNumberCubit.phoneNumberKey]?.value as String? ?? '';
            if (_phoneNumberController.text != cubitPhoneNumber) {
              _phoneNumberController.text = cubitPhoneNumber;
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _phoneNumberController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          errorText: state.fields[PhoneNumberCubit.phoneNumberKey]?.error,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(state.isKeypadVisible ? Icons.keyboard_hide : Icons.keyboard),
                            onPressed: () => cubit.toggleKeypad(),
                          ),
                        ),
                        onTap: () => cubit.showKeypad(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: state.isFormValid && !state.isSubmitting ? () => cubit.submit() : null,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: state.isSubmitting
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Next', style: TextStyle(fontSize: 18)),
                      ),
                      const Spacer(),
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
                          onChanged: (text) => cubit.onPhoneNumberChanged(text),
                        ),
                      ),
                    ),
                  ),
                if (state.isSubmitting && state.isFormValid)
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
