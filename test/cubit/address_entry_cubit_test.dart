import 'package:bloc_test/bloc_test.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
// Assuming DropdownItem is in drop_down_dm.dart and used for state representation if necessary
// import 'package:custom_form/core/data/drop_down_dm.dart';
import 'package:custom_form/ui/address_entry/cubit/address_entry_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressEntryCubit Tests', () {
    const AddressData sampleAddress = AddressData(
      id: "12jdjkdjk",
      address: "123 MAIN STREET",
      city: "Test City",
      zipCode: "02116",
      state: "MA", // State code
      landmark: "Near Central Park",
    );

    // Test initial state without initial data
    blocTest<AddressEntryCubit, BaseFormState>(
      'emits initial state correctly when no initialData is provided',
      build: () => AddressEntryCubit(),
      act: (cubit) => cubit.state, // Trigger initial state if not already done by constructor
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.streetKey]?.value, '');
        expect(state.fields[AddressEntryCubit.cityKey]?.value, '');
        expect(state.fields[AddressEntryCubit.pincodeKey]?.value, '');
        // For stateKey, the value in BaseFormField is expected to be the ID or null
        expect(state.fields[AddressEntryCubit.stateKey]?.value, null);
        expect(state.fields[AddressEntryCubit.landmarkKey]?.value, '');
        expect(state.isFormValid, isFalse); // Initially form should be invalid due to required fields
      },
    );

    // Test initial state with initial data
    blocTest<AddressEntryCubit, BaseFormState>(
      'emits initial state correctly when initialData is provided',
      build: () => AddressEntryCubit(initialData: sampleAddress),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.streetKey]?.value, sampleAddress.address);
        expect(state.fields[AddressEntryCubit.cityKey]?.value, sampleAddress.city);
        expect(state.fields[AddressEntryCubit.pincodeKey]?.value, sampleAddress.zipCode);
        expect(state.fields[AddressEntryCubit.stateKey]?.value, sampleAddress.state);
        expect(state.fields[AddressEntryCubit.landmarkKey]?.value, sampleAddress.landmark);

        // Also check initialValue tracking
        expect(state.fields[AddressEntryCubit.streetKey]?.initialValue, sampleAddress.address);
        expect(cubit.fieldHadInitialValue(AddressEntryCubit.streetKey), isTrue);
        expect(cubit.fieldHadInitialValue(AddressEntryCubit.landmarkKey), isTrue);

        // Form should be valid if all required fields from initialData are valid
        // This depends on the validation logic and the sample data
        // For this sample data, it should be valid.
        expect(state.isFormValid, isTrue);
      },
    );

    // Test field update
    blocTest<AddressEntryCubit, BaseFormState>(
      'updates field and validates form correctly',
      build: () => AddressEntryCubit(),
      act: (cubit) {
        cubit.updateField(AddressEntryCubit.streetKey, 'New Street');
        cubit.updateField(AddressEntryCubit.cityKey, 'New City');
        cubit.updateField(AddressEntryCubit.pincodeKey, '12345');
        cubit.updateField(AddressEntryCubit.stateKey, 'NY'); // Update with a state ID
      },
      // Skip first emit if it's just the empty initial state before updates
      // The number of emits depends on how BaseFormCubit handles updates (one per update or batched)
      // Assuming one emit per updateField that causes validation.
      // The last emit will have all fields updated.
      skip: 0, // Adjust if needed based on BaseFormCubit's behavior
      expect: () => [
        // Intermediate states might be emitted by BaseFormCubit.
        // We are primarily interested in the final state after all updates.
        // This part needs careful checking of BaseFormCubit's emit behavior.
        // For simplicity, let's check the final effect via `verify`.
      ],
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.streetKey]?.value, 'New Street');
        expect(state.fields[AddressEntryCubit.cityKey]?.value, 'New City');
        expect(state.fields[AddressEntryCubit.pincodeKey]?.value, '12345');
        expect(state.fields[AddressEntryCubit.stateKey]?.value, 'NY');
        expect(state.isFormValid, isTrue); // All required fields are now filled
      },
    );

    // Test validation: Street empty
    blocTest<AddressEntryCubit, BaseFormState>(
      'validates streetKey as required',
      build: () => AddressEntryCubit(initialData: sampleAddress), // Start with valid data
      act: (cubit) => cubit.updateField(AddressEntryCubit.streetKey, ''), // Make it invalid
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.streetKey]?.error, 'Street cannot be empty');
        expect(state.isFormValid, isFalse);
      },
    );

    // Test validation: City empty
    blocTest<AddressEntryCubit, BaseFormState>(
      'validates cityKey as required',
      build: () => AddressEntryCubit(initialData: sampleAddress),
      act: (cubit) => cubit.updateField(AddressEntryCubit.cityKey, ''),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.cityKey]?.error, 'City cannot be empty');
        expect(state.isFormValid, isFalse);
      },
    );

    // Test validation: Pincode empty
     blocTest<AddressEntryCubit, BaseFormState>(
      'validates pincodeKey as required',
      build: () => AddressEntryCubit(initialData: sampleAddress),
      act: (cubit) => cubit.updateField(AddressEntryCubit.pincodeKey, ''),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.pincodeKey]?.error, 'Pincode cannot be empty');
        expect(state.isFormValid, isFalse);
      },
    );

    // Test validation: State empty
    blocTest<AddressEntryCubit, BaseFormState>(
      'validates stateKey as required',
      build: () => AddressEntryCubit(initialData: sampleAddress),
      // For dropdowns, value becomes null if cleared or not selected
      act: (cubit) => cubit.updateField(AddressEntryCubit.stateKey, null),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.stateKey]?.error, 'State must be selected');
        expect(state.isFormValid, isFalse);
      },
    );

    // Test fieldHadInitialValue
    test('fieldHadInitialValue works correctly', () {
      final cubitWithData = AddressEntryCubit(initialData: sampleAddress);
      expect(cubitWithData.fieldHadInitialValue(AddressEntryCubit.streetKey), isTrue);
      expect(cubitWithData.fieldHadInitialValue(AddressEntryCubit.landmarkKey), isTrue);

      final cubitWithoutData = AddressEntryCubit();
      // Need to ensure fields are initialized before checking fieldHadInitialValue
      // The cubit's constructor calls _initializeFields which should set up the fields map.
      // If state.fields is empty initially, fieldHadInitialValue might not work as expected until fields are populated.
      // Let's assume fields are initialized by the time fieldHadInitialValue is called.
      expect(cubitWithoutData.fieldHadInitialValue(AddressEntryCubit.streetKey), isFalse);
    });

    // Test submission states
    // Note: BaseFormCubit's submitForm is `Future<void>` and internally manages
    // isSubmitting, isSuccess, isFailure.
    // The AddressEntryCubit's submitForm just has a delay for now.
    blocTest<AddressEntryCubit, BaseFormState>(
      'emits [submitting, success] when submitForm is called and successful',
      build: () {
        // Pre-fill form to be valid for submission
        final cubit = AddressEntryCubit();
        cubit.updateField(AddressEntryCubit.streetKey, '123 Main St');
        cubit.updateField(AddressEntryCubit.cityKey, 'Valid City');
        cubit.updateField(AddressEntryCubit.pincodeKey, '12345');
        cubit.updateField(AddressEntryCubit.stateKey, 'CA');
        return cubit;
      },
      act: (cubit) => cubit.submitForm(const {}), // Pass empty map as per current override
      expect: () => [
        // Expected states:
        // 1. State with isSubmitting = true (form data remains)
        // 2. State with isSubmitting = false, isSuccess = true (form data might be cleared or kept)
        // Exact states depend on BaseFormCubit implementation.
        // We check for these properties.
        isA<BaseFormState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<BaseFormState>()
            .having((s) => s.isSubmitting, 'isSubmitting after', false)
            .having((s) => s.isSuccess, 'isSuccess', true),
      ],
      verify: (cubit) {
        expect(cubit.state.isSubmitting, isFalse);
        expect(cubit.state.isSuccess, isTrue);
      }
    );

    // Add a test for submission failure if BaseFormCubit can simulate that
    // For now, AddressEntryCubit's submitForm always succeeds.
  });
}
