import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/money.dart';
import '../../orders/presentation/order_widgets.dart';
import '../application/customer_cart.dart';

class CustomerCatalogScreen extends ConsumerWidget {
  const CustomerCatalogScreen({this.category, super.key});

  final String? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogListProvider);
    final title = (category == null || category!.isEmpty)
        ? 'Catálogo'
        : category!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: MassSectionTitle(
            title: title,
            help: 'Toca un producto para verlo y agregarlo al carrito.',
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SampleCatalogNotice(),
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
                  if (product.isActive &&
                      (category == null ||
                          category!.isEmpty ||
                          product.category == category))
                    product,
              ];
              if (visible.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 72),
                      SizedBox(height: 12),
                      Text('No hay productos en esta categoría.'),
                    ],
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CustomerProductScreen extends ConsumerWidget {
  const CustomerProductScreen({required this.productId, super.key});

  final String productId;

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
        final matches = products.where((product) => product.id == productId);
        if (matches.isEmpty || !matches.first.isActive) {
          return const Center(child: Text('No encontramos ese producto.'));
        }
        final product = matches.first;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(child: ProductArtwork(label: product.category, size: 140)),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: MassColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.unitLabel,
              style: const TextStyle(color: MassColors.muted),
            ),
            const SizedBox(height: 12),
            Text(
              Money(product.priceCents).label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: MassColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            Text(product.description),
            const SizedBox(height: 24),
            MassButton(
              buttonKey: const Key('customer-add'),
              label: 'Agregar al carrito',
              icon: Icons.add_shopping_cart,
              onPressed: () {
                ref.read(customerCartProvider.notifier).add(product);
                context.go('${AppRoutes.customerHome}/carrito');
              },
            ),
          ],
        );
      },
    );
  }
}
