import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/core/data/drop_down_dm.dart'; // Still needed for DropdownItem type
import 'package:custom_form/ui/address_entry/cubit/address_entry_cubit.dart';
import 'package:custom_form/widgets/app_drop_down.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressEntryPage extends StatelessWidget {
  final AddressData? initialAddressData;

  const AddressEntryPage({super.key, this.initialAddressData});

  // REMOVE this static list:
  // static const List<DropdownItem> _states = [
  //   DropdownItem(id: 1, title: 'Massachusetts', subTitle: 'MA'),
  //   DropdownItem(id: 2, title: 'New York', subTitle: 'NY'),
  //   DropdownItem(id: 3, title: 'California', subTitle: 'CA'),
  //   DropdownItem(id: 4, title: 'Texas', subTitle: 'TX'),
  // ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressEntryCubit(initialData: initialAddressData),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AddressEntryCubit, BaseFormState>(
            buildWhen: (previous, current) => previous.fields.isEmpty && current.fields.isNotEmpty,
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
            // Get items from cubit. This needs to be accessed within a context where cubit is available.
            // If stateItemsFromCubit is needed by the BlocBuilder for the dropdown, it should be accessed there,
            // or if it's static/final from the cubit type, it can be AddressEntryCubit._stateItems (if visible)
            // or cubit.stateDropdownItems if it's an instance getter.
            // The provided plan suggests `cubit.stateDropdownItems` which is an instance getter.
            final List<DropdownItem> stateItemsFromCubit = cubit.stateDropdownItems;

            if (state.fields.isEmpty) {
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
                          buildWhen: (prev, curr) => prev.fields[AddressEntryCubit.stateKey] != curr.fields[AddressEntryCubit.stateKey] || prev.fields.isEmpty,
                          builder: (context, state) {
                            // Access cubit again here if needed, or use the one from the outer builder.
                            // For stateItemsFromCubit, it's better to use the one from the outer builder to avoid repeated calls if it were a method.
                            // Since it's a getter, it's fine either way, but for consistency:
                            // final List<DropdownItem> items = context.read<AddressEntryCubit>().stateDropdownItems;

                            final int? currentStateId = state.fields[AddressEntryCubit.stateKey]?.value as int?;
                            DropdownItem? selectedState;

                            if (currentStateId != null) {
                              for (final item in stateItemsFromCubit) { // Use items from cubit (captured from outer scope)
                                if (item.id == currentStateId) {
                                  selectedState = item;
                                  break;
                                }
                              }
                            }

                            return DropdownField(
                              label: "State",
                              value: selectedState,
                              items: stateItemsFromCubit, // Use items from cubit
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
                          controller: TextEditingController(text: state.fields[AddressEntryCubit.pincodeKey]?.value?.toString() ?? ''),
                          keyboardType: TextInputType.number,
                          errorText: state.fields[AddressEntryCubit.pincodeKey]?.error,
                          onChanged: (v) => cubit.updateField(AddressEntryCubit.pincodeKey, v),
                          suffixIcon: (state.fields[AddressEntryCubit.pincodeKey]?.initialValue != null && state.fields[AddressEntryCubit.pincodeKey]!.initialValue.toString().isNotEmpty)
                              ? const Icon(Icons.edit, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 16),
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
