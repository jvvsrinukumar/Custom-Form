import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/core/data/drop_down_dm.dart';
import 'package:custom_form/ui/address_entry/cubit/address_entry_cubit.dart';
import 'package:custom_form/widgets/app_drop_down.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressEntryPage extends StatelessWidget {
  final AddressData? initialAddressData;

  const AddressEntryPage({super.key, this.initialAddressData});

  // Define the list of states for the dropdown
  static const List<DropdownItem> _states = [
    DropdownItem(id: 1, title: 'Massachusetts', subTitle: 'MA'),
    DropdownItem(id: 2, title: 'New York', subTitle: 'NY'),
    DropdownItem(id: 3, title: 'California', subTitle: 'CA'),
    DropdownItem(id: 4, title: 'Texas', subTitle: 'TX'),
    // Add more states as needed, ensuring unique integer IDs
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressEntryCubit(initialData: initialAddressData),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AddressEntryCubit, BaseFormState>(
            buildWhen: (previous, current) => previous.fields.isEmpty && current.fields.isNotEmpty, // Build only once when fields are initialized
            builder: (context, state) {
              final cubit = context.read<AddressEntryCubit>();
              return Text(cubit.initialData != null ? 'Edit Address' : 'Add Address');
            },
          ),
        ),
        body: BlocConsumer<AddressEntryCubit, BaseFormState>(
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(context.read<AddressEntryCubit>().initialData != null
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
            final cubit = context.read<AddressEntryCubit>();

            if (state.fields.isEmpty) {
              // Cubit is initializing, show a loader or empty container
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Street Field
                        AppTextField(
                          label: "Street Address",
                          controller: TextEditingController(text: state.fields[AddressEntryCubit.streetKey]?.value?.toString() ?? ''),
                          errorText: state.fields[AddressEntryCubit.streetKey]?.error,
                          onChanged: (v) => cubit.updateField(AddressEntryCubit.streetKey, v),
                          suffixIcon: (state.fields[AddressEntryCubit.streetKey]?.initialValue != null && state.fields[AddressEntryCubit.streetKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // City Field
                        AppTextField(
                          label: "City",
                          controller: TextEditingController(text: state.fields[AddressEntryCubit.cityKey]?.value?.toString() ?? ''),
                          errorText: state.fields[AddressEntryCubit.cityKey]?.error,
                          onChanged: (v) => cubit.updateField(AddressEntryCubit.cityKey, v),
                          suffixIcon: (state.fields[AddressEntryCubit.cityKey]?.initialValue != null && state.fields[AddressEntryCubit.cityKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // State Dropdown
                        BlocBuilder<AddressEntryCubit, BaseFormState>(
                          // Build when stateKey field changes OR when fields are first initialized
                          buildWhen: (prev, curr) => prev.fields[AddressEntryCubit.stateKey] != curr.fields[AddressEntryCubit.stateKey] || prev.fields.isEmpty,
                          builder: (context, state) {
                            final int? currentStateId = state.fields[AddressEntryCubit.stateKey]?.value as int?;
                            DropdownItem? selectedState;
                            if (currentStateId != null) {
                                selectedState = _states.firstWhere((item) => item.id == currentStateId, orElse: () {
                                  // Optional: handle case where ID might not be in _states
                                  // This could happen if initialData.state (string) couldn't be mapped to an int ID
                                  // or if the int ID from cubit isn't in AddressEntryPage._states.
                                  // print("Warning: State ID $currentStateId not found in _states list.");
                                  return null;
                                });
                            }

                            return DropdownField(
                              label: "State",
                              value: selectedState, // This is a DropdownItem?
                              items: _states,
                              errorText: state.fields[AddressEntryCubit.stateKey]?.error,
                              onChanged: (DropdownItem? item) {
                                // item?.id is already an int, cubit expects int?
                                cubit.updateField(AddressEntryCubit.stateKey, item?.id);
                              },
                              // Suffix icon logic for DropdownField remains as previously discussed (not directly supported like AppTextField)
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Pincode Field
                        AppTextField(
                          label: "Pincode",
                          controller: TextEditingController(text: state.fields[AddressEntryCubit.pincodeKey]?.value?.toString() ?? ''),
                          keyboardType: TextInputType.number,
                          errorText: state.fields[AddressEntryCubit.pincodeKey]?.error,
                          onChanged: (v) => cubit.updateField(AddressEntryCubit.pincodeKey, v),
                          suffixIcon: (state.fields[AddressEntryCubit.pincodeKey]?.initialValue != null && state.fields[AddressEntryCubit.pincodeKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Landmark Field (Optional)
                        AppTextField(
                          label: "Landmark (Optional)",
                           controller: TextEditingController(text: state.fields[AddressEntryCubit.landmarkKey]?.value?.toString() ?? ''),
                          errorText: state.fields[AddressEntryCubit.landmarkKey]?.error,
                          onChanged: (v) => cubit.updateField(AddressEntryCubit.landmarkKey, v),
                           suffixIcon: (state.fields[AddressEntryCubit.landmarkKey]?.initialValue != null && state.fields[AddressEntryCubit.landmarkKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        ElevatedButton(
                          onPressed: state.isFormValid && !state.isSubmitting
                              ? () => cubit.submitForm(const {}) // Pass empty map or actual values if needed by submitForm
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
