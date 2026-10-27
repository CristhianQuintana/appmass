import '../../../core/errors/app_failure.dart';
import '../domain/catalog_product.dart';

CatalogProduct mapProductRow(Map<String, dynamic> row) {
  final id = row['id'];
  final sku = row['sku'];
  final name = row['name'];
  final price = row['price_cents'];
  final active = row['is_active'];
  final sample = row['is_sample'];
  final priceCents = price is int
      ? price
      : price is num
      ? price.toInt()
      : null;
  if (id is! String ||
      sku is! String ||
      name is! String ||
      priceCents == null ||
      active is! bool ||
      sample is! bool) {
    throw const ValidationFailure('El catálogo devolvió un dato incompleto.');
  }
  return CatalogProduct(
    id: id,
    sku: sku,
    name: name,
    description: row['description'] is String
        ? row['description'] as String
        : '',
    category: row['category'] is String ? row['category'] as String : 'General',
    unitLabel: row['unit_label'] is String
        ? row['unit_label'] as String
        : 'unidad',
    priceCents: priceCents,
    isActive: active,
    isSample: sample,
    imageUrl: row['image_url'] is String ? row['image_url'] as String : '',
  );
}
