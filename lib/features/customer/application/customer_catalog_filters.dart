import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/domain/catalog_product.dart';

enum CatalogSort { relevance, priceAsc, priceDesc, nameAsc }

enum UnitFilter { all, piece, weight }

class CustomerCatalogFilters {
  const CustomerCatalogFilters({
    this.query = '',
    this.categories = const {},
    this.minPriceCents = 0,
    this.maxPriceCents = 100000,
    this.offersOnly = false,
    this.unit = UnitFilter.all,
    this.sort = CatalogSort.relevance,
  });

  final String query;
  final Set<String> categories;
  final int minPriceCents;
  final int maxPriceCents;
  final bool offersOnly;
  final UnitFilter unit;
  final CatalogSort sort;

  bool get hasActiveFilters =>
      query.trim().isNotEmpty ||
      categories.isNotEmpty ||
      offersOnly ||
      unit != UnitFilter.all ||
      sort != CatalogSort.relevance ||
      minPriceCents > 0 ||
      maxPriceCents < 100000;

  CustomerCatalogFilters copyWith({
    String? query,
    Set<String>? categories,
    int? minPriceCents,
    int? maxPriceCents,
    bool? offersOnly,
    UnitFilter? unit,
    CatalogSort? sort,
  }) {
    return CustomerCatalogFilters(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      minPriceCents: minPriceCents ?? this.minPriceCents,
      maxPriceCents: maxPriceCents ?? this.maxPriceCents,
      offersOnly: offersOnly ?? this.offersOnly,
      unit: unit ?? this.unit,
      sort: sort ?? this.sort,
    );
  }
}

class CustomerCatalogFiltersController extends Notifier<CustomerCatalogFilters> {
  @override
  CustomerCatalogFilters build() => const CustomerCatalogFilters();

  void setQuery(String value) => state = state.copyWith(query: value);

  void toggleCategory(String category) {
    final next = {...state.categories};
    if (!next.add(category)) next.remove(category);
    state = state.copyWith(categories: next);
  }

  void setPriceRange(int minCents, int maxCents) {
    state = state.copyWith(minPriceCents: minCents, maxPriceCents: maxCents);
  }

  void setOffersOnly(bool value) => state = state.copyWith(offersOnly: value);

  void setUnit(UnitFilter value) => state = state.copyWith(unit: value);

  void setSort(CatalogSort value) => state = state.copyWith(sort: value);

  void reset() => state = const CustomerCatalogFilters();
}

final customerCatalogFiltersProvider =
    NotifierProvider<CustomerCatalogFiltersController, CustomerCatalogFilters>(
      CustomerCatalogFiltersController.new,
    );

/// Oferta visual determinista (sin campo de descuento en BD).
bool productHasOffer(CatalogProduct product) {
  final digits = int.tryParse(product.sku.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  return digits % 3 == 0;
}

int productListPriceCents(CatalogProduct product) {
  if (!productHasOffer(product)) return product.priceCents;
  return (product.priceCents * 1.18).round();
}

int productDiscountPercent(CatalogProduct product) {
  if (!productHasOffer(product)) return 0;
  final list = productListPriceCents(product);
  if (list <= 0) return 0;
  return (((list - product.priceCents) / list) * 100).round().clamp(1, 90);
}

enum SaleUnitKind { piece, weight }

SaleUnitKind saleUnitKind(String unitLabel) {
  final value = unitLabel.toLowerCase();
  if (value.contains('kg') ||
      value.contains('kilo') ||
      RegExp(r'\b\d+\s*g\b').hasMatch(value) ||
      value.trim() == 'g') {
    return SaleUnitKind.weight;
  }
  return SaleUnitKind.piece;
}

String saleUnitCaption(CatalogProduct product) {
  return saleUnitKind(product.unitLabel) == SaleUnitKind.weight
      ? 'por kg'
      : 'por ${product.unitLabel}';
}

String customerFacingDescription(CatalogProduct product) {
  final raw = product.description.trim();
  final lower = raw.toLowerCase();
  if (raw.isEmpty ||
      lower.contains('prueba') ||
      lower.contains('no es un artículo oficial') ||
      lower.contains('no es un articulo oficial') ||
      lower.contains('ficticio')) {
    return 'Producto de ${product.category.toLowerCase()}. '
        'Se vende ${saleUnitCaption(product)}.';
  }
  return raw;
}

List<CatalogProduct> applyCustomerFilters(
  List<CatalogProduct> products,
  CustomerCatalogFilters filters,
) {
  final q = filters.query.trim().toLowerCase();
  var list = [
    for (final product in products)
      if (product.isActive &&
          (filters.categories.isEmpty ||
              filters.categories.contains(product.category)) &&
          product.priceCents >= filters.minPriceCents &&
          product.priceCents <= filters.maxPriceCents &&
          (!filters.offersOnly || productHasOffer(product)) &&
          _matchesUnit(product, filters.unit) &&
          (q.isEmpty ||
              product.name.toLowerCase().contains(q) ||
              product.category.toLowerCase().contains(q) ||
              product.sku.toLowerCase().contains(q)))
        product,
  ];

  switch (filters.sort) {
    case CatalogSort.priceAsc:
      list.sort((a, b) => a.priceCents.compareTo(b.priceCents));
    case CatalogSort.priceDesc:
      list.sort((a, b) => b.priceCents.compareTo(a.priceCents));
    case CatalogSort.nameAsc:
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    case CatalogSort.relevance:
      break;
  }
  return list;
}

bool _matchesUnit(CatalogProduct product, UnitFilter filter) {
  if (filter == UnitFilter.all) return true;
  final kind = saleUnitKind(product.unitLabel);
  if (filter == UnitFilter.weight) return kind == SaleUnitKind.weight;
  return kind == SaleUnitKind.piece;
}
