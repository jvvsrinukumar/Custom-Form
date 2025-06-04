import 'package:bloc/bloc.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';

typedef FieldValidator = String? Function(dynamic value);

abstract class BaseFormCubit extends Cubit<BaseFormState> {
  final Map<String, FieldValidator> validators;

  BaseFormCubit(Map<String, dynamic> initialValues, {required this.validators})
      : super(BaseFormState(
          fields: {
            for (var entry in initialValues.entries)
              entry.key: BaseFormFieldState(value: entry.value)
          },
        ));

  void updateField(String name, dynamic value) {
    final validator = validators[name];
    final error = validator?.call(value);
    final isValid = error == null;

    final updatedField = state.fields[name]!.copyWith(
      value: value,
      error: error,
      isValid: isValid,
    );

    emit(state.copyWith(
      fields: {...state.fields, name: updatedField},
      isSuccess: false,
      isFailure: false,
    ));
  }

  Future<void> submit() async {
    // Validate all fields
    final updatedFields = <String, BaseFormFieldState>{};
    bool hasError = false;

    state.fields.forEach((key, field) {
      final validator = validators[key];
      final error = validator?.call(field.value);
      final isValid = error == null;
      if (!isValid) hasError = true;
      updatedFields[key] = field.copyWith(error: error, isValid: isValid);
    });

    if (hasError) {
      emit(state.copyWith(fields: updatedFields, isFailure: true));
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      final values = {for (var e in state.fields.entries) e.key: e.value.value};
      await submitForm(values);
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (_) {
      emit(state.copyWith(
          isSubmitting: false, isFailure: true, apiError: "Submission failed"));
    }
  }

  Future<void> submitForm(Map<String, dynamic> values);
}
