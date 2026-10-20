import 'package:app_mass/app/app.dart';
import 'package:app_mass/core/errors/app_failure.dart';
import 'package:app_mass/features/catalog/domain/catalog_product.dart';
import 'package:app_mass/features/orders/domain/order_draft.dart';
import 'package:app_mass/features/simulation/demo_accounts.dart';
import 'package:app_mass/features/simulation/simulation_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'la demostración cobra el precio del catálogo, no el del teléfono',
    () async {
      final store = SimulationStore.seeded();
      addTearDown(store.dispose);
      await store.signIn(
        email: 'ana.operadora@demo.local',
        password: demoPassword,
      );
      const tampered = CatalogProduct(
        id: '11111111-1111-4111-8111-111111111111',
        sku: 'PRB-001',
        name: 'Agua de mesa 625 ml',
        description: '',
        category: 'Bebidas',
        unitLabel: 'botella',
        priceCents: 1,
        isActive: true,
        isSample: true,
      );
      final draft = OrderDraft.empty('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')
          .copyWith(customerName: 'Rosa Mendoza')
          .addProduct(tampered);

      final id = await store.createOrder(draft);
      final saved = await store.findOrder(id);

      expect(saved?.totalCents, 150);
      expect(saved?.items.single.unitPriceCents, 150);
    },
  );

  test('el transportista simulado no ve pedidos de otros', () async {
    final store = SimulationStore.seeded();
    addTearDown(store.dispose);
    await store.signIn(
      email: 'luis.reparto@demo.local',
      password: demoPassword,
    );

    final orders = await store.listOrders();

    expect(orders.map((order) => order.publicCode), [
      'PED-DEMO-1005',
      'PED-DEMO-1004',
    ]);
    expect(await store.findOrder('order-submitted'), isNull);
  });

  testWidgets(
    'la demostración abre el inicio del operador con pedidos de prueba',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: MassApp()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byKey(const Key('demo-enter')));
      await _until(tester, find.byKey(const Key('demo-account-operator')));

      await tester.tap(find.byKey(const Key('demo-account-operator')));
      await _until(tester, find.text('PED-DEMO-1001'));

      expect(find.text('Ana Quispe'), findsOneWidget);
      expect(
        find.text('Demostración local. Datos ficticios, sin conexión.'),
        findsOneWidget,
      );
      expect(find.text('PED-DEMO-1005'), findsOneWidget);
    },
  );

  test('el cliente simulado solo ve su pedido y el catálogo activo', () async {
    final store = SimulationStore.seeded();
    addTearDown(store.dispose);
    await store.signIn(
      email: 'rosa.cliente@demo.local',
      password: demoPassword,
    );

    final orders = await store.listOrders();
    final products = await store.search(query: '', includeInactive: false);

    expect(orders.map((order) => order.publicCode), ['PED-DEMO-1001']);
    expect(products, isNotEmpty);
    expect(products.every((product) => product.isActive), isTrue);
    expect(store.summary(), throwsA(isA<UnauthorizedFailure>()));
    expect(store.listStaff(), throwsA(isA<UnauthorizedFailure>()));
  });

  testWidgets('la cuenta de cliente abre su tienda y no el personal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: MassApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const Key('demo-enter')));
    await _until(tester, find.byKey(const Key('demo-account-customer')));
    await tester.tap(find.byKey(const Key('demo-account-customer')));
    await _until(tester, find.text('Bebidas'));

    expect(find.text('Rosa Mendoza'), findsOneWidget);
    expect(find.text('Cliente'), findsWidgets);
    expect(find.text('Personal'), findsNothing);
    expect(find.text('Panadería'), findsOneWidget);
  });
}

Future<void> _until(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('No se encontró el elemento esperado.');
}
