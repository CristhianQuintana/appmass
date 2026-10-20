import 'package:flutter/material.dart';

import '../../../app/theme/mass_colors.dart';
import '../../orders/domain/money.dart';
import '../domain/catalog_product.dart';

/// Ilustración de categoría. No es una foto oficial del producto.
class ProductArtwork extends StatelessWidget {
  const ProductArtwork({required this.label, this.size = 72, super.key});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(label);
    return Semantics(
      label: 'Ilustración de ${visual.caption}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: visual.background,
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
        child: Icon(visual.icon, color: visual.foreground, size: size * 0.46),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    this.onAdd,
    this.onOpen,
    super.key,
  });

  final CatalogProduct product;
  final VoidCallback? onAdd;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen ?? onAdd,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: ProductArtwork(label: product.category, size: 72)),
              const SizedBox(height: 12),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: MassColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                product.unitLabel,
                style: const TextStyle(color: MassColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Money(product.priceCents).label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (!product.isActive)
                    const Icon(
                      Icons.visibility_off,
                      size: 18,
                      color: MassColors.muted,
                    )
                  else if (onAdd != null)
                    IconButton(
                      tooltip: 'Agregar ${product.name}',
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_circle, color: MassColors.ink),
                    )
                  else if (onOpen != null)
                    const Icon(Icons.chevron_right, color: MassColors.muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Artwork {
  const _Artwork(this.icon, this.background, this.foreground, this.caption);

  final IconData icon;
  final Color background;
  final Color foreground;
  final String caption;
}

_Artwork _visualFor(String label) {
  final value = label.toLowerCase();
  if (value.contains('bebida') ||
      value.contains('agua') ||
      value.contains('gaseosa')) {
    return const _Artwork(
      Icons.local_drink,
      Color(0xFFD7E8FF),
      Color(0xFF1D4E89),
      'bebida',
    );
  }
  if (value.contains('pan')) {
    return const _Artwork(
      Icons.bakery_dining,
      Color(0xFFFFE3C2),
      Color(0xFF8A4B08),
      'panadería',
    );
  }
  if (value.contains('láct') ||
      value.contains('lact') ||
      value.contains('leche')) {
    return const _Artwork(
      Icons.water_drop,
      Color(0xFFE4F4FF),
      Color(0xFF0F5F8A),
      'lácteo',
    );
  }
  if (value.contains('limpieza') || value.contains('deterg')) {
    return const _Artwork(
      Icons.cleaning_services,
      Color(0xFFE5F6EA),
      Color(0xFF1B6B3A),
      'limpieza',
    );
  }
  if (value.contains('huevo')) {
    return const _Artwork(
      Icons.egg_alt,
      Color(0xFFFFF3C4),
      Color(0xFF745B00),
      'huevos',
    );
  }
  if (value.contains('entrega') || value.contains('domicilio')) {
    return const _Artwork(
      Icons.local_shipping,
      Color(0xFFE7EEFF),
      Color(0xFF1D3F8A),
      'entrega',
    );
  }
  return const _Artwork(
    Icons.inventory_2,
    Color(0xFFFFF4CC),
    Color(0xFF745B00),
    'abarrotes',
  );
}
