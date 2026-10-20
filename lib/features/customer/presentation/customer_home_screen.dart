import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../../orders/presentation/order_widgets.dart';

const customerCategories = [
  'Bebidas',
  'Panadería',
  'Lácteos',
  'Abarrotes',
  'Limpieza',
];

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const MassSectionTitle(
          title: 'Tienda',
          help: 'Elige una categoría para ver los productos de prueba.',
        ),
        const SizedBox(height: 8),
        const SampleCatalogNotice(),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: customerCategories.length,
          itemBuilder: (context, index) {
            final category = customerCategories[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.go(
                  '${AppRoutes.customerHome}/catalogo?categoria=${Uri.encodeComponent(category)}',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProductArtwork(label: category, size: 72),
                      const SizedBox(height: 12),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: MassColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
