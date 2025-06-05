import 'package:custom_form/core/cubits/base_form/cubit/base_form_cubit.dart';
import 'package:custom_form/core/cubits/base_form/cubit/base_form_state.dart'; // Required for BaseFormFieldState
import 'package:custom_form/core/data/user_model.dart';
import 'profile_form_state.dart'; // This now includes ProfileFieldKeys

class ProfilePageCubit extends BaseFormCubit {
  final User _initialUser; // Store initial user

  ProfilePageCubit(User initialUser)
      : _initialUser = initialUser,
        super() { // BaseFormCubit constructor is parameterless
    // Emit the initial state: user and isEditMode are set, BaseFormState has empty fields.
    emit(ProfileFormState.initial(_initialUser));
    // Now initialize the actual form fields using BaseFormCubit's mechanism
    _initializeFields();
  }

  void _initializeFields() {
    final Map<String, BaseFormFieldState> initialFieldsMap = {
      ProfileFieldKeys.firstName: BaseFormFieldState(value: _initialUser.firstName, initialValue: _initialUser.firstName),
      ProfileFieldKeys.lastName: BaseFormFieldState(value: _initialUser.lastName, initialValue: _initialUser.lastName),
      ProfileFieldKeys.email: BaseFormFieldState(value: _initialUser.email, initialValue: _initialUser.email),
      ProfileFieldKeys.password: BaseFormFieldState(value: _initialUser.password, initialValue: _initialUser.password), // Will be disabled in UI
    };
    // initializeFormFields is from BaseFormCubit. It will emit a new state (ProfileFormState)
    // with the fields map updated, because ProfileFormState.copyWith will be used internally by BaseFormCubit.
    initializeFormFields(initialFieldsMap);
  }

  @override
  Map<String, FieldValidator> get validators => {
        ProfileFieldKeys.firstName: (value, _) {
          if (value == null || value.toString().isEmpty) {
            return 'First name cannot be empty.';
          }
          return null;
        },
        ProfileFieldKeys.lastName: (value, _) {
          if (value == null || value.toString().isEmpty) {
            return 'Last name cannot be empty.';
          }
          return null;
        },
        ProfileFieldKeys.email: (value, _) {
          if (value == null || value.toString().isEmpty) {
            return 'Email cannot be empty.';
          }
          final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegExp.hasMatch(value.toString())) {
            return 'Enter a valid email address.';
          }
          return null;
        },
        // No validator for password as it's not intended to be editable/submitted here
      };

  ProfileFormState get profileState => state as ProfileFormState;

  void toggleEditMode() {
    emit(profileState.copyWith(isEditMode: !profileState.isEditMode));
  }

  @override
  Future<void> submitForm(Map<String, dynamic> values) async {
    // Ensure we are working with the most current state, especially if BaseFormCubit has emitted.
    // However, `values` map from BaseFormCubit's `validateAndSubmit` is the most up-to-date for field values.
    final ProfileFormState currentState = profileState;

    final updatedUser = User(
      firstName: values[ProfileFieldKeys.firstName]?.toString() ?? currentState.user.firstName,
      lastName: values[ProfileFieldKeys.lastName]?.toString() ?? currentState.user.lastName,
      email: values[ProfileFieldKeys.email]?.toString() ?? currentState.user.email,
      password: currentState.user.password, // Password is not updated from form
    );

    emit(currentState.copyWith(
      user: updatedUser,
      isEditMode: false,
      isSubmitting: false, // Handled by BaseFormCubit, but good to be explicit
      isSuccess: true,
      isFailure: false,
      apiError: null, // Clear any previous API error
      fields: { // Update the fields to reflect the submission as new initial values and reset validation state
        ProfileFieldKeys.firstName: BaseFormFieldState(value: updatedUser.firstName, initialValue: updatedUser.firstName, error: null, isValid: true),
        ProfileFieldKeys.lastName: BaseFormFieldState(value: updatedUser.lastName, initialValue: updatedUser.lastName, error: null, isValid: true),
        ProfileFieldKeys.email: BaseFormFieldState(value: updatedUser.email, initialValue: updatedUser.email, error: null, isValid: true),
        ProfileFieldKeys.password: BaseFormFieldState(value: updatedUser.password, initialValue: updatedUser.password, error: null, isValid: true),
      }
    ));
  }
}
