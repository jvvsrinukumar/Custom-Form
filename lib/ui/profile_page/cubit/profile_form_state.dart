import 'package:equatable/equatable.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart';
import 'package:custom_form/core/data/user_model.dart';

// Define field keys for consistency, also usable by Cubit and Widget
class ProfileFieldKeys {
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String email = 'email';
  static const String password = 'password';
}

class ProfileFormState extends BaseFormState {
  final User user;
  final bool isEditMode;

  const ProfileFormState({
    required Map<String, BaseFormFieldState> fields,
    bool isSubmitting = false,
    bool isSuccess = false,
    bool isFailure = false,
    String? apiError,
    required this.user,
    this.isEditMode = false,
  }) : super(
          fields: fields,
          isSubmitting: isSubmitting,
          isSuccess: isSuccess,
          isFailure: isFailure,
          apiError: apiError,
        );

  // Factory to initialize with a user, setting an EMPTY fields map for BaseFormState initially.
  factory ProfileFormState.initial(User initialUser) {
    return ProfileFormState(
      user: initialUser,
      isEditMode: false,
      fields: const {}, // EMPTY fields map initially
      // Explicitly initialize other BaseFormState properties to defaults
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
      apiError: null,
    );
  }

  // Override copyWith to handle both BaseFormState and ProfileFormState properties
  @override
  ProfileFormState copyWith({
    Map<String, BaseFormFieldState>? fields,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? apiError,
    User? user,
    bool? isEditMode,
  }) {
    return ProfileFormState(
      fields: fields ?? this.fields,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      apiError: apiError ?? this.apiError, // Ensure apiError is handled
      user: user ?? this.user,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  @override
  List<Object?> get props => [
        fields,
        isSubmitting,
        isSuccess,
        isFailure,
        apiError,
        user,
        isEditMode,
      ];
}
