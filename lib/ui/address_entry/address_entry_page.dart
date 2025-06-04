import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/core/data/drop_down_dm.dart';
import 'package:custom_form/ui/address_entry/cubit/address_entry_cubit.dart';
import 'package:custom_form/widgets/app_drop_down.dart';
import 'package:custom_form/widgets/app_text_field.dart'; // Now stateful

class AddressEntryPage extends StatelessWidget {
  final AddressData? initialAddressData;

  const AddressEntryPage({super.key, this.initialAddressData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressEntryCubit(initialData: initialAddressData),
      child: Scaffold(
        appBar: AppBar(
          title: Builder(builder: (appBarContext) { // Use appBarContext for reading cubit
            return BlocBuilder<AddressEntryCubit, BaseFormState>(
              bloc: appBarContext.read<AddressEntryCubit>(), // Explicitly pass bloc instance
              buildWhen: (previous, current) => previous.fields.isEmpty && current.fields.isNotEmpty,
              builder: (context, state) { // This context is also fine for reading
                final cubit = context.read<AddressEntryCubit>();
                return Text(cubit.initialData != null ? 'Edit Address' : 'Add Address');
              },
            );
          }),
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
              // Simplified error dialog call for brevity in this structure
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: const Text("Error"),
                        content: Text(state.apiError!),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("OK"))
                        ],
                      ));
            }
          },
          builder: (context, state) {
            final cubit = context.read<AddressEntryCubit>();
            final List<DropdownItem> stateItemsFromCubit = cubit.stateDropdownItems;

            if (state.fields.isEmpty && !cubit.isClosed) {
               if (state.fields[AddressEntryCubit.streetKey] == null && !cubit.isClosed) {
                 return const Center(child: CircularProgressIndicator());
               }
            }

            // Centralized controller sync logic is removed.
            // Individual BlocBuilders handle their respective field's controller sync.

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Street Field
                        BlocBuilder<AddressEntryCubit, BaseFormState>(
                          buildWhen: (previous, current) {
                            if (previous.fields.isEmpty && current.fields.isNotEmpty) return true;
                            return previous.fields[AddressEntryCubit.streetKey] != current.fields[AddressEntryCubit.streetKey];
                          },
                          builder: (context, fieldState) {
                            // _streetController is no longer available here.
                            // AppTextField will use its internal controller.
                            // Wire up value and onChanged.
                            return AppTextField(
                              label: "Street Address",
                              value: fieldState.fields[AddressEntryCubit.streetKey]?.value?.toString() ?? '',
                              onChanged: (v) => cubit.updateField(AddressEntryCubit.streetKey, v),
                              errorText: fieldState.fields[AddressEntryCubit.streetKey]?.error,
                              suffixIcon: (fieldState.fields[AddressEntryCubit.streetKey]?.initialValue != null &&
                                           fieldState.fields[AddressEntryCubit.streetKey]!.initialValue.toString().isNotEmpty)
                                  ? const Icon(Icons.edit, size: 20)
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // City Field
                        BlocBuilder<AddressEntryCubit, BaseFormState>(
                           buildWhen: (previous, current) {
                            if (previous.fields.isEmpty && current.fields.isNotEmpty) return true;
                            return previous.fields[AddressEntryCubit.cityKey] != current.fields[AddressEntryCubit.cityKey];
                          },
                          builder: (context, fieldState) {
                            return AppTextField(
                              label: "City",
                              value: fieldState.fields[AddressEntryCubit.cityKey]?.value?.toString() ?? '',
                              onChanged: (v) => cubit.updateField(AddressEntryCubit.cityKey, v),
                              errorText: fieldState.fields[AddressEntryCubit.cityKey]?.error,
                              suffixIcon: (fieldState.fields[AddressEntryCubit.cityKey]?.initialValue != null &&
                                           fieldState.fields[AddressEntryCubit.cityKey]!.initialValue.toString().isNotEmpty)
                                  ? const Icon(Icons.edit, size: 20)
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // State Dropdown
                        BlocBuilder<AddressEntryCubit, BaseFormState>(
                          buildWhen: (prev, curr) => prev.fields[AddressEntryCubit.stateKey] != curr.fields[AddressEntryCubit.stateKey] || prev.fields.isEmpty,
                          builder: (context, fieldState) {
                            final int? currentStateId = fieldState.fields[AddressEntryCubit.stateKey]?.value as int?;
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
                              errorText: fieldState.fields[AddressEntryCubit.stateKey]?.error,
                              onChanged: (DropdownItem? item) {
                                cubit.updateField(AddressEntryCubit.stateKey, item?.id);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Pincode Field
                        BlocBuilder<AddressEntryCubit, BaseFormState>(
                          buildWhen: (previous, current) {
                            if (previous.fields.isEmpty && current.fields.isNotEmpty) return true;
                            return previous.fields[AddressEntryCubit.pincodeKey] != current.fields[AddressEntryCubit.pincodeKey];
                          },
                          builder: (context, fieldState) {
                            return AppTextField(
                              label: "Pincode",
                              keyboardType: TextInputType.number,
                              value: fieldState.fields[AddressEntryCubit.pincodeKey]?.value?.toString() ?? '',
                              onChanged: (v) => cubit.updateField(AddressEntryCubit.pincodeKey, v),
                              errorText: fieldState.fields[AddressEntryCubit.pincodeKey]?.error,
                              suffixIcon: (fieldState.fields[AddressEntryCubit.pincodeKey]?.initialValue != null &&
                                           fieldState.fields[AddressEntryCubit.pincodeKey]!.initialValue.toString().isNotEmpty)
                                  ? const Icon(Icons.edit, size: 20)
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Landmark Field
                        BlocBuilder<AddressEntryCubit, BaseFormState>(
                           buildWhen: (previous, current) {
                            if (previous.fields.isEmpty && current.fields.isNotEmpty) return true;
                            return previous.fields[AddressEntryCubit.landmarkKey] != current.fields[AddressEntryCubit.landmarkKey];
                          },
                          builder: (context, fieldState) {
                            return AppTextField(
                              label: "Landmark (Optional)",
                              value: fieldState.fields[AddressEntryCubit.landmarkKey]?.value?.toString() ?? '',
                              onChanged: (v) => cubit.updateField(AddressEntryCubit.landmarkKey, v),
                              errorText: fieldState.fields[AddressEntryCubit.landmarkKey]?.error,
                              suffixIcon: (fieldState.fields[AddressEntryCubit.landmarkKey]?.initialValue != null &&
                                           fieldState.fields[AddressEntryCubit.landmarkKey]!.initialValue.toString().isNotEmpty)
                                  ? const Icon(Icons.edit, size: 20)
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        BlocBuilder<AddressEntryCubit, BaseFormState>(
                          buildWhen: (prev, curr) => prev.isFormValid != curr.isFormValid || prev.isSubmitting != curr.isSubmitting,
                          builder: (context, buttonState) { // Changed state variable name to avoid conflict
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: buttonState.isFormValid && !buttonState.isSubmitting
                                    ? () => context.read<AddressEntryCubit>().submit() // Use context.read here
                                    : null,
                                child: Text(context.read<AddressEntryCubit>().initialData != null ? 'Update' : 'Save'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isSubmitting) // Uses state from the main BlocConsumer
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
