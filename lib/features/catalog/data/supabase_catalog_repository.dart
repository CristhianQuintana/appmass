import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_failure.dart';
import '../../orders/data/remote_error.dart';
import '../domain/catalog_product.dart';
import 'product_row_mapper.dart';

class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<CatalogProduct>> search({
    required String query,
    required bool includeInactive,
  }) {
    return guardRemote(() async {
      final rows = await _client.rpc(
        'list_catalog',
        params: {
          'p_query': sanitizeCatalogQuery(query),
          'p_include_inactive': includeInactive,
        },
      );
      if (rows is! List) return const [];
      return [for (final row in rows) mapProductRow(_rowMap(row))];
    });
  }

  @override
  Future<String> saveProduct(ProductInput input) {
    return guardRemote(() async {
      final id = await _client.rpc(
        'upsert_product',
        params: {
          'p_id': input.id,
          'p_sku': input.sku.trim(),
          'p_name': input.name.trim(),
          'p_description': input.description.trim(),
          'p_category': input.category.trim(),
          'p_unit_label': input.unitLabel.trim(),
          'p_price_cents': input.priceCents,
          'p_active': input.isActive,
        },
      );
      if (id is! String || id.isEmpty) throw const UnexpectedFailure();
      return id;
    });
  }
}

Map<String, dynamic> _rowMap(Object? row) {
  if (row is Map<String, dynamic>) return row;
  if (row is Map) return Map<String, dynamic>.from(row);
  throw const ValidationFailure('El catálogo devolvió un dato incompleto.');
}
