import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/core/data/drop_down_dm.dart'; // For DropdownItem if needed for state value

class AddressEntryCubit extends BaseFormCubit {
  static const String streetKey = 'street';
  static const String cityKey = 'city';
  static const String landmarkKey = 'landmark';
  static const String pincodeKey = 'pincode';
  static const String stateKey = 'state';

  final AddressData? initialData;

  AddressEntryCubit({this.initialData}) {
    _initializeFields();
  }

  void _initializeFields() {
    // Initial values map
    final Map<String, dynamic> initialValues = {
      streetKey: initialData?.address ?? '',
      cityKey: initialData?.city ?? '',
      landmarkKey: initialData?.landmark ?? '',
      pincodeKey: initialData?.zipCode ?? '',
      // For the state dropdown, we'll store the DropdownItem's ID (e.g., "MA")
      // The UI will need to map this ID back to a DropdownItem object.
      stateKey: initialData?.state,
    };

    // Initialize fields using BaseFormCubit's method
    // Pass both value and initialValue at the point of first initialization.
    initializeFormFields(Map.fromEntries(initialValues.entries.map(
      (entry) => MapEntry(entry.key, BaseFormFieldState(value: entry.value, initialValue: entry.value)),
    )));

    // If initialData is present, call setFieldInitialValue to ensure initialValue is formally set
    // and value is updated if it was null. This might seem redundant if initializeFormFields
    // already sets initialValue, but setFieldInitialValue has specific logic for this.
    // Alternatively, the logic in setFieldInitialValue could be merged into initializeFormFields
    // or this block could be refined if BaseFormFieldState is always constructed with initialValue above.
    // For now, keeping it ensures the initial values are processed as intended by setFieldInitialValue.
    if (initialData != null) {
        // Note: initialValues map already incorporates initialData.
        // The setFieldInitialValue calls below will re-apply these, ensuring the
        // 'initialValue' property within BaseFormFieldState is correctly set,
        // and also aligning current field 'value' if it was null.
        setFieldInitialValue(streetKey, initialValues[streetKey]);
        setFieldInitialValue(cityKey, initialValues[cityKey]);
        setFieldInitialValue(landmarkKey, initialValues[landmarkKey]);
        setFieldInitialValue(pincodeKey, initialValues[pincodeKey]);
        setFieldInitialValue(stateKey, initialValues[stateKey]);
    }
  }

  // Renamed from getValidations and signature changed to match FieldValidator typedef
  Map<String, FieldValidator> _getValidatorsMap() {
    return {
      streetKey: (value, _) => // allValues ('_') is not used here but is part of the signature
          value == null || value.toString().isEmpty ? 'Street cannot be empty' : null,
      cityKey: (value, _) =>
          value == null || value.toString().isEmpty ? 'City cannot be empty' : null,
      pincodeKey: (value, _) {
        if (value == null || value.toString().isEmpty) {
          return 'Pincode cannot be empty';
        }
        // Basic US Zip code validation (5 digits) - can be made more robust
        // if (!RegExp(r'^[0-9]{5}$').hasMatch(value.toString())) {
        //   return 'Enter a valid 5-digit pincode';
        // }
        return null;
      },
      stateKey: (value, _) =>
          value == null || value.toString().isEmpty ? 'State must be selected' : null,
      landmarkKey: (value, _) => null, // Optional field
    };
  }

  @override
  Map<String, FieldValidator> get validators => _getValidatorsMap();

  // Helper to indicate if a field had an initial value from AddressData
  // This can be used by the UI to decide whether to show an edit icon.
  // It should now check the initialValue property of the field in the state.
  bool fieldHadInitialValue(String key) {
    // Check against the 'initialValue' stored in the field's state
    final field = state.fields[key];
    return field?.initialValue != null && field!.initialValue.toString().isNotEmpty;
  }

  // _getInitialValueForKey is no longer strictly needed if fieldHadInitialValue checks state.
  // However, it can be kept if direct access to initialData sources is preferred for some logic.
  // For consistency, relying on state.fields[key].initialValue is better.
  // String? _getInitialValueForKey(String key) {
  //   switch (key) {
  //     case streetKey:
  //       return initialData?.address;
  //     // ... other cases
  //     default:
  //       return null;
  //   }
  // }

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // This method is called by BaseFormCubit after validation
    // 'values' contains the current form values
    emit(state.copyWith(isSubmitting: true)); // Already handled by BaseFormCubit's submit

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Example: Accessing validated values
    // final String street = values[streetKey];
    // final String city = values[cityKey];
    // print('Submitting data: $values');

    // Based on API response:
    // emit(state.copyWith(isSubmitting: false, isSuccess: true));
    // or
    // emit(state.copyWith(isSubmitting: false, isFailure: true, apiError: 'Failed to save address'));

    // For now, just print and simulate success
    print('AddressEntryCubit.submitForm called with: $values');
    emit(state.copyWith(isSubmitting: false, isSuccess: true, apiError: null));
  }
}
