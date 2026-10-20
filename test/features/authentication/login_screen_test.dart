import 'dart:async';

import 'package:app_mass/core/config/app_config.dart';
import 'package:app_mass/core/errors/app_failure.dart';
import 'package:app_mass/core/startup/startup_state.dart';
import 'package:app_mass/features/authentication/application/auth_providers.dart';
import 'package:app_mass/features/authentication/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  testWidgets(
    'muestra el ingreso sin selector de rol ni credenciales precargadas',
    (tester) async {
      final auth = FakeAuthRepository();
      addTearDown(auth.dispose);
      await tester.pumpWidget(_loginApp(auth));
      await tester.pump();

      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.text('Operador'), findsNothing);
      expect(find.text('Transportista'), findsNothing);
      expect(find.text('Supervisor'), findsNothing);
      expect(find.text('ejemplo@mass.pe'), findsNothing);
    },
  );

  testWidgets('valida campos vacíos antes de llamar al servicio', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    addTearDown(auth.dispose);
    await tester.pumpWidget(_loginApp(auth));
    await tester.pump();

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Ingresa el correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa la contraseña.'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('un correo mal formado no sale de la pantalla', (tester) async {
    final auth = FakeAuthRepository();
    addTearDown(auth.dispose);
    await tester.pumpWidget(_loginApp(auth));
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'no-es-correo',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'password1',
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Ingresa un correo electrónico válido.'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('deshabilita el envío repetido mientras autentica', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..signInGate = Completer<void>();
    addTearDown(auth.dispose);
    await tester.pumpWidget(_loginApp(auth));
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'password1',
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('login-submit')),
    );
    expect(button.onPressed, isNull);
    expect(auth.signInCalls, 1);
    auth.signInGate!.complete();
  });

  testWidgets('muestra un error genérico y se puede reintentar', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..signInError = const InvalidCredentialsFailure();
    addTearDown(auth.dispose);
    await tester.pumpWidget(_loginApp(auth));
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'password1',
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(
      find.text('No se pudo iniciar sesión con los datos proporcionados.'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('login-submit')),
    );
    expect(button.onPressed, isNotNull);
  });
}

Widget _loginApp(FakeAuthRepository auth) {
  return ProviderScope(
    overrides: [
      startupProvider.overrideWithValue(_readyStartup),
      authRepositoryProvider.overrideWithValue(auth),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

const _readyStartup = StartupState(
  config: AppConfig(
    supabaseUrl: 'https://example.supabase.co',
    supabaseAnonKey: 'sb_publishable_test',
  ),
  supabaseInitialized: true,
);
