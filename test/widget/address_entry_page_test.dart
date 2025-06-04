import 'package:bloc_test/bloc_test.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/core/data/drop_down_dm.dart';
import 'package:custom_form/ui/address_entry/cubit/address_entry_cubit.dart';
import 'package:custom_form/ui/address_entry/address_entry_page.dart';
import 'package:custom_form/widgets/app_drop_down.dart';
import 'package:custom_form/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart'; // For mocking cubit

// Mock Cubit
class MockAddressEntryCubit extends MockBloc<BaseFormEvent, BaseFormState> implements AddressEntryCubit {
  // Implement fieldHadInitialValue for the mock
  // Store initial data if provided to constructor to mimic real cubit for this method
  final AddressData? _initialData;
  MockAddressEntryCubit({AddressData? initialData}) : _initialData = initialData;

  @override
  bool fieldHadInitialValue(String key) {
    // This method was removed from the actual cubit. UI now relies on state.fields[key].initialValue.
    // This mock implementation is kept just in case any test was directly calling it on the mock,
    // but ideally, tests should reflect the actual cubit's interface.
    if (_initialData == null) return false;
    switch (key) {
      case AddressEntryCubit.streetKey: return _initialData!.address.isNotEmpty;
      case AddressEntryCubit.cityKey: return _initialData!.city.isNotEmpty;
      case AddressEntryCubit.pincodeKey: return _initialData!.zipCode.isNotEmpty;
      // For stateKey, initialData.state is a String code. The cubit now maps this to an int ID.
      // This mock's fieldHadInitialValue for stateKey would be more complex if it needed to mimic that.
      // Given it's unused by UI, this can be simplified or removed.
      case AddressEntryCubit.stateKey:
        // Check if the original string state code was present.
        return _initialData!.state.isNotEmpty;
      case AddressEntryCubit.landmarkKey: return _initialData!.landmark?.isNotEmpty ?? false;
      default: return false;
    }
  }

  // Required getter for the cubit's initialData property
  @override
  AddressData? get initialData => _initialData;

  // ADD THIS GETTER:
  @override
  List<DropdownItem> get stateDropdownItems => const [
        DropdownItem(id: 1, title: 'Massachusetts', subTitle: 'MA'),
        DropdownItem(id: 2, title: 'New York', subTitle: 'NY'),
        DropdownItem(id: 3, title: 'California', subTitle: 'CA'),
        DropdownItem(id: 4, title: 'Texas', subTitle: 'TX'),
      ];
}


void main() {
  late MockAddressEntryCubit mockCubit;

  // sampleAddress.state is "MA" (String)
  const AddressData sampleAddress = AddressData(
    id: "1",
    address: "123 Test St",
    city: "Testville",
    zipCode: "12345",
    state: "MA",
    landmark: "Near Test Park",
  );
  // Corresponding integer ID for "MA" based on the new stateDropdownItems
  const int sampleAddressStateId = 1;

  // Helper to pump the widget with a given state
  Future<void> pumpPage(WidgetTester tester, BaseFormState state, {AddressData? initialData}) async {
    // Ensure the mockCubit instance used in when() is the same one provided to BlocProvider.
    // This is typically handled by setUp creating mockCubit before each test.
    when(() => mockCubit.state).thenReturn(state);
    when(() => mockCubit.stateDropdownItems).thenReturn(const [ // Ensure getter is stubbed
        DropdownItem(id: 1, title: 'Massachusetts', subTitle: 'MA'),
        DropdownItem(id: 2, title: 'New York', subTitle: 'NY'),
        DropdownItem(id: 3, title: 'California', subTitle: 'CA'),
        DropdownItem(id: 4, title: 'Texas', subTitle: 'TX'),
    ]);


    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AddressEntryCubit>.value(
          value: mockCubit, // Use the mockCubit from setUp
          child: AddressEntryPage(initialAddressData: initialData),
        ),
      ),
    );
  }

  // Initial state for a new address form (empty)
  final initialEmptyState = BaseFormState(
    fields: {
      AddressEntryCubit.streetKey: const BaseFormFieldState(value: '', initialValue: ''),
      AddressEntryCubit.cityKey: const BaseFormFieldState(value: '', initialValue: ''),
      AddressEntryCubit.pincodeKey: const BaseFormFieldState(value: '', initialValue: ''),
      AddressEntryCubit.stateKey: const BaseFormFieldState(value: null, initialValue: null), // Now int?
      AddressEntryCubit.landmarkKey: const BaseFormFieldState(value: '', initialValue: ''),
    },
    isFormValid: false, // Typically false if required fields are empty
    isSubmitting: false,
    isSuccess: false,
    isFailure: false,
  );

  // Initial state for an edit address form (pre-filled)
  BaseFormState getPreFilledState(AddressData data, int mappedStateId) { // Pass mapped ID
    return BaseFormState(
      fields: {
        AddressEntryCubit.streetKey: BaseFormFieldState(value: data.address, initialValue: data.address),
        AddressEntryCubit.cityKey: BaseFormFieldState(value: data.city, initialValue: data.city),
        AddressEntryCubit.pincodeKey: BaseFormFieldState(value: data.zipCode, initialValue: data.zipCode),
        // Use the mapped integer ID for stateKey's value and initialValue
        AddressEntryCubit.stateKey: BaseFormFieldState(value: mappedStateId, initialValue: mappedStateId),
        AddressEntryCubit.landmarkKey: BaseFormFieldState(value: data.landmark ?? '', initialValue: data.landmark ?? ''),
      },
      isFormValid: true, // Assuming data is valid and all required fields are filled
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }


  setUp(() {
    mockCubit = MockAddressEntryCubit();
    // Common stubs for all tests using this mockCubit
    whenListen(mockCubit, Stream.fromIterable([initialEmptyState]), initialState: initialEmptyState);
    // Stub the stateDropdownItems getter for all tests
    when(() => mockCubit.stateDropdownItems).thenReturn(const [
        DropdownItem(id: 1, title: 'Massachusetts', subTitle: 'MA'),
        DropdownItem(id: 2, title: 'New York', subTitle: 'NY'),
        // Add more if tests interact with other items by text
    ]);
  });

  group('AddressEntryPage Widget Tests', () {
    testWidgets('renders correctly for "Add Address" mode (empty form)', (WidgetTester tester) async {
      // mockCubit is already set up with initialEmptyState by default from setUp
      await pumpPage(tester, initialEmptyState);

      expect(find.text('Add Address'), findsOneWidget);
      // Basic rendering checks
      expect(find.widgetWithText(AppTextField, 'Street Address'), findsOneWidget);
      // ... other fields
      expect(find.widgetWithText(DropdownField, 'State'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('renders correctly for "Edit Address" mode (pre-filled form)', (WidgetTester tester) async {
      mockCubit = MockAddressEntryCubit(initialData: sampleAddress); // Provide initialData to mock
      final prefilledState = getPreFilledState(sampleAddress, sampleAddressStateId); // Use mapped ID

      // Stub the specific mockCubit instance created for this test
      whenListen(mockCubit, Stream.fromIterable([prefilledState]), initialState: prefilledState);
      when(() => mockCubit.stateDropdownItems).thenReturn(const [ // Ensure getter is stubbed for this instance
        DropdownItem(id: 1, title: 'Massachusetts', subTitle: 'MA'),
        DropdownItem(id: 2, title: 'New York', subTitle: 'NY'),
      ]);

      await pumpPage(tester, prefilledState, initialData: sampleAddress);
      await tester.pumpAndSettle();

      expect(find.text('Edit Address'), findsOneWidget);
      expect(find.text(sampleAddress.address), findsOneWidget);
      expect(find.text(sampleAddress.city), findsOneWidget);
      expect(find.text('Massachusetts'), findsOneWidget); // Check for the title of the selected DropdownItem
      expect(find.text(sampleAddress.zipCode), findsOneWidget);
      expect(find.text(sampleAddress.landmark!), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Update'), findsOneWidget);
      // Based on UI logic: (state.fields[KEY]?.initialValue != null && state.fields[KEY]!.initialValue.toString().isNotEmpty)
      // All fields in sampleAddress are non-empty, so 4 AppTextFields should show edit icon.
      expect(find.byIcon(Icons.edit), findsNWidgets(4));
    });

    testWidgets('shows error messages when fields are invalid', (WidgetTester tester) async {
      final errorState = initialEmptyState.copyWith(
        fields: {
          ...initialEmptyState.fields,
          AddressEntryCubit.streetKey: const BaseFormFieldState(value: '', error: 'Street cannot be empty', initialValue: ''),
        },
        isFormValid: false,
      );
      // Use the mockCubit from setUp, or re-initialize if specific state stream is needed for just this test.
      whenListen(mockCubit, Stream.fromIterable([initialEmptyState, errorState]), initialState: initialEmptyState);
      await pumpPage(tester, errorState); // Pump with the state showing the error

      expect(find.text('Street cannot be empty'), findsOneWidget);
    });

    testWidgets('calls cubit updateField on text input', (WidgetTester tester) async {
      await pumpPage(tester, initialEmptyState);
      final streetField = find.widgetWithText(AppTextField, 'Street Address');
      await tester.enterText(streetField, 'New Street Value');
      await tester.pump();
      verify(() => mockCubit.updateField(AddressEntryCubit.streetKey, 'New Street Value')).called(1);
    });

    testWidgets('calls cubit updateField on dropdown selection', (WidgetTester tester) async {
      await pumpPage(tester, initialEmptyState);
      final dropdown = find.widgetWithText(DropdownField, "State");
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Massachusetts').last);
      await tester.pumpAndSettle();
      verify(() => mockCubit.updateField(AddressEntryCubit.stateKey, 1)).called(1); // ID for Massachusetts is 1
    });

    testWidgets('submit button is disabled when form is invalid or submitting', (WidgetTester tester) async {
      // Form invalid (initialEmptyState is invalid by default)
      await pumpPage(tester, initialEmptyState);
      ElevatedButton button = tester.widget(find.widgetWithText(ElevatedButton, 'Save'));
      expect(button.onPressed, isNull);

      // Form submitting
      final submittingState = initialEmptyState.copyWith(isFormValid: true, isSubmitting: true);
      whenListen(mockCubit, Stream.fromIterable([initialEmptyState, submittingState]), initialState: initialEmptyState);
      await pumpPage(tester, submittingState);
      button = tester.widget(find.widgetWithText(ElevatedButton, 'Save'));
      expect(button.onPressed, isNull);
    });

    testWidgets('calls cubit submitForm when submit button is pressed', (WidgetTester tester) async {
      final validState = getPreFilledState(sampleAddress, sampleAddressStateId).copyWith(isFormValid: true); // Ensure a valid state
      whenListen(mockCubit, Stream.fromIterable([initialEmptyState, validState]), initialState: initialEmptyState);
      await pumpPage(tester, validState);
      final button = find.widgetWithText(ElevatedButton, 'Update'); // Text changes if initialData is present
      await tester.tap(button);
      await tester.pump();
      verify(() => mockCubit.submitForm(any())).called(1); // any() because values map isn't critical here
    });

    testWidgets('shows loading indicator when submitting', (WidgetTester tester) async {
      final submittingState = initialEmptyState.copyWith(isFormValid: true, isSubmitting: true);
      whenListen(mockCubit, Stream.fromIterable([initialEmptyState, submittingState]), initialState: initialEmptyState);
      await pumpPage(tester, submittingState);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

  });
}
