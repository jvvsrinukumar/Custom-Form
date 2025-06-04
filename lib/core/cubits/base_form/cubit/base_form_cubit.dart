import 'package:bloc/bloc.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';

typedef FieldValidator = String? Function(
    dynamic value, Map<String, dynamic> allValues);

abstract class BaseFormCubit extends Cubit<BaseFormState> {
  final Map<String, FieldValidator> validators;

  BaseFormCubit(Map<String, dynamic> initialValues, {required this.validators})
      : super(BaseFormState(
          fields: {
            for (var entry in initialValues.entries)
              entry.key: BaseFormFieldState(value: entry.value)
          },
        ));

  Map<String, dynamic> get currentValues =>
      state.fields.map((key, field) => MapEntry(key, field.value));

  void updateField(String name, dynamic value) {
    final newFields = {
      ...state.fields,
      name: state.fields[name]!.copyWith(value: value),
    };

    final allValues = {
      for (var entry in newFields.entries) entry.key: entry.value.value,
    };

    final validator = validators[name];
    final error = validator?.call(value, allValues);
    final isValid = error == null;

    final updatedField = newFields[name]!.copyWith(
      error: error,
      isValid: isValid,
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

    final values = currentValues;

    state.fields.forEach((key, field) {
      final validator = validators[key];
      final error = validator?.call(field.value, values);
      final isValid = error == null;
      if (!isValid) hasError = true;

      updatedFields[key] = field.copyWith(error: error, isValid: isValid);
    });

    if (hasError) {
      emit(state.copyWith(fields: updatedFields, isFailure: true));
      return;
    }

    emit(state.copyWith(fields: updatedFields, isSubmitting: true));

    await submitForm(values);
  }

  Future<void> submitForm(Map<String, dynamic> values);
}
