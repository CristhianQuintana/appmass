import '../../../core/errors/app_failure.dart';
import '../domain/catalog_product.dart';

class UnavailableCatalogRepository implements CatalogRepository {
  const UnavailableCatalogRepository();

  @override
  Future<List<CatalogProduct>> search({
    required String query,
    required bool includeInactive,
  }) async {
    return const [];
  }

  @override
  Future<String> saveProduct(ProductInput input) async {
    throw const ConfigurationFailure();
  }
}
