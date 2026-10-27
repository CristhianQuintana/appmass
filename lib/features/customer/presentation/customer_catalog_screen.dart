import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_button.dart';
import '../../catalog/domain/catalog_product.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/money.dart';
import '../../orders/presentation/order_widgets.dart';
import '../../orders/presentation/role_shell.dart';
import '../application/customer_cart.dart';
import '../application/customer_catalog_filters.dart';
import 'fly_to_cart.dart';

const customerCategories = [
  'Bebidas',
  'Panadería',
  'Lácteos',
  'Abarrotes',
  'Limpieza',
  'Snacks',
  'Cuidado personal',
];

class CustomerCatalogScreen extends ConsumerWidget {
  const CustomerCatalogScreen({this.category, super.key});

  final String? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = category?.trim() ?? '';
    if (selected.isEmpty) {
      return const _CategoriesBrowse();
    }
    return _CategoryProducts(category: selected);
  }
}

class _CategoriesBrowse extends ConsumerWidget {
  const _CategoriesBrowse();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogListProvider);
    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncFeedback(
        message: userFacingMessage(error),
        onRetry: () => ref.invalidate(catalogListProvider),
      ),
      data: (products) {
        final counts = <String, int>{};
        for (final product in products) {
          if (!product.isActive) continue;
          counts[product.category] = (counts[product.category] ?? 0) + 1;
        }
        final categories = [
          for (final name in customerCategories)
            if ((counts[name] ?? 0) > 0) name,
          for (final entry in counts.entries)
            if (!customerCategories.contains(entry.key)) entry.key,
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: MassColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Elige un tipo de producto para ver su catálogo.',
              style: TextStyle(color: MassColors.muted, height: 1.35),
            ),
            const SizedBox(height: 18),
            for (final name in categories)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: MassColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => context.go(
                      '${AppRoutes.customerHome}/catalogo?categoria=${Uri.encodeComponent(name)}',
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: MassColors.outline),
                        gradient: LinearGradient(
                          colors: [
                            MassColors.yellowSoft.withValues(alpha: 0.55),
                            MassColors.surface,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ProductArtwork(label: name, size: 64),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      color: MassColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${counts[name] ?? 0} productos',
                                    style: const TextStyle(
                                      color: MassColors.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: MassColors.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryProducts extends ConsumerWidget {
  const _CategoryProducts({required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogListProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Volver a categorías',
                onPressed: () =>
                    context.go('${AppRoutes.customerHome}/catalogo'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: MassColors.ink,
                      ),
                    ),
                    const Text(
                      'Catálogo por categoría',
                      style: TextStyle(
                        color: MassColors.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.go('${AppRoutes.customerHome}/catalogo'),
                child: const Text('Categorías'),
              ),
            ],
          ),
        ),
        Expanded(
          child: catalog.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AsyncFeedback(
              message: userFacingMessage(error),
              onRetry: () => ref.invalidate(catalogListProvider),
            ),
            data: (products) {
              final visible = [
                for (final product in products)
                  if (product.isActive && product.category == category) product,
              ];
              if (visible.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay productos en esta categoría.',
                    style: TextStyle(color: MassColors.muted),
                  ),
                );
              }
              return CatalogImagePrefetch(
                products: visible,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      onAdd: (origin) async {
                        ref.read(customerCartProvider.notifier).add(product);
                        await playFlyToCart(
                          context: context,
                          fromKey: origin,
                          category: product.category,
                          imageUrl: product.imageUrl,
                        );
                        if (!context.mounted) return;
                        showAddedToCartSnack(
                          context,
                          productName: product.name,
                          onViewCart: () => openCustomerCartDrawer(context),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CustomerProductScreen extends ConsumerStatefulWidget {
  const CustomerProductScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<CustomerProductScreen> createState() =>
      _CustomerProductScreenState();
}

class _CustomerProductScreenState extends ConsumerState<CustomerProductScreen> {
  final GlobalKey _imageKey = GlobalKey();
  var _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogListProvider);
    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncFeedback(
        message: userFacingMessage(error),
        onRetry: () => ref.invalidate(catalogListProvider),
      ),
      data: (products) {
        final matches = products.where(
          (product) => product.id == widget.productId,
        );
        if (matches.isEmpty || !matches.first.isActive) {
          return const Center(child: Text('No encontramos ese producto.'));
        }
        final product = matches.first;
        final weight = saleUnitKind(product.unitLabel) == SaleUnitKind.weight;
        final unitWord = weight ? 'kg' : product.unitLabel;
        final offer = productHasOffer(product);
        final total = product.priceCents * _quantity;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  KeyedSubtree(
                    key: _imageKey,
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: MassColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: MassColors.outline),
                          boxShadow: const [
                            BoxShadow(
                              color: MassColors.shadow,
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ProductArtwork(
                                  label: product.category,
                                  imageUrl: product.imageUrl,
                                  expand: true,
                                  hiRes: true,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              if (offer)
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: MassColors.offer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '-${productDiscountPercent(product)}% oferta',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      color: MassColors.muted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: MassColors.ink,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (offer)
                    Text(
                      Money(productListPriceCents(product)).label,
                      style: const TextStyle(
                        color: MassColors.muted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '${Money(product.priceCents).label} · $unitWord',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: offer ? MassColors.offer : MassColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    customerFacingDescription(product),
                    style: const TextStyle(
                      color: MassColors.inkSoft,
                      height: 1.45,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: MassColors.surfaceLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MassColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weight ? 'Cantidad (kg)' : 'Cantidad (unidades)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: MassColors.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _QtyChip(
                              icon: Icons.remove_rounded,
                              onPressed: _quantity <= 1
                                  ? null
                                  : () => setState(() => _quantity -= 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: Text(
                                '$_quantity $unitWord',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            _QtyChip(
                              icon: Icons.add_rounded,
                              onPressed: _quantity >= 99
                                  ? null
                                  : () => setState(() => _quantity += 1),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    color: MassColors.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  Money(total).label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    color: MassColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: MassButton(
                  buttonKey: const Key('customer-add'),
                  label: 'Agregar $_quantity $unitWord · ${Money(total).label}',
                  icon: Icons.add_shopping_cart_rounded,
                  onPressed: () => _add(product),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _add(CatalogProduct product) async {
    ref.read(customerCartProvider.notifier).add(product, quantity: _quantity);
    await playFlyToCart(
      context: context,
      fromKey: _imageKey,
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

class _QtyChip extends StatelessWidget {
  const _QtyChip({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MassColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: onPressed == null ? MassColors.outline : MassColors.ink,
          ),
        ),
      ),
    );
  }
}
