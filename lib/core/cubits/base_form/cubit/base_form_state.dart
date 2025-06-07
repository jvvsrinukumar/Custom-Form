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
  final bool isKeypadVisible; // Add this
  // Note: isFormValid is a getter, so it's not included as a field

  const BaseFormState({
    required this.fields,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.apiError,
    this.isKeypadVisible = true, // Default to true
  });

  bool get isFormValid => fields.values.every((f) => f.isValid);

  BaseFormState copyWith({
    Map<String, BaseFormFieldState>? fields,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? apiError,
    bool? clearApiError, // Keep existing clearApiError functionality if needed elsewhere, though not in original snippet. For safety, I'll base it on the user's original intent.
    bool? isKeypadVisible, // Add this
  }) {
    return BaseFormState(
      fields: fields ?? this.fields,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      apiError: clearApiError == true ? null : apiError ?? this.apiError, // Retain existing logic for apiError
      isKeypadVisible: isKeypadVisible ?? this.isKeypadVisible, // Add this
    );
  }

  @override
  List<Object?> get props => [
        fields,
        isSubmitting,
        isSuccess,
        isFailure,
        apiError,
        isKeypadVisible, // Add this
        // isFormValid is derived, so not in props directly
      ];
}
