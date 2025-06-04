import 'package:equatable/equatable.dart';

class BaseFormFieldState extends Equatable {
  final dynamic value;
  final String? error;
  final bool isValid;

  const BaseFormFieldState(
      {required this.value, this.error, this.isValid = true});

  BaseFormFieldState copyWith({dynamic value, String? error, bool? isValid}) {
    return BaseFormFieldState(
      value: value ?? this.value,
      error: error,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [value, error, isValid];
}

class BaseFormState extends Equatable {
  final Map<String, BaseFormFieldState> fields;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? apiError;

  const BaseFormState({
    required this.fields,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.apiError,
  });

  bool get isFormValid => fields.values.every((f) => f.isValid);

  BaseFormState copyWith(
      {Map<String, BaseFormFieldState>? fields,
      bool? isSubmitting,
      bool? isSuccess,
      bool? isFailure,
      String? apiError}) {
    return BaseFormState(
      fields: fields ?? this.fields,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      apiError: apiError ?? this.apiError,
    );
  }

  @override
  List<Object?> get props => [fields, isSubmitting, isSuccess, isFailure];
}
