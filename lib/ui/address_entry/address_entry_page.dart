import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/core/data/drop_down_dm.dart';
import 'package:custom_form/ui/address_entry/cubit/address_entry_cubit.dart';
import 'package:custom_form/widgets/app_drop_down.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressEntryPage extends StatefulWidget {
  final AddressData? initialAddressData;

  const AddressEntryPage({super.key, this.initialAddressData});

  @override
  _AddressEntryPageState createState() => _AddressEntryPageState();
}

class _AddressEntryPageState extends State<AddressEntryPage> {
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _landmarkController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with initial text from widget.initialAddressData
    // The cubit will independently initialize its state from this same data.
    _streetController = TextEditingController(text: widget.initialAddressData?.address ?? '');
    _cityController = TextEditingController(text: widget.initialAddressData?.city ?? '');
    _pincodeController = TextEditingController(text: widget.initialAddressData?.zipCode ?? '');
    _landmarkController = TextEditingController(text: widget.initialAddressData?.landmark ?? '');

    // Add listeners to update cubit on text change
    // Listeners use context.read<AddressEntryCubit>() which is valid as they are called after build.
    _streetController.addListener(_onStreetChanged);
    _cityController.addListener(_onCityChanged);
    _pincodeController.addListener(_onPincodeChanged);
    _landmarkController.addListener(_onLandmarkChanged);
  }

  void _onStreetChanged() {
    // Check to prevent loops if cubit state update somehow triggers controller text update.
    // context.read is safe here as listeners are called after initial build.
    final cubit = context.read<AddressEntryCubit>();
    if (cubit.state.fields[AddressEntryCubit.streetKey]?.value != _streetController.text) {
      cubit.updateField(AddressEntryCubit.streetKey, _streetController.text);
    }
  }

  void _onCityChanged() {
    final cubit = context.read<AddressEntryCubit>();
    if (cubit.state.fields[AddressEntryCubit.cityKey]?.value != _cityController.text) {
      cubit.updateField(AddressEntryCubit.cityKey, _cityController.text);
    }
  }

  void _onPincodeChanged() {
    final cubit = context.read<AddressEntryCubit>();
    if (cubit.state.fields[AddressEntryCubit.pincodeKey]?.value != _pincodeController.text) {
      cubit.updateField(AddressEntryCubit.pincodeKey, _pincodeController.text);
    }
  }

  void _onLandmarkChanged() {
    final cubit = context.read<AddressEntryCubit>();
    if (cubit.state.fields[AddressEntryCubit.landmarkKey]?.value != _landmarkController.text) {
      cubit.updateField(AddressEntryCubit.landmarkKey, _landmarkController.text);
    }
  }

  @override
  void dispose() {
    // It's good practice to remove listeners, though for TextEditingController,
    // disposing the controller itself usually handles this.
    _streetController.removeListener(_onStreetChanged);
    _cityController.removeListener(_onCityChanged);
    _pincodeController.removeListener(_onPincodeChanged);
    _landmarkController.removeListener(_onLandmarkChanged);

    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This BlocProvider creates the AddressEntryCubit instance for this widget subtree.
    return BlocProvider(
      create: (_) => AddressEntryCubit(initialData: widget.initialAddressData),
      child: Scaffold(
        appBar: AppBar(
          // AppBar title now needs to access context for BlocBuilder, or cubit instance via Consumer/Builder
          // For simplicity, we'll use a Builder here to get context for context.read
          title: Builder(
            builder: (appBarContext) => BlocBuilder<AddressEntryCubit, BaseFormState>(
              // Accessing cubit via appBarContext.read ensures it's the one from THIS BlocProvider
              bloc: appBarContext.read<AddressEntryCubit>(),
              buildWhen: (previous, current) => previous.fields.isEmpty && current.fields.isNotEmpty,
              builder: (context, state) { // This context is fine too
                // Use context.read here as it's inside the BlocProvider's scope
                final cubit = context.read<AddressEntryCubit>();
                return Text(cubit.initialData != null ? 'Edit Address' : 'Add Address');
              },
            ),
          ),
        ),
        // Use a BlocConsumer that refers to the cubit provided by the BlocProvider above.
        body: BlocConsumer<AddressEntryCubit, BaseFormState>(
          listener: (context, state) {
            // Accessing cubit via context.read is fine here as it's within BlocProvider's scope.
            final cubit = context.read<AddressEntryCubit>();
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(cubit.initialData != null
                        ? 'Address updated successfully!'
                        : 'Address saved successfully!')),
              );
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
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
            // Accessing cubit via context.read is fine here.
            final cubit = context.read<AddressEntryCubit>();
            final List<DropdownItem> stateItemsFromCubit = cubit.stateDropdownItems;

            if (state.fields.isEmpty && !cubit.isClosed) { // Check !cubit.isClosed for safety during hot reload/dispose
              // Cubit might be initializing or fields not ready yet.
              // The cubit's _initializeFields is called in its constructor.
              // So, by the time BlocProvider creates it, fields should be there.
              // This condition might only be true for a very brief moment or if cubit is closed.
              // A null check on a specific field might be more reliable if fields can be empty post-init.
               if (state.fields[AddressEntryCubit.streetKey] == null && !cubit.isClosed) {
                 return const Center(child: CircularProgressIndicator());
               }
            }

            // Update controller text if cubit state changes and differs from controller
            // This creates two-way binding: Controller updates cubit (via listener), Cubit state updates UI (via BlocBuilder/Consumer)
            // And if cubit state is changed by other means, controller should reflect it.
            // Only update if different to avoid cursor jumping and infinite loops.
            if (_streetController.text != (state.fields[AddressEntryCubit.streetKey]?.value?.toString() ?? '')) {
              _streetController.text = state.fields[AddressEntryCubit.streetKey]?.value?.toString() ?? '';
            }
            if (_cityController.text != (state.fields[AddressEntryCubit.cityKey]?.value?.toString() ?? '')) {
              _cityController.text = state.fields[AddressEntryCubit.cityKey]?.value?.toString() ?? '';
            }
            if (_pincodeController.text != (state.fields[AddressEntryCubit.pincodeKey]?.value?.toString() ?? '')) {
              _pincodeController.text = state.fields[AddressEntryCubit.pincodeKey]?.value?.toString() ?? '';
            }
            if (_landmarkController.text != (state.fields[AddressEntryCubit.landmarkKey]?.value?.toString() ?? '')) {
              _landmarkController.text = state.fields[AddressEntryCubit.landmarkKey]?.value?.toString() ?? '';
            }


            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: "Street Address",
                          controller: _streetController, // Use state-managed controller
                          errorText: state.fields[AddressEntryCubit.streetKey]?.error,
                          // onChanged is removed
                          suffixIcon: (state.fields[AddressEntryCubit.streetKey]?.initialValue != null && state.fields[AddressEntryCubit.streetKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: "City",
                          controller: _cityController, // Use state-managed controller
                          errorText: state.fields[AddressEntryCubit.cityKey]?.error,
                          // onChanged is removed
                          suffixIcon: (state.fields[AddressEntryCubit.cityKey]?.initialValue != null && state.fields[AddressEntryCubit.cityKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 16),

                        BlocBuilder<AddressEntryCubit, BaseFormState>(
                          buildWhen: (prev, curr) => prev.fields[AddressEntryCubit.stateKey] != curr.fields[AddressEntryCubit.stateKey] || prev.fields.isEmpty,
                          builder: (context, state) {
                            final int? currentStateId = state.fields[AddressEntryCubit.stateKey]?.value as int?;
                            DropdownItem? selectedState;

                            if (currentStateId != null) {
                              for (final item in stateItemsFromCubit) {
                                if (item.id == currentStateId) {
                                  selectedState = item;
                                  break;
                                }
                              }
                            }

                            return DropdownField(
                              label: "State",
                              value: selectedState,
                              items: stateItemsFromCubit,
                              errorText: state.fields[AddressEntryCubit.stateKey]?.error,
                              onChanged: (DropdownItem? item) {
                                cubit.updateField(AddressEntryCubit.stateKey, item?.id);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: "Pincode",
                          controller: _pincodeController, // Use state-managed controller
                          keyboardType: TextInputType.number,
                          errorText: state.fields[AddressEntryCubit.pincodeKey]?.error,
                          // onChanged is removed
                          suffixIcon: (state.fields[AddressEntryCubit.pincodeKey]?.initialValue != null && state.fields[AddressEntryCubit.pincodeKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: "Landmark (Optional)",
                           controller: _landmarkController, // Use state-managed controller
                          errorText: state.fields[AddressEntryCubit.landmarkKey]?.error,
                          // onChanged is removed
                           suffixIcon: (state.fields[AddressEntryCubit.landmarkKey]?.initialValue != null && state.fields[AddressEntryCubit.landmarkKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: state.isFormValid && !state.isSubmitting
                              ? () => cubit.submitForm(const {})
                              : null,
                          child: Text(cubit.initialData != null ? 'Update' : 'Save'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isSubmitting)
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
