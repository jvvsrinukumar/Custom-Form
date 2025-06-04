import 'package:bloc/bloc.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';

typedef FieldValidator = String? Function(
    dynamic value, Map<String, dynamic> allValues);

abstract class BaseFormCubit extends Cubit<BaseFormState> {
  // Validators should be provided by the concrete implementation.
  Map<String, FieldValidator> get validators;

  BaseFormCubit() : super(const BaseFormState(fields: {}));

  void initializeFormFields(Map<String, BaseFormFieldState> initialFields) {
    emit(state.copyWith(fields: initialFields));
  }

  // Method to explicitly set/track an initial value for a field.
  // This is useful if the page is loaded with pre-existing data.
  // It also sets the field's current value to initialValue if value is currently null.
  void setFieldInitialValue(String key, dynamic initialValue) {
    if (state.fields.containsKey(key)) {
      final currentField = state.fields[key]!;
      // Ensure the value of the field is also set to the initialValue,
      // especially if it was previously null or uninitialized.
      dynamic newValue = currentField.value ?? initialValue;

      emit(state.copyWith(fields: {
        ...state.fields,
        key: currentField.copyWith(
          initialValue: initialValue,
          value: newValue, // Ensure current value is also set
          isValid: currentField.isValid, // Preserve existing validity
        ),
      }));
    } else {
      // If the field doesn't exist, create it.
      // This might happen if setFieldInitialValue is called before full initialization
      // or for dynamically added fields.
      emit(state.copyWith(fields: {
        ...state.fields,
        key: BaseFormFieldState(value: initialValue, initialValue: initialValue),
      }));
    }
  }

  Map<String, dynamic> get currentValues =>
      state.fields.map((key, field) => MapEntry(key, field.value));

  void updateField(String name, dynamic value) {
    if (!state.fields.containsKey(name)) {
      // Optionally handle or log error if field not initialized
      // For now, let's create it, similar to how setFieldInitialValue handles a new key
      final newField = BaseFormFieldState(value: value);
      emit(state.copyWith(fields: {
        ...state.fields,
        name: newField,
      }));
    }

    final currentField = state.fields[name]!;
    final newFields = {
      ...state.fields,
      // Preserve initialValue when updating the field
      name: currentField.copyWith(value: value, initialValue: currentField.initialValue),
    };

    final allValues = {
      for (var entry in newFields.entries) entry.key: entry.value.value,
    };

    final validator = validators[name];
    // Pass currentField.value instead of value directly to validator if value hasn't been updated in state yet
    final error = validator?.call(newFields[name]!.value, allValues);
    final isValid = error == null;

    final updatedField = newFields[name]!.copyWith(
      error: error,
      isValid: isValid,
      clearError: error == null, // Explicitly clear error if valid
    );

    emit(state.copyWith(
      fields: {...newFields, name: updatedField},
      isSuccess: false,
      isFailure: false,
    ));
  }

  Future<void> submit() async {
    final updatedFields = <String, BaseFormFieldState>{};
    bool hasError = false;

    final values = currentValues; // These are the current values from the state

    // Create a new map for updated fields to avoid modifying state directly during iteration
    final Map<String, BaseFormFieldState> fieldsToUpdate = Map.from(state.fields);

    state.fields.forEach((key, field) {
      final validator = validators[key];
      // Validate against the current value of the field
      final error = validator?.call(field.value, values);
      final isValid = error == null;
      if (!isValid) {
        hasError = true;
      }
      // Update the field in our temporary map
      fieldsToUpdate[key] = field.copyWith(
        error: error,
        isValid: isValid,
        clearError: isValid
      );
    });

    if (hasError) {
      emit(state.copyWith(fields: fieldsToUpdate, isFailure: true));
      return;
    }

    // Emit with potentially updated fields (e.g. errors cleared) before submitting
    emit(state.copyWith(fields: fieldsToUpdate, isSubmitting: true, isFailure: false, isSuccess: false));

    await submitForm(values); // values here are from currentValues before this validation pass
  }

  Future<void> submitForm(Map<String, dynamic> values);
}
