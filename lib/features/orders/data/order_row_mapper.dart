import '../../../core/errors/app_failure.dart';
import '../domain/order_status.dart';
import '../domain/store_order.dart';

int readCents(Object? value) {
  if (value is int && value >= 0) return value;
  throw const ValidationFailure('El pedido devolvió un importe inválido.');
}

DateTime readTime(Object? value) {
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.toLocal();
  }
  throw const ValidationFailure('El pedido devolvió una fecha inválida.');
}

StoreOrder mapOrderRow(Map<String, dynamic> row) {
  final id = row['id'];
  final code = row['public_code'];
  final modality = row['modality'];
  final status = row['status'];
  final name = row['customer_name'];
  final createdBy = row['created_by'];
  final version = row['version'];
  if (id is! String ||
      code is! String ||
      modality is! String ||
      status is! String ||
      name is! String ||
      createdBy is! String ||
      version is! int) {
    throw const ValidationFailure('El pedido devolvió un dato incompleto.');
  }
  return StoreOrder(
    id: id,
    publicCode: code,
    modality: modalityFromStorage(modality),
    status: orderStatusFromStorage(status),
    customerName: name,
    customerPhone: row['customer_phone'] is String
        ? row['customer_phone'] as String
        : '',
    addressLine: row['address_line'] is String
        ? row['address_line'] as String
        : '',
    addressReference: row['address_reference'] is String
        ? row['address_reference'] as String
        : '',
    notes: row['notes'] is String ? row['notes'] as String : '',
    createdBy: createdBy,
    totalCents: readCents(row['total_cents']),
    version: version,
    createdAt: readTime(row['created_at']),
    items: _items(row['order_items']),
  );
}

List<OrderItem> _items(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const ValidationFailure('El detalle del pedido es inválido.');
  }
  return [for (final raw in value) _item(_asMap(raw))];
}

Map<String, dynamic> _asMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  throw const ValidationFailure('El detalle del pedido es inválido.');
}

OrderItem _item(Map<String, dynamic> row) {
  final name = row['product_name'];
  final quantity = row['quantity'];
  if (name is! String || quantity is! int) {
    throw const ValidationFailure('Una línea del pedido es inválida.');
  }
  var imageUrl = '';
  var category = '';
  final product = row['products'];
  if (product is Map) {
    final image = product['image_url'];
    final cat = product['category'];
    if (image is String) imageUrl = image;
    if (cat is String) category = cat;
  }
  return OrderItem(
    productName: name,
    quantity: quantity,
    unitPriceCents: readCents(row['unit_price_cents']),
    lineTotalCents: readCents(row['line_total_cents']),
    imageUrl: imageUrl,
    category: category,
  );
}

OrderEvent mapEventRow(Map<String, dynamic> row) {
  final action = row['action'];
  final toStatus = row['to_status'];
  if (action is! String || toStatus is! String) {
    throw const ValidationFailure('El historial del pedido es inválido.');
  }
  return OrderEvent(
    action: action,
    fromStatus: row['from_status'] is String
        ? row['from_status'] as String
        : null,
    toStatus: toStatus,
    note: row['note'] is String ? row['note'] as String : '',
    createdAt: readTime(row['created_at']),
  );
}
