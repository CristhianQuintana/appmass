import 'package:app_mass/app/app.dart';
import 'package:app_mass/core/config/app_config.dart';
import 'package:app_mass/core/errors/app_failure.dart';
import 'package:app_mass/core/startup/startup_state.dart';
import 'package:app_mass/features/authentication/application/auth_providers.dart';
import 'package:app_mass/features/authentication/domain/auth_identity.dart';
import 'package:app_mass/features/profile/application/profile_controller.dart';
import 'package:app_mass/features/profile/domain/staff_profile.dart';
import 'package:app_mass/features/profile/domain/staff_role.dart';
import 'package:app_mass/features/orders/application/order_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_catalog_repository.dart';
import '../support/fake_order_repository.dart';
import '../support/fake_profile_repository.dart';

void main() {
  testWidgets('sin configuración no muestra datos de una sesión', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MassApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No se pudo conectar'), findsOneWidget);
    expect(find.text('Inicia sesión'), findsNothing);
  });

  testWidgets(
    'un operador autenticado ve su inicio y al salir vuelve al ingreso',
    (tester) async {
      final auth = FakeAuthRepository()
        ..current = const AuthIdentity(id: 'user-1', email: 'ana@example.com');
      final profiles = FakeProfileRepository(auth)
        ..profiles['user-1'] = const StaffProfile(
          id: 'user-1',
          fullName: 'Ana Operadora',
          role: StaffRole.operator,
          isActive: true,
        );
      addTearDown(auth.dispose);

      await tester.pumpWidget(_app(auth, profiles));
      await _pumpUntil(tester, find.text('Todavía no hay pedidos.'));

      expect(find.text('Ana Operadora'), findsOneWidget);
      expect(find.text('Operador'), findsWidgets);
      expect(find.text('Administrador'), findsNothing);

      await tester.tap(find.byKey(const Key('home-account')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account-sign-out')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-sign-out')));
      await _pumpUntil(tester, find.text('Inicia sesión'));
      expect(find.text('Ana Operadora'), findsNothing);
    },
  );

  testWidgets('un perfil inactivo no entra al inicio operativo', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..current = const AuthIdentity(id: 'user-2', email: 'luis@example.com');
    final profiles = FakeProfileRepository(auth)
      ..profiles['user-2'] = const StaffProfile(
        id: 'user-2',
        fullName: 'Luis',
        role: StaffRole.administrator,
        isActive: false,
      );
    addTearDown(auth.dispose);

    await tester.pumpWidget(_app(auth, profiles));
    await _pumpUntil(tester, find.text('Acceso no habilitado'));

    expect(find.text('Luis'), findsNothing);
    expect(find.textContaining('supervisarás pedidos'), findsNothing);
  });

  testWidgets(
    'un error al leer el perfil no habilita pantallas privilegiadas',
    (tester) async {
      final auth = FakeAuthRepository()
        ..current = const AuthIdentity(id: 'user-3', email: 'sol@example.com');
      final profiles = FakeProfileRepository(auth)
        ..error = const NetworkFailure();
      addTearDown(auth.dispose);

      await tester.pumpWidget(_app(auth, profiles));
      await _pumpUntil(tester, find.text('Acceso no habilitado'));

      expect(find.textContaining('No hay conexión'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    },
  );
}

Widget _app(FakeAuthRepository auth, FakeProfileRepository profiles) {
  return ProviderScope(
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
      profileRepositoryProvider.overrideWithValue(profiles),
      orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
      catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
    ],
    child: const MassApp(),
  );
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('No se encontró el texto esperado.');
}
