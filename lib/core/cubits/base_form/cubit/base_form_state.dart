import 'package:equatable/equatable.dart';

class BaseFormFieldState extends Equatable {
  final dynamic value;
  final String? error;
  final bool isValid;
  final dynamic initialValue;

  const BaseFormFieldState({
    required this.value,
    this.error,
    this.isValid = false,
    this.initialValue,
  });

  BaseFormFieldState copyWith({
    dynamic value,
    String? error,
    bool? isValid,
    dynamic initialValue,
    bool clearError = false,
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

// --------- HERE IS THE KEY CHANGE ----------
class BaseFormState extends Equatable {
  final Map<String, BaseFormFieldState> fields;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? apiError;
  final bool isKeypadVisible; // <--- ADDED THIS FIELD

  const BaseFormState({
    required this.fields,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.apiError,
    this.isKeypadVisible = true, // <--- DEFAULT VALUE
  });

  bool get isFormValid =>
      fields.isNotEmpty && fields.values.every((field) => field.isValid);

  BaseFormState copyWith({
    Map<String, BaseFormFieldState>? fields,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? apiError,
    bool? clearApiError,
    bool? isKeypadVisible, // <--- ADDED THIS
  }) {
    return BaseFormState(
      fields: fields ?? this.fields,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      apiError: clearApiError == true ? null : apiError ?? this.apiError,
      isKeypadVisible:
          isKeypadVisible ?? this.isKeypadVisible, // <--- ADDED THIS
    );
  }

  @override
  List<Object?> get props => [
        fields,
        isSubmitting,
        isSuccess,
        isFailure,
        apiError,
        isKeypadVisible,
      ];
}
