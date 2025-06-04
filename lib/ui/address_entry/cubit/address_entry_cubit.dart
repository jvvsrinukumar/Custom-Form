import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
// No longer need DropdownItem here directly for state value, as we store int ID.

class AddressEntryCubit extends BaseFormCubit {
  static const String streetKey = 'street';
  static const String cityKey = 'city';
  static const String landmarkKey = 'landmark';
  static const String pincodeKey = 'pincode';
  static const String stateKey = 'state'; // This will now store int?

  final AddressData? initialData;

  // Mapping from string state codes (like in AddressData) to integer IDs (for DropdownItems)
  static const Map<String, int> _stateCodeToIdMap = {
    'MA': 1,
    'NY': 2,
    'CA': 3,
    'TX': 4,
    // Add other states from AddressEntryPage._states if necessary
    // Ensure this map is consistent with AddressEntryPage._states
  };

  // Optional: Reverse map if needed for submission (int ID to String code)
  // static final Map<int, String> _idToStateCodeMap =
  //   Map.fromEntries(_stateCodeToIdMap.entries.map((e) => MapEntry(e.value, e.key)));


  AddressEntryCubit({this.initialData}) : super() { // Call no-arg constructor of BaseFormCubit
    _initializeFields();
  }

  void _initializeFields() {
    int? initialSelectedStateId;
    if (initialData?.state != null && initialData!.state.isNotEmpty) {
      initialSelectedStateId = _stateCodeToIdMap[initialData!.state.toUpperCase()];
    }

    // Prepare a map of BaseFormFieldState for initializeFormFields
    final Map<String, BaseFormFieldState> initialFieldsMap = {
      streetKey: BaseFormFieldState(value: initialData?.address ?? '', initialValue: initialData?.address ?? ''),
      cityKey: BaseFormFieldState(value: initialData?.city ?? '', initialValue: initialData?.city ?? ''),
      landmarkKey: BaseFormFieldState(value: initialData?.landmark ?? '', initialValue: initialData?.landmark ?? ''),
      pincodeKey: BaseFormFieldState(value: initialData?.zipCode ?? '', initialValue: initialData?.zipCode ?? ''),
      stateKey: BaseFormFieldState(value: initialSelectedStateId, initialValue: initialSelectedStateId), // Store int?
    };

    initializeFormFields(initialFieldsMap);

    // The setFieldInitialValue calls from the previous version are now handled by
    // setting initialValue directly in BaseFormFieldState instances above.
    // BaseFormCubit's initializeFormFields sets these up.
    // If specific logic from setFieldInitialValue (like ensuring value is also set if null)
    // is still needed beyond what initializeFormFields does, it would need to be re-evaluated.
    // However, BaseFormFieldState now takes initialValue, and BaseFormCubit's setFieldInitialValue
    // was primarily for cases where initialValue was not part of BaseFormFieldState.
  }

  @override
  Map<String, FieldValidator> get validators {
    return {
      streetKey: (value, _) =>
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
      stateKey: (value, _) => // value here is now int?
          value == null ? 'State must be selected' : null, // Check for null for int?
      landmarkKey: (value, _) => null, // Optional field
    };
  }

  // fieldHadInitialValue and _getInitialValueForKey methods are removed.
  // UI/tests can rely on cubit.state.fields[key]?.initialValue directly.

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // Accessing stateKey from 'values' map will give int?
    // final int? selectedStateId = values[stateKey] as int?;

    // If AddressData.state needs to be a string for submission to an API,
    // you would map the integer ID back to its string code here.
    // Example:
    // final String? stateCodeForApi;
    // if (selectedStateId != null) {
    //   // Create or use a reverse map: _idToStateCodeMap
    //   // stateCodeForApi = _idToStateCodeMap[selectedStateId];
    // } else {
    //   stateCodeForApi = null;
    // }
    // print('Submitting form with Street: ${values[streetKey]}, State ID: $selectedStateId, Mapped State Code: $stateCodeForApi');

    // Simulate API call
    // BaseFormCubit's submit() method already sets isSubmitting to true and clears previous errors.
    await Future.delayed(const Duration(seconds: 1));

    // For now, just print and simulate success
    print('AddressEntryCubit.submitForm called with (values map from BaseFormCubit): $values');
    // Example: how the original data might be structured if needed for API
    // AddressData dataToSubmit = AddressData(
    //   id: initialData?.id ?? '', // or generate new ID
    //   address: values[streetKey] as String,
    //   city: values[cityKey] as String,
    //   zipCode: values[pincodeKey] as String,
    //   state: stateCodeForApi ?? '', // Use the mapped string state code
    //   landmark: values[landmarkKey] as String?,
    // );
    // print('Data to submit to API: ${dataToSubmit}');

    emit(state.copyWith(isSubmitting: false, isSuccess: true, apiError: null));
  }
}
