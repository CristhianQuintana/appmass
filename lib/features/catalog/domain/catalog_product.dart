class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.category,
    required this.unitLabel,
    required this.priceCents,
    required this.isActive,
    required this.isSample,
    this.imageUrl = '',
  });

  final String id;
  final String sku;
  final String name;
  final String description;
  final String category;
  final String unitLabel;
  final int priceCents;
  final bool isActive;
  final bool isSample;
  final String imageUrl;
}

class ProductInput {
  const ProductInput({
    this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.category,
    required this.unitLabel,
    required this.priceCents,
    required this.isActive,
    this.imageUrl = '',
  });

  final String? id;
  final String sku;
  final String name;
  final String description;
  final String category;
  final String unitLabel;
  final int priceCents;
  final bool isActive;
  final String imageUrl;

  String? validate() {
    if (sku.trim().isEmpty || sku.trim().length > 40) {
      return 'Ingresa un código de producto.';
    }
    if (name.trim().isEmpty || name.trim().length > 120) {
      return 'Ingresa el nombre del producto.';
    }
    if (description.trim().length > 400) {
      return 'La descripción es demasiado larga.';
    }
    if (category.trim().isEmpty || category.trim().length > 40) {
      return 'Ingresa una categoría.';
    }
    if (unitLabel.trim().isEmpty || unitLabel.trim().length > 40) {
      return 'Ingresa la unidad.';
    }
    if (priceCents < 0) return 'El precio no puede ser negativo.';
    final image = imageUrl.trim();
    if (image.length > 500) return 'La URL de la imagen es demasiado larga.';
    if (image.isNotEmpty && !image.toLowerCase().startsWith('https://')) {
      return 'La imagen debe usar una URL https.';
    }
    return null;
  }
}

abstract class CatalogRepository {
  Future<List<CatalogProduct>> search({
    required String query,
    required bool includeInactive,
  });

  Future<String> saveProduct(ProductInput input);
}

/// Limita y neutraliza una búsqueda antes de enviarla al servidor.
String sanitizeCatalogQuery(String raw) {
  final cleaned = raw.trim().replaceAll(RegExp(r'[%_\\,()*]'), '');
  if (cleaned.length <= 40) return cleaned;
  return cleaned.substring(0, 40);
}
