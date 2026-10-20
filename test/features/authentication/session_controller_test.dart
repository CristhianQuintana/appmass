import 'dart:async';

import 'package:app_mass/core/config/app_config.dart';
import 'package:app_mass/core/errors/app_failure.dart';
import 'package:app_mass/core/startup/startup_state.dart';
import 'package:app_mass/features/authentication/application/auth_providers.dart';
import 'package:app_mass/features/authentication/application/session_controller.dart';
import 'package:app_mass/features/authentication/domain/auth_identity.dart';
import 'package:app_mass/features/authentication/domain/login_validator.dart';
import 'package:app_mass/features/authentication/domain/password_reset_outcome.dart';
import 'package:app_mass/features/authentication/domain/session_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() {
    auth = FakeAuthRepository();
  });

  tearDown(() async {
    await auth.dispose();
  });

  test('no envía credenciales incompletas', () async {
    final container = _container(auth);
    addTearDown(container.dispose);
    await _listen(container);

    await container
        .read(sessionControllerProvider.notifier)
        .signIn(email: '', password: '');

    final state = container.read(sessionControllerProvider);
    expect(auth.signInCalls, 0);
    expect(state.validation.email, LoginFieldError.required);
    expect(state.status, SessionStatus.signedOut);
  });

  test('credenciales rechazadas no abren sesión', () async {
    auth.signInError = const InvalidCredentialsFailure();
    final container = _container(auth);
    addTearDown(container.dispose);
    await _listen(container);

    await container
        .read(sessionControllerProvider.notifier)
        .signIn(email: 'ana@example.com', password: 'password1');

    final state = container.read(sessionControllerProvider);
    expect(state.status, SessionStatus.signedOut);
    expect(state.failure, isA<InvalidCredentialsFailure>());
    expect(state.failure!.userMessage, isNot(contains('ana@example.com')));
  });

  test('un fallo de red no se presenta como acceso concedido', () async {
    auth.signInError = const NetworkFailure();
    final container = _container(auth);
    addTearDown(container.dispose);
    await _listen(container);

    await container
        .read(sessionControllerProvider.notifier)
        .signIn(email: 'ana@example.com', password: 'password1');

    expect(
      container.read(sessionControllerProvider).failure,
      isA<NetworkFailure>(),
    );
    expect(
      container.read(sessionControllerProvider).status,
      SessionStatus.signedOut,
    );
  });

  test('ignora un segundo envío mientras el primero sigue en curso', () async {
    auth.signInGate = Completer<void>();
    final container = _container(auth);
    addTearDown(container.dispose);
    await _listen(container);
    final notifier = container.read(sessionControllerProvider.notifier);

    final first = notifier.signIn(
      email: 'ana@example.com',
      password: 'password1',
    );
    final second = notifier.signIn(
      email: 'ana@example.com',
      password: 'password1',
    );

    expect(auth.signInCalls, 1);
    expect(container.read(sessionControllerProvider).isSubmitting, isTrue);
    auth.signInGate!.complete();
    await first;
    await second;
    await _flush();
    expect(
      container.read(sessionControllerProvider).status,
      SessionStatus.signedIn,
    );
  });

  test('cerrar sesión deja de exponer la identidad anterior', () async {
    auth.current = const AuthIdentity(id: 'user-1', email: 'ana@example.com');
    final container = _container(auth);
    addTearDown(container.dispose);
    await _listen(container);
    expect(
      container.read(sessionControllerProvider).status,
      SessionStatus.signedIn,
    );

    await container.read(sessionControllerProvider.notifier).signOut();
    await _flush();

    final state = container.read(sessionControllerProvider);
    expect(state.status, SessionStatus.signedOut);
    expect(state.identity, isNull);
    expect(auth.signOutCalls, 1);
  });

  test('la recuperación aceptada no confirma que la cuenta exista', () async {
    auth.resetOutcome = PasswordResetOutcome.accepted;
    final container = _container(auth);
    addTearDown(container.dispose);
    await _listen(container);

    await container
        .read(sessionControllerProvider.notifier)
        .requestPasswordReset('ana@example.com');

    final state = container.read(sessionControllerProvider);
    expect(state.resetMessage, isNotNull);
    expect(state.resetMessage, isNot(contains('existe')));
    expect(state.failure, isNull);
    expect(auth.resetEmails, ['ana@example.com']);
  });
}

ProviderContainer _container(FakeAuthRepository auth) {
  return ProviderContainer(
    overrides: [
      startupProvider.overrideWithValue(
        const StartupState(
          config: AppConfig(
            supabaseUrl: 'https://example.supabase.co',
            supabaseAnonKey: 'sb_publishable_test',
          ),
          supabaseInitialized: true,
        ),
      ),
      authRepositoryProvider.overrideWithValue(auth),
    ],
  );
}

Future<void> _listen(ProviderContainer container) async {
  container.listen(sessionControllerProvider, (_, _) {});
  await _flush();
}

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
