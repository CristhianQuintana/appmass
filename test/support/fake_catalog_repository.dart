import 'package:app_mass/features/catalog/domain/catalog_product.dart';

class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository({List<CatalogProduct>? products})
    : products = products ?? const [];

  final List<CatalogProduct> products;
  final saved = <ProductInput>[];
  Object? error;

  @override
  Future<List<CatalogProduct>> search({
    required String query,
    required bool includeInactive,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    final term = sanitizeCatalogQuery(query).toLowerCase();
    return [
      for (final product in products)
        if ((includeInactive || product.isActive) &&
            (term.isEmpty ||
                product.name.toLowerCase().contains(term) ||
                product.sku.toLowerCase().contains(term)))
          product,
    ];
  }

  @override
  Future<String> saveProduct(ProductInput input) async {
    final failure = error;
    if (failure != null) throw failure;
    saved.add(input);
    return input.id ?? 'product-new';
  }
}
