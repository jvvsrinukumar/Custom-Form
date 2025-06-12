import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
// Equatable is already imported via BaseFormState if BaseFormState extends/mixes Equatable

// The abstract PhoneNumberState and PhoneNumberInitial are removed as custom states will extend BaseFormState directly.

final class DontDisturb extends BaseFormState {
  final String name;

  const DontDisturb({
    required this.name,
    required Map<String, BaseFormFieldState> fields,
    bool isSubmitting = false,
    // isSuccess is often true for specific outcome states like this,
    // but can be tailored if DND has further steps.
    bool isSuccess = true,
    bool isFailure = false,
    String? apiError,
    bool isKeypadVisible = true, // Or false if DND means keypad should hide
  }) : super(
          fields: fields,
          isSubmitting: isSubmitting,
          isSuccess: isSuccess,
          isFailure: isFailure,
          apiError: apiError,
          isKeypadVisible: isKeypadVisible,
        );

  @override
  List<Object?> get props => [
        name, // Custom property
        fields,
        isSubmitting,
        isSuccess,
        isFailure,
        apiError,
        isKeypadVisible,
      ];

  // It's good practice for custom states to have their own copyWith if they add new properties,
  // or if you want to ensure the return type is specific.
  // However, if BaseFormState.copyWith is sufficient and you only add props, this might be optional.
  // For robustness, let's add one.
  DontDisturb copyWithDontDisturb({ // Renamed to avoid conflict if BaseFormState also has copyWith
    String? name,
    Map<String, BaseFormFieldState>? fields,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? apiError,
    bool? clearApiError,
    bool? isKeypadVisible,
  }) {
    return DontDisturb(
      name: name ?? this.name,
      fields: fields ?? this.fields,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      apiError: clearApiError == true ? null : apiError ?? this.apiError,
      isKeypadVisible: isKeypadVisible ?? this.isKeypadVisible,
    );
  }
}

// Add other custom states that extend BaseFormState here if needed for PhoneNumberCubit.
// For example:
// class PhoneNumberVerificationRequired extends BaseFormState { ... }
