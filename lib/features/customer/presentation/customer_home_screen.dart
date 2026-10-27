import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../catalog/domain/catalog_product.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/presentation/order_widgets.dart';
import '../../orders/presentation/role_shell.dart';
import '../application/customer_cart.dart';
import '../application/customer_catalog_filters.dart';
import 'customer_filter_sheet.dart';
import 'fly_to_cart.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogListProvider);
    final filters = ref.watch(customerCatalogFiltersProvider);

    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncFeedback(
        message: userFacingMessage(error),
        onRetry: () => ref.invalidate(catalogListProvider),
      ),
      data: (products) {
        final active = [for (final p in products) if (p.isActive) p];
        final categories = {
          for (final p in active) p.category,
        }.toList()..sort();
        final prices = active.map((p) => p.priceCents).toList()..sort();
        final minCents = prices.isEmpty ? 0 : prices.first;
        final maxCents = prices.isEmpty ? 10000 : prices.last;
        final visible = applyCustomerFilters(active, filters);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Todo el catálogo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: MassColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${visible.length} productos disponibles',
                    style: const TextStyle(
                      color: MassColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _search,
                          onChanged: (value) => ref
                              .read(customerCatalogFiltersProvider.notifier)
                              .setQuery(value),
                          decoration: InputDecoration(
                            hintText: 'Buscar productos',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: filters.query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Limpiar',
                                    onPressed: () {
                                      _search.clear();
                                      ref
                                          .read(
                                            customerCatalogFiltersProvider
                                                .notifier,
                                          )
                                          .setQuery('');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Badge(
                        isLabelVisible: filters.hasActiveFilters,
                        child: Material(
                          color: MassColors.ink,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => showCustomerFilterSheet(
                              context,
                              categories: categories,
                              catalogMinCents: minCents,
                              catalogMaxCents: maxCents,
                            ),
                            child: const SizedBox(
                              width: 52,
                              height: 52,
                              child: Icon(
                                Icons.tune_rounded,
                                color: MassColors.yellow,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (visible.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No hay productos con esos filtros.',
                    style: TextStyle(color: MassColors.muted),
                  ),
                ),
              )
            else
              Expanded(
                child: CatalogImagePrefetch(
                  products: active,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final product = visible[index];
                      return ProductCard(
                        product: product,
                        onOpen: () => context.go(
                          '${AppRoutes.customerHome}/producto/${product.id}',
                        ),
                        onAdd: (origin) => _addWithAnimation(product, origin),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _addWithAnimation(
    CatalogProduct product,
    GlobalKey origin,
  ) async {
    ref.read(customerCartProvider.notifier).add(product);
    await playFlyToCart(
      context: context,
      fromKey: origin,
      category: product.category,
      imageUrl: product.imageUrl,
    );
    if (!mounted) return;
    showAddedToCartSnack(
      context,
      productName: product.name,
      onViewCart: () => openCustomerCartDrawer(context),
    );
  }
}
