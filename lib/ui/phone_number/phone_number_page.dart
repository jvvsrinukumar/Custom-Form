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
  // Keypad visibility is now managed by this page's state.
  // The cubit's isKeypadVisible might still be used to inform initial state or if cubit needs to hide it.
  bool _isKeypadLocallyVisible = true;

  @override
  void initState() {
    super.initState();
    // Initialize controller. Cubit might provide initial value later via BlocListener or initial state.
    _phoneNumberController = TextEditingController();

    // Add listener to sync controller changes TO the cubit
    _phoneNumberController.addListener(() {
      // Ensure context is available and cubit is accessible.
      // This is safe as listener is tied to controller's lifecycle, which is tied to this state.
      if (mounted) {
        final cubit = context.read<PhoneNumberCubit>();
        // Only update cubit if text actually differs from cubit's state to avoid loops
        if (cubit.state.fields[PhoneNumberCubit.phoneNumberKey]?.value != _phoneNumberController.text) {
          cubit.onPhoneNumberChanged(_phoneNumberController.text);
        }
      }
    });

    // Set initial text if cubit already has a value (e.g. on page revisit)
    // This needs to be done carefully, typically after the first frame or via a listener.
    // For simplicity, we'll rely on BlocConsumer's builder to set initial text.
    // Or, if cubit is available immediately (which it is in BlocProvider's create):
    // final initialCubitState = context.read<PhoneNumberCubit>().state;
    // _phoneNumberController.text = initialCubitState.fields[PhoneNumberCubit.phoneNumberKey]?.value ?? '';
    //
    // Deferring this to BlocProvider's create or first build via BlocBuilder.
  }

  @override
  void dispose() {
    _phoneNumberController.dispose(); // Dispose controller
    super.dispose();
  }

  void _toggleKeypadVisibility() {
    setState(() {
      _isKeypadLocallyVisible = !_isKeypadLocallyVisible;
    });
    // Optionally, inform cubit if it needs to know about UI-driven keypad changes
    // final cubit = context.read<PhoneNumberCubit>();
    // if (_isKeypadLocallyVisible) cubit.showKeypad(); else cubit.hideKeypad();
    // Since cubit no longer has show/hide keypad, this part is commented out.
  }

  void _showKeypad() {
    if (!_isKeypadLocallyVisible) {
      setState(() {
        _isKeypadLocallyVisible = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (blocContext) { // Renamed to blocContext to avoid clash if needed, though not here.
        final cubit = PhoneNumberCubit();
        // Set initial controller text from cubit's initial state after cubit is created.
        // This ensures controller has the value when the TextFormField is first built.
        final initialValue = cubit.state.fields[PhoneNumberCubit.phoneNumberKey]?.value as String? ?? '';
        _phoneNumberController.text = initialValue;
        // And potentially sync keypad visibility from cubit's initial state
        _isKeypadLocallyVisible = cubit.state.isKeypadVisible;
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Enter Phone Number')),
        body: BlocConsumer<PhoneNumberCubit, BaseFormState>(
          listenWhen: (prev, curr) {
            if (curr is DontDisturb) return true;
            // Also listen if keypad visibility from cubit changes, to sync local state
            if (prev.isKeypadVisible != curr.isKeypadVisible) return true;
            return prev.isSubmitting != curr.isSubmitting ||
                prev.isSuccess != curr.isSuccess ||
                prev.isFailure != curr.isFailure ||
                prev.apiError != curr.apiError;
          },
          listener: (context, state) {
            // Sync local keypad visibility if cubit dictates it (e.g. after submit)
            if (_isKeypadLocallyVisible != state.isKeypadVisible) {
                setState(() {
                  _isKeypadLocallyVisible = state.isKeypadVisible;
                });
            }

            if (state is DontDisturb) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('DND Active for: ${state.name}')));
              _phoneNumberController.clear(); // Clear controller, listener will inform cubit
            } else if (state.isSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Phone Number Submitted!')));
              _phoneNumberController.clear(); // Clear controller
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

            // Sync controller text if cubit's state changed it
            final cubitPhoneNumber = state.fields[PhoneNumberCubit.phoneNumberKey]?.value as String? ?? '';
            if (_phoneNumberController.text != cubitPhoneNumber) {
              _phoneNumberController.text = cubitPhoneNumber;
              // Check if the controller is already focused to prevent moving cursor unnecessarily
              // if the change came from the controller's own listener.
              // However, if change comes from cubit (e.g. after submit), this is fine.
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
                        readOnly: true, // Input via custom keypad
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          errorText: state.fields[PhoneNumberCubit.phoneNumberKey]?.error,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_isKeypadLocallyVisible ? Icons.keyboard_hide : Icons.keyboard),
                            onPressed: _toggleKeypadVisibility,
                          ),
                        ),
                        onTap: _showKeypad, // Show keypad when field is tapped
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: state.isFormValid && !state.isSubmitting ? () => cubit.submit() : null,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: state.isSubmitting
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Next', style: TextStyle(fontSize: 18)),
                      ),
                      // Using Spacer to push keypad to bottom if it were in a Column,
                      // but since keypad is in Stack, this primarily just takes up remaining space in the Column.
                      const Spacer(),
                    ],
                  ),
                ),
                if (_isKeypadLocallyVisible)
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
                          controller: _phoneNumberController, // Controller is managed by this page
                          // onChanged is not strictly needed if controller listener is robust.
                          // If provided, it would also call cubit.onPhoneNumberChanged.
                          // The controller's listener (_phoneNumberController.addListener) handles this.
                        ),
                      ),
                    ),
                  ),
                // Global loader
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
