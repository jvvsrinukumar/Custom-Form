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
    if (_initialData == null) return false;
    switch (key) {
      case AddressEntryCubit.streetKey: return _initialData!.address.isNotEmpty;
      case AddressEntryCubit.cityKey: return _initialData!.city.isNotEmpty;
      case AddressEntryCubit.pincodeKey: return _initialData!.zipCode.isNotEmpty;
      case AddressEntryCubit.stateKey: return _initialData!.state.isNotEmpty;
      case AddressEntryCubit.landmarkKey: return _initialData!.landmark?.isNotEmpty ?? false;
      default: return false;
    }
  }

  // Required getter for the cubit's initialData property
  @override
  AddressData? get initialData => _initialData;
}


void main() {
  late MockAddressEntryCubit mockCubit;

  const AddressData sampleAddress = AddressData(
    id: "1",
    address: "123 Test St",
    city: "Testville",
    zipCode: "12345",
    state: "MA", // ID for Massachusetts
    landmark: "Near Test Park",
  );

  // Helper to pump the widget with a given state
  Future<void> pumpPage(WidgetTester tester, BaseFormState state, {AddressData? initialData}) async {
    when(() => mockCubit.state).thenReturn(state);
    // Crucial: when the cubit is created in AddressEntryPage, it might call _initializeFields.
    // The mock needs to handle this or the test setup needs to ensure state is already 'initialized'.
    // For simplicity, we ensure the state passed to pumpPage is already reflective of initialized fields.

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AddressEntryCubit>.value(
          value: mockCubit,
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
      AddressEntryCubit.stateKey: const BaseFormFieldState<String?>(value: null, initialValue: null), // Dropdown value
      AddressEntryCubit.landmarkKey: const BaseFormFieldState(value: '', initialValue: ''),
    },
    isFormValid: false,
    isSubmitting: false,
    isSuccess: false,
    isFailure: false,
  );

  // Initial state for an edit address form (pre-filled)
  BaseFormState getPreFilledState(AddressData data) {
    return BaseFormState(
      fields: {
        AddressEntryCubit.streetKey: BaseFormFieldState(value: data.address, initialValue: data.address),
        AddressEntryCubit.cityKey: BaseFormFieldState(value: data.city, initialValue: data.city),
        AddressEntryCubit.pincodeKey: BaseFormFieldState(value: data.zipCode, initialValue: data.zipCode),
        AddressEntryCubit.stateKey: BaseFormFieldState<String?>(value: data.state, initialValue: data.state),
        AddressEntryCubit.landmarkKey: BaseFormFieldState(value: data.landmark ?? '', initialValue: data.landmark ?? ''),
      },
      isFormValid: true, // Assuming data is valid
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }


  setUp(() {
    // Default mock cubit for 'add' mode
    mockCubit = MockAddressEntryCubit();
    // Stub the stream for BlocBuilder/BlocConsumer
    whenListen(mockCubit, Stream.fromIterable([initialEmptyState]), initialState: initialEmptyState);
  });

  group('AddressEntryPage Widget Tests', () {
    testWidgets('renders correctly for "Add Address" mode (empty form)', (WidgetTester tester) async {
      await pumpPage(tester, initialEmptyState);

      expect(find.text('Add Address'), findsOneWidget); // AppBar title
      expect(find.widgetWithText(AppTextField, 'Street Address'), findsOneWidget);
      expect(find.widgetWithText(AppTextField, 'City'), findsOneWidget);
      expect(find.widgetWithText(DropdownField, 'State'), findsOneWidget);
      expect(find.widgetWithText(AppTextField, 'Pincode'), findsOneWidget);
      expect(find.widgetWithText(AppTextField, 'Landmark (Optional)'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);

      // No edit icons should be visible
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('renders correctly for "Edit Address" mode (pre-filled form)', (WidgetTester tester) async {
      // Setup mock for 'edit' mode
      mockCubit = MockAddressEntryCubit(initialData: sampleAddress);
      final prefilledState = getPreFilledState(sampleAddress);
      whenListen(mockCubit, Stream.fromIterable([prefilledState]), initialState: prefilledState);

      await pumpPage(tester, prefilledState, initialData: sampleAddress);
      await tester.pumpAndSettle(); // Ensure all rebuilds complete

      expect(find.text('Edit Address'), findsOneWidget); // AppBar title
      expect(find.text(sampleAddress.address), findsOneWidget); // Street field pre-filled
      expect(find.text(sampleAddress.city), findsOneWidget);     // City field pre-filled
      // State Dropdown pre-fill check (find selected item's title)
      // AddressEntryPage._states has {id: 'MA', title: 'Massachusetts', subTitle: 'MA'}
      expect(find.text('Massachusetts'), findsOneWidget);
      expect(find.text(sampleAddress.zipCode), findsOneWidget); // Pincode field pre-filled
      expect(find.text(sampleAddress.landmark!), findsOneWidget); // Landmark field pre-filled
      expect(find.widgetWithText(ElevatedButton, 'Update'), findsOneWidget);

      // Edit icons should be visible for fields that had initial data
      // The number of icons depends on how many fields in sampleAddress are non-empty
      // Street, City, Pincode, State (via Dropdown), Landmark = 5 AppTextFields with potential icons
      // DropdownField does not use the suffixIcon logic directly.
      // So, Street, City, Pincode, Landmark = 4 icons.
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
      whenListen(mockCubit, Stream.fromIterable([errorState]), initialState: errorState);
      await pumpPage(tester, errorState);

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
      await tester.pumpAndSettle(); // Wait for dropdown menu to appear

      // Tap the first item ('Massachusetts', ID: 'MA')
      // Note: finding items in a dropdown menu can be tricky.
      // This assumes 'Massachusetts' is visible and tappable.
      await tester.tap(find.text('Massachusetts').last); // .last if multiple instances
      await tester.pumpAndSettle(); // Wait for selection to process

      verify(() => mockCubit.updateField(AddressEntryCubit.stateKey, 'MA')).called(1);
    });

    testWidgets('submit button is disabled when form is invalid or submitting', (WidgetTester tester) async {
      // Form invalid
      await pumpPage(tester, initialEmptyState.copyWith(isFormValid: false));
      ElevatedButton button = tester.widget(find.widgetWithText(ElevatedButton, 'Save'));
      expect(button.onPressed, isNull);

      // Form submitting
      final submittingState = initialEmptyState.copyWith(isFormValid: true, isSubmitting: true);
      whenListen(mockCubit, Stream.fromIterable([submittingState]), initialState: submittingState);
      await pumpPage(tester, submittingState);
      button = tester.widget(find.widgetWithText(ElevatedButton, 'Save'));
      expect(button.onPressed, isNull);
    });

    testWidgets('calls cubit submitForm when submit button is pressed', (WidgetTester tester) async {
      final validState = initialEmptyState.copyWith(isFormValid: true);
      whenListen(mockCubit, Stream.fromIterable([validState]), initialState: validState);
      await pumpPage(tester, validState);

      final button = find.widgetWithText(ElevatedButton, 'Save');
      await tester.tap(button);
      await tester.pump();

      verify(() => mockCubit.submitForm(const {})).called(1);
    });

    testWidgets('shows loading indicator when submitting', (WidgetTester tester) async {
      final submittingState = initialEmptyState.copyWith(isFormValid: true, isSubmitting: true);
      whenListen(mockCubit, Stream.fromIterable([submittingState]), initialState: submittingState);
      await pumpPage(tester, submittingState);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

  });
}
