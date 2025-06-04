import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/core/data/drop_down_dm.dart'; // Import DropdownItem

class AddressEntryCubit extends BaseFormCubit {
  static const String streetKey = 'street';
  static const String cityKey = 'city';
  static const String landmarkKey = 'landmark';
  static const String pincodeKey = 'pincode';
  static const String stateKey = 'state'; // This will now store int?

  final AddressData? initialData;

  // 1. Define the static list of DropdownItems for states
  static final List<DropdownItem> _stateItems = [
    const DropdownItem(id: 1, title: 'Massachusetts', subTitle: 'MA'),
    const DropdownItem(id: 2, title: 'New York', subTitle: 'NY'),
    const DropdownItem(id: 3, title: 'California', subTitle: 'CA'),
    const DropdownItem(id: 4, title: 'Texas', subTitle: 'TX'),
    // Add more states as needed, ensuring unique integer IDs and consistency with _stateCodeToIdMap
  ];

  // 2. Create a public getter for this list
  List<DropdownItem> get stateDropdownItems => _stateItems;

  // Mapping from string state codes (like in AddressData) to integer IDs (for DropdownItems)
  // This map should be consistent with _stateItems.
  static const Map<String, int> _stateCodeToIdMap = {
    'MA': 1,
    'NY': 2,
    'CA': 3,
    'TX': 4,
    // If more states are added to _stateItems, update this map too.
  };

  // Optional: Reverse map if needed for submission (int ID to String code)
  // This can be generated from _stateItems if subTitle is the desired code.
  // static final Map<int, String> _idToStateCodeMap = Map.fromEntries(
  //   _stateItems.map((item) => MapEntry(item.id as int, item.subTitle ?? item.title))
  // );


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
        return null;
      },
      stateKey: (value, _) => // value here is now int?
          value == null ? 'State must be selected' : null, // Check for null for int?
      landmarkKey: (value, _) => null, // Optional field
    };
  }

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // Accessing stateKey from 'values' map will give int?
    final int? selectedStateId = values[stateKey] as int?;

    // If AddressData.state needs to be a string for submission to an API,
    // you would map the integer ID back to its string code here.
    // Example using _stateItems:
    String? stateCodeForApi;
    if (selectedStateId != null) {
      try {
        stateCodeForApi = _stateItems.firstWhere((item) => item.id == selectedStateId).subTitle;
      } catch (e) {
        // Handle case where ID might not be found in _stateItems, though unlikely if data is consistent
        print("Warning: State ID $selectedStateId not found in _stateItems during submission. Error: $e");
        stateCodeForApi = null;
      }
    }
    // print('Submitting form with Street: ${values[streetKey]}, State ID: $selectedStateId, Mapped State Code: $stateCodeForApi');

    await Future.delayed(const Duration(seconds: 1));

    print('AddressEntryCubit.submitForm called with (values map from BaseFormCubit): $values. Mapped state code: $stateCodeForApi');
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
