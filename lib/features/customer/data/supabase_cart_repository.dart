import 'package:supabase_flutter/supabase_flutter.dart';

import '../../catalog/domain/catalog_product.dart';
import '../../orders/data/remote_error.dart';
import '../../orders/domain/order_draft.dart';

class SupabaseCartRepository {
  SupabaseCartRepository(this._client);

  final SupabaseClient _client;

  Future<List<DraftLine>> listItems() {
    return guardRemote(() async {
      final rows = await _client.rpc('list_cart_items');
      if (rows is! List) return const [];
      return [
        for (final row in rows)
          if (row is Map<String, dynamic>)
            DraftLine(
              product: CatalogProduct(
                id: row['product_id'] as String,
                sku: row['sku'] as String? ?? '',
                name: row['name'] as String? ?? '',
                description: '',
                category: row['category'] as String? ?? '',
                unitLabel: row['unit_label'] as String? ?? '',
                priceCents: _asInt(row['price_cents']),
                isActive: true,
                isSample: true,
                imageUrl: row['image_url'] is String
                    ? row['image_url'] as String
                    : '',
              ),
              quantity: _asInt(row['quantity'], fallback: 1),
            ),
      ];
    });
  }

  Future<void> upsert({required String productId, required int quantity}) {
    return guardRemote(() async {
      await _client.rpc(
        'upsert_cart_item',
        params: {'p_product_id': productId, 'p_quantity': quantity},
      );
    });
  }

  Future<void> clear() {
    return guardRemote(() async {
      await _client.rpc('clear_cart');
    });
  }
}

class LocalCartRepository {
  const LocalCartRepository();

  Future<List<DraftLine>> listItems() async => const [];

  Future<void> upsert({
    required String productId,
    required int quantity,
  }) async {}

  Future<void> clear() async {}
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}
