import 'package:bloc_test/bloc_test.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/ui/address_entry/cubit/address_entry_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressEntryCubit Tests', () {
    const AddressData sampleAddress = AddressData(
      id: "12jdjkdjk",
      address: "123 MAIN STREET",
      city: "Test City",
      zipCode: "02116",
      state: "MA", // String state code, e.g., Massachusetts
      landmark: "Near Central Park",
    );

    // Expected mapped ID for "MA" from AddressEntryCubit._stateCodeToIdMap
    // This value must match the one defined in AddressEntryCubit._stateCodeToIdMap
    const int expectedStateIdForMA = 1;
    const int sampleStateIdForNY = 2; // e.g., New York's ID for update tests (must match map in cubit or be a valid ID)

    // Test initial state without initial data
    blocTest<AddressEntryCubit, BaseFormState>(
      'emits initial state correctly when no initialData is provided',
      build: () => AddressEntryCubit(),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.streetKey]?.value, '');
        expect(state.fields[AddressEntryCubit.cityKey]?.value, '');
        expect(state.fields[AddressEntryCubit.pincodeKey]?.value, '');
        expect(state.fields[AddressEntryCubit.stateKey]?.value, isNull); // Expecting int? to be null
        expect(state.fields[AddressEntryCubit.landmarkKey]?.value, '');
        expect(state.isFormValid, isFalse); // Initially form should be invalid due to required fields
      },
    );

    // Test initial state with initial data
    blocTest<AddressEntryCubit, BaseFormState>(
      'emits initial state correctly when initialData is provided, mapping state code to ID',
      build: () => AddressEntryCubit(initialData: sampleAddress),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.streetKey]?.value, sampleAddress.address);
        expect(state.fields[AddressEntryCubit.cityKey]?.value, sampleAddress.city);
        expect(state.fields[AddressEntryCubit.pincodeKey]?.value, sampleAddress.zipCode);
        expect(state.fields[AddressEntryCubit.landmarkKey]?.value, sampleAddress.landmark);

        // Verify stateKey value is the mapped integer ID
        expect(state.fields[AddressEntryCubit.stateKey]?.value, expectedStateIdForMA);
        // Also check initialValue tracking directly from the state
        expect(state.fields[AddressEntryCubit.streetKey]?.initialValue, sampleAddress.address);
        expect(state.fields[AddressEntryCubit.stateKey]?.initialValue, expectedStateIdForMA);
        expect(state.fields[AddressEntryCubit.landmarkKey]?.initialValue, sampleAddress.landmark);

        // Form should be valid if all required fields from initialData are valid
        expect(state.isFormValid, isTrue);
      },
    );

    // Test field update for stateKey
    blocTest<AddressEntryCubit, BaseFormState>(
      'updates stateKey field with integer ID and validates form correctly',
      build: () => AddressEntryCubit(), // Start with empty cubit
      act: (cubit) {
        // Update other required fields to make form valid eventually
        cubit.updateField(AddressEntryCubit.streetKey, 'New Street');
        cubit.updateField(AddressEntryCubit.cityKey, 'New City');
        cubit.updateField(AddressEntryCubit.pincodeKey, '12345');
        cubit.updateField(AddressEntryCubit.stateKey, sampleStateIdForNY); // Update with an integer ID
      },
      // Skipping intermediate states for brevity, verify final state
      skip: 3, // street, city, pincode updates
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.streetKey]?.value, 'New Street');
        expect(state.fields[AddressEntryCubit.cityKey]?.value, 'New City');
        expect(state.fields[AddressEntryCubit.pincodeKey]?.value, '12345');
        expect(state.fields[AddressEntryCubit.stateKey]?.value, sampleStateIdForNY);
        expect(state.isFormValid, isTrue); // Assuming all required fields are filled
      },
    );

    // Test validation: Street empty
    blocTest<AddressEntryCubit, BaseFormState>(
      'validates streetKey as required',
      build: () => AddressEntryCubit(initialData: sampleAddress),
      act: (cubit) => cubit.updateField(AddressEntryCubit.streetKey, ''),
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

    // Test validation: State empty (value is null for int?)
    blocTest<AddressEntryCubit, BaseFormState>(
      'validates stateKey as required (value is null for int?)',
      build: () => AddressEntryCubit(initialData: sampleAddress),
      act: (cubit) => cubit.updateField(AddressEntryCubit.stateKey, null),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.fields[AddressEntryCubit.stateKey]?.error, 'State must be selected');
        expect(state.isFormValid, isFalse);
      },
    );

    // fieldHadInitialValue method was removed.
    // Tests for initial value presence are covered by checking state.fields[key]?.initialValue

    // Test submission states
    blocTest<AddressEntryCubit, BaseFormState>(
      'emits [submitting, success] when submitForm is called and successful (with int state ID)',
      build: () {
        // Pre-fill form to be valid for submission
        final cubit = AddressEntryCubit();
        cubit.updateField(AddressEntryCubit.streetKey, '123 Main St');
        cubit.updateField(AddressEntryCubit.cityKey, 'Valid City');
        cubit.updateField(AddressEntryCubit.pincodeKey, '12345');
        cubit.updateField(AddressEntryCubit.stateKey, expectedStateIdForMA); // Use int ID
        return cubit;
      },
      act: (cubit) => cubit.submitForm(const {}),
      expect: () => [
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
  });
}
