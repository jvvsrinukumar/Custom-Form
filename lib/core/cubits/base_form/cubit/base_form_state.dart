import 'package:equatable/equatable.dart';

class BaseFormFieldState extends Equatable {
  final dynamic value;
  final String? error;
  final bool isValid;
  final dynamic initialValue; // New field

  const BaseFormFieldState({
    required this.value,
    this.error,
    this.isValid = true,
    this.initialValue, // Added to constructor
  });

  BaseFormFieldState copyWith({
    dynamic value,
    String? error,
    bool? isValid,
    dynamic initialValue, // Added to copyWith
    bool clearError = false, // Added for explicit error clearing
  }) {
    return BaseFormFieldState(
      value: value ?? this.value,
      error: clearError ? null : error ?? this.error,
      isValid: isValid ?? this.isValid,
      initialValue: initialValue ?? this.initialValue,
    );
  }

  @override
  List<Object?> get props => [value, error, isValid, initialValue];
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
