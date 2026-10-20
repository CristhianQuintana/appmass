import '../../../core/errors/app_failure.dart';
import '../domain/auth_identity.dart';
import '../domain/login_validator.dart';
import '../domain/session_status.dart';

class SessionState {
  const SessionState({
    required this.status,
    this.identity,
    this.isSubmitting = false,
    this.failure,
    this.validation = LoginValidation.valid,
    this.resetMessage,
  });

  final SessionStatus status;
  final AuthIdentity? identity;
  final bool isSubmitting;
  final AppFailure? failure;
  final LoginValidation validation;
  final String? resetMessage;

  SessionState copyWith({
    SessionStatus? status,
    AuthIdentity? identity,
    bool clearIdentity = false,
    bool? isSubmitting,
    AppFailure? failure,
    bool clearFailure = false,
    LoginValidation? validation,
    String? resetMessage,
    bool clearResetMessage = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      identity: clearIdentity ? null : identity ?? this.identity,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : failure ?? this.failure,
      validation: validation ?? this.validation,
      resetMessage: clearResetMessage
          ? null
          : resetMessage ?? this.resetMessage,
    );
  }
}
