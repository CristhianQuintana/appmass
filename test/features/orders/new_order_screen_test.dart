import 'package:app_mass/app/theme/mass_theme.dart';
import 'package:app_mass/features/authentication/application/auth_providers.dart';
import 'package:app_mass/features/authentication/domain/auth_identity.dart';
import 'package:app_mass/features/catalog/domain/catalog_product.dart';
import 'package:app_mass/features/orders/application/order_providers.dart';
import 'package:app_mass/features/orders/presentation/new_order_screen.dart';
import 'package:app_mass/features/profile/application/profile_controller.dart';
import 'package:app_mass/features/profile/domain/staff_profile.dart';
import 'package:app_mass/features/profile/domain/staff_role.dart';
import 'package:app_mass/core/config/app_config.dart';
import 'package:app_mass/core/startup/startup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_catalog_repository.dart';
import '../../support/fake_order_repository.dart';
import '../../support/fake_profile_repository.dart';

void main() {
  testWidgets(
    'un pedido vacío no se envía y el catálogo se identifica como prueba',
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
      final orders = FakeOrderRepository();
      addTearDown(auth.dispose);
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
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
            orderRepositoryProvider.overrideWithValue(orders),
            catalogRepositoryProvider.overrideWithValue(
              FakeCatalogRepository(
                products: const [
                  CatalogProduct(
                    id: '11111111-1111-1111-1111-111111111111',
                    sku: 'PRB-001',
                    name: 'Agua de mesa',
                    description: '',
                    category: 'Bebidas',
                    unitLabel: 'botella',
                    priceCents: 150,
                    isActive: true,
                    isSample: true,
                  ),
                ],
              ),
            ),
          ],
          child: MaterialApp(
            theme: MassTheme.light(),
            home: const Scaffold(body: NewOrderScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text(
          'Catálogo de prueba. No son precios oficiales de Tiendas MASS.',
        ),
        findsOneWidget,
      );
      expect(find.text('Agua de mesa'), findsOneWidget);

      await tester.tap(find.byKey(const Key('order-submit')));
      await tester.pump();

      expect(find.text('Ingresa el nombre de contacto.'), findsOneWidget);
      expect(orders.createdPayloads, isEmpty);
    },
  );
}
