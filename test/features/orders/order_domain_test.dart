import 'package:app_mass/features/catalog/domain/catalog_product.dart';
import 'package:app_mass/features/delivery/domain/maps_link.dart';
import 'package:app_mass/features/orders/domain/idempotency_key.dart';
import 'package:app_mass/features/orders/domain/money.dart';
import 'package:app_mass/features/orders/domain/order_draft.dart';
import 'package:app_mass/features/orders/domain/order_rules.dart';
import 'package:app_mass/features/orders/domain/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const water = CatalogProduct(
    id: '11111111-1111-1111-1111-111111111111',
    sku: 'PRB-001',
    name: 'Agua de mesa',
    description: 'Dato de prueba',
    category: 'Bebidas',
    unitLabel: 'botella',
    priceCents: 150,
    isActive: true,
    isSample: true,
  );
  const inactive = CatalogProduct(
    id: '22222222-2222-2222-2222-222222222222',
    sku: 'PRB-006',
    name: 'Gaseosa',
    description: 'Dato de prueba',
    category: 'Bebidas',
    unitLabel: 'botella',
    priceCents: 250,
    isActive: false,
    isSample: true,
  );

  test('el dinero se calcula en céntimos y se muestra en soles', () {
    expect(const Money(150).lineTotal(2), 300);
    expect(const Money(450).label, contains('S/'));
    final label = const Money(450).label;
    expect(label.contains('4.50') || label.contains('4,50'), isTrue);
    expect(parseSolesToCents('4.50'), 450);
    expect(parseSolesToCents('4,5'), 450);
    expect(parseSolesToCents('4.555'), isNull);
    expect(() => const Money(-1).lineTotal(1), throwsArgumentError);
    expect(() => const Money(100).lineTotal(100), throwsArgumentError);
  });

  test('un borrador no envía precios y conserva la clave de reintento', () {
    final draft = OrderDraft.empty(newIdempotencyKey())
        .copyWith(customerName: 'Ana')
        .addProduct(water)
        .addProduct(water)
        .addProduct(inactive);
    expect(draft.lines, hasLength(1));
    expect(draft.lines.single.quantity, 2);
    final increased = draft.addProduct(water);
    expect(increased.lines.single.quantity, 3);
    expect(increased.changeQuantity(water.id, 100).lines.single.quantity, 3);

    final payload = orderItemsPayload(draft);
    expect(payload.single.keys, ['product_id', 'quantity']);
    expect(payload.single['quantity'], 2);
    expect(
      draft.copyWith(notes: 'sin cebolla').idempotencyKey,
      draft.idempotencyKey,
    );
    expect(draft.validate(), isNull);
    expect(
      draft.copyWith(customerName: '').validate(),
      'Ingresa el nombre de contacto.',
    );
    final ready = draft.copyWith(customerName: 'Ana');
    expect(ready.validate(), isNull);
    expect(
      ready.copyWith(modality: OrderModality.delivery).validate(),
      'Ingresa un teléfono de contacto válido.',
    );
  });

  test('la búsqueda no conserva comodines y se recorta', () {
    expect(sanitizeCatalogQuery('  pan%_\\()*  '), 'pan');
    expect(sanitizeCatalogQuery('a' * 50).length, 40);
  });

  test('las transiciones inválidas no se ofrecen en el cliente', () {
    const rules = OrderRules();
    expect(
      rules.preparationTarget(OrderStatus.submitted, OrderModality.inStore),
      OrderStatus.preparing,
    );
    expect(
      rules.preparationTarget(OrderStatus.completed, OrderModality.inStore),
      isNull,
    );
    expect(
      rules.preparationTarget(OrderStatus.preparing, OrderModality.delivery),
      OrderStatus.readyForDispatch,
    );
    expect(rules.canCancel(OrderStatus.assigned), isFalse);
    expect(
      rules.canAssign(OrderStatus.readyForDispatch, OrderModality.inStore),
      isFalse,
    );
    expect(
      rules.canAssign(OrderStatus.assigned, OrderModality.delivery),
      isTrue,
    );
    expect(rules.canStartDelivery(OrderStatus.inDelivery), isFalse);
    expect(rules.canRecordResult(OrderStatus.inDelivery), isTrue);
    expect(isAllowedFailureReason('customer_absent'), isTrue);
    expect(isAllowedFailureReason('robo'), isFalse);
    expect(() => orderStatusFromStorage('ready'), throwsFormatException);
  });

  test('el enlace de mapa solo lleva la dirección', () {
    final uri = deliveryMapsUri('Jr. Ayacucho 123, Huancayo');
    expect(uri, isNotNull);
    expect(uri!.host, 'www.google.com');
    expect(uri.queryParameters['query'], 'Jr. Ayacucho 123, Huancayo');
    expect(uri.toString(), isNot(contains('999')));
    expect(deliveryMapsUri('corta'), isNull);
    expect(deliveryMapsUri('linea\ninyectada'), isNull);
  });
}
