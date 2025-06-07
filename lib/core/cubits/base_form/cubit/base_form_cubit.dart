import 'package:bloc/bloc.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';

typedef FieldValidator = String? Function(
    dynamic value, Map<String, dynamic> allValues);

abstract class BaseFormCubit extends Cubit<BaseFormState> {
  Map<String, FieldValidator> get validators;

  BaseFormCubit() : super(const BaseFormState(fields: {}));

  void initializeFormFields(Map<String, BaseFormFieldState> initialFields) {
    emit(state.copyWith(fields: initialFields));
  }

  Map<String, dynamic> get currentValues =>
      state.fields.map((key, field) => MapEntry(key, field.value));

  void updateField(String name, dynamic value) {
    final currentField = state.fields[name];
    final newFields = {
      ...state.fields,
      name:
          (currentField ?? const BaseFormFieldState(value: '', isValid: false))
              .copyWith(value: value),
    };

    final values = {
      for (var entry in newFields.entries) entry.key: entry.value.value,
    };

    final validator = validators[name];
    final error = validator?.call(newFields[name]!.value, values);
    final isValid = error == null;

    final updatedField = newFields[name]!.copyWith(
      error: error,
      isValid: isValid,
      clearError: isValid,
    );

    emit(state.copyWith(
      fields: {...newFields, name: updatedField},
      isSuccess: false,
      isFailure: false,
    ));
  }

  Future<void> submit() async {
    final values = currentValues;
    final updatedFields = <String, BaseFormFieldState>{};
    bool hasError = false;

    state.fields.forEach((key, field) {
      final validator = validators[key];
      final error = validator?.call(field.value, values);
      final isValid = error == null;
      if (!isValid) hasError = true;
      updatedFields[key] =
          field.copyWith(error: error, isValid: isValid, clearError: isValid);
    });

    if (hasError) {
      emit(state.copyWith(fields: updatedFields, isFailure: true));
      return;
    }

    emit(state.copyWith(
        fields: updatedFields,
        isSubmitting: true,
        isFailure: false,
        isSuccess: false));
    await submitForm(values);
  }

  Future<void> submitForm(Map<String, dynamic> values);
}
