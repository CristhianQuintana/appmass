import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../simulation/demo_mode.dart';
import '../domain/login_validator.dart';
import '../domain/password_reset_outcome.dart';
import '../domain/session_status.dart';
import 'auth_providers.dart';
import 'session_state.dart';

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  static const _validator = LoginValidator();

  @override
  SessionState build() {
    final startup = ref.watch(startupProvider);
    final demo = ref.watch(demoModeProvider);
    if (!startup.canUseSupabase && !demo) {
      return const SessionState(status: SessionStatus.unconfigured);
    }

    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.watchSession().listen(
      (identity) {
        state = state.copyWith(
          status: identity == null
              ? SessionStatus.signedOut
              : SessionStatus.signedIn,
          identity: identity,
          clearIdentity: identity == null,
          clearFailure: true,
          validation: LoginValidation.valid,
          clearResetMessage: true,
        );
      },
      onError: (Object _, StackTrace _) {
        state = state.copyWith(
          status: SessionStatus.signedOut,
          clearIdentity: true,
          failure: const UnexpectedFailure(),
        );
      },
    );
    ref.onDispose(subscription.cancel);
    return const SessionState(status: SessionStatus.unknown);
  }

  Future<void> signIn({required String email, required String password}) async {
    if (state.isSubmitting) return;
    final validation = _validator.validate(email: email, password: password);
    if (!validation.isValid) {
      state = state.copyWith(
        validation: validation,
        clearFailure: true,
        clearResetMessage: true,
      );
      return;
    }
    if (!_backendReady) {
      state = state.copyWith(
        failure: const ConfigurationFailure(),
        validation: LoginValidation.valid,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      validation: LoginValidation.valid,
      clearResetMessage: true,
    );
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password);
      state = state.copyWith(isSubmitting: false);
    } on AppFailure catch (failure) {
      state = state.copyWith(isSubmitting: false, failure: failure);
    } on Object {
      state = state.copyWith(
        isSubmitting: false,
        failure: const UnexpectedFailure(),
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    if (state.isSubmitting) return;
    final emailError = _validator.validateEmail(email);
    if (emailError != null) {
      state = state.copyWith(
        validation: LoginValidation(email: emailError),
        clearFailure: true,
        clearResetMessage: true,
      );
      return;
    }
    if (!_backendReady) {
      state = state.copyWith(failure: const ConfigurationFailure());
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      validation: LoginValidation.valid,
      clearResetMessage: true,
    );
    try {
      final outcome = await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(email: email.trim());
      state = state.copyWith(
        isSubmitting: false,
        failure: _failureForReset(outcome),
        clearFailure: outcome == PasswordResetOutcome.accepted,
        resetMessage: outcome == PasswordResetOutcome.accepted
            ? 'Si el correo corresponde a una cuenta habilitada, recibirás instrucciones para restablecer el acceso.'
            : null,
      );
    } on Object {
      state = state.copyWith(
        isSubmitting: false,
        failure: const UnexpectedFailure(),
      );
    }
  }

  Future<void> signOut() async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = state.copyWith(isSubmitting: false);
    } on AppFailure catch (failure) {
      state = state.copyWith(isSubmitting: false, failure: failure);
    } on Object {
      state = state.copyWith(
        isSubmitting: false,
        failure: const UnexpectedFailure(),
      );
    }
  }

  bool get _backendReady =>
      ref.read(startupProvider).canUseSupabase || ref.read(demoModeProvider);

  AppFailure? _failureForReset(PasswordResetOutcome outcome) {
    return switch (outcome) {
      PasswordResetOutcome.accepted => null,
      PasswordResetOutcome.network => const NetworkFailure(),
      PasswordResetOutcome.rateLimited => const RateLimitFailure(),
      PasswordResetOutcome.unavailable => const UnexpectedFailure(),
    };
  }
}
