import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/mass_colors.dart';
import '../../orders/domain/money.dart';
import '../domain/catalog_product.dart';

/// Imagen del producto por URL o ilustración de categoría como respaldo.
class ProductArtwork extends StatelessWidget {
  const ProductArtwork({
    required this.label,
    this.imageUrl = '',
    this.size = 72,
    this.expand = false,
    this.fit = BoxFit.contain,
    /// Miniaturas más grandes (detalle de producto).
    this.hiRes = false,
    super.key,
  });

  final String label;
  final String imageUrl;
  final double size;

  /// Si es true, llena el padre en lugar de un cuadrado fijo.
  final bool expand;
  final BoxFit fit;
  final bool hiRes;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(label);
    final url = imageUrl.trim();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final box = expand ? null : size;
    final logical = hiRes
        ? 220.0
        : expand
        ? 120.0
        : size;
    final decodePx = (logical * dpr).clamp(64, hiRes ? 512 : 360).round();
    final networkUrl = url.toLowerCase().startsWith('https://')
        ? catalogThumbnailUrl(url, logicalSize: logical)
        : '';
    final fallback = _FallbackArt(visual: visual, size: size);

    Widget content;
    if (networkUrl.isNotEmpty) {
      content = CachedNetworkImage(
        imageUrl: networkUrl,
        fit: fit,
        alignment: Alignment.center,
        filterQuality: FilterQuality.low,
        memCacheWidth: decodePx,
        memCacheHeight: decodePx,
        fadeInDuration: const Duration(milliseconds: 120),
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      );
    } else {
      content = fallback;
    }

    final framed = ColoredBox(
      color: const Color(0xFFF3F4F6),
      child: box == null
          ? content
          : SizedBox(width: box, height: box, child: content),
    );
    return Semantics(
      label: networkUrl.isEmpty
          ? 'Ilustración de ${visual.caption}'
          : 'Imagen del producto',
      child: expand
          ? framed
          : ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.18),
              child: framed,
            ),
    );
  }
}

/// Prefiere miniaturas OFF (100/200) según el tamaño en pantalla.
String catalogThumbnailUrl(String url, {required double logicalSize}) {
  final target = logicalSize <= 80
      ? 100
      : logicalSize <= 160
      ? 200
      : 400;
  final match = RegExp(
    r'\.(100|200|400)\.(jpe?g|png|webp)$',
    caseSensitive: false,
  ).firstMatch(url);
  if (match == null) return url;
  final current = int.tryParse(match.group(1) ?? '') ?? 400;
  if (current <= target) return url;
  return url.replaceFirst(
    '.${match.group(1)}.',
    '.$target.',
  );
}

class _FallbackArt extends StatelessWidget {
  const _FallbackArt({required this.visual, required this.size});

  final _Artwork visual;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: visual.background,
      child: Center(
        child: Icon(visual.icon, color: visual.foreground, size: size * 0.42),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  const ProductCard({
    required this.product,
    this.onAdd,
    this.onOpen,
    this.showOfferBadge = true,
    super.key,
  });

  final CatalogProduct product;
  /// Recibe la clave del área de imagen para animar hacia el carrito.
  final Future<void> Function(GlobalKey originKey)? onAdd;
  final VoidCallback? onOpen;
  final bool showOfferBadge;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final offer = widget.showOfferBadge && _productHasOffer(product);
    final listPrice = _listPriceCents(product);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MassColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MassColors.outline),
        boxShadow: const [
          BoxShadow(
            color: MassColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: KeyedSubtree(
                        key: _imageKey,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: ProductArtwork(
                            label: product.category,
                            imageUrl: product.imageUrl,
                            expand: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    if (offer)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: MassColors.offer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '-${_discountPercent(product)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    if (widget.onAdd != null && product.isActive)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Material(
                          color: MassColors.yellow,
                          elevation: 2,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => widget.onAdd!(_imageKey),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 20,
                                color: MassColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: MassColors.ink,
                          height: 1.15,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _unitCaption(product),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MassColors.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (offer)
                        Text(
                          Money(listPrice).label,
                          style: const TextStyle(
                            color: MassColors.muted,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        Money(product.priceCents).label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: offer ? MassColors.offer : MassColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _productHasOffer(CatalogProduct product) {
  final digits =
      int.tryParse(product.sku.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  return digits % 3 == 0;
}

int _listPriceCents(CatalogProduct product) {
  if (!_productHasOffer(product)) return product.priceCents;
  return (product.priceCents * 1.18).round();
}

int _discountPercent(CatalogProduct product) {
  final list = _listPriceCents(product);
  if (list <= 0) return 0;
  return (((list - product.priceCents) / list) * 100).round().clamp(1, 90);
}

String _unitCaption(CatalogProduct product) {
  final value = product.unitLabel.toLowerCase();
  if (value.contains('kg') || value.contains('kilo')) {
    return 'Precio por kg';
  }
  return 'Precio por ${product.unitLabel}';
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
  if (value.contains('pan') || value.contains('snack')) {
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
  if (value.contains('limpieza') ||
      value.contains('deterg') ||
      value.contains('cuidado')) {
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

/// Precarga miniaturas del catálogo (disco + memoria) en lotes.
Future<void> prefetchProductImages(
  BuildContext context,
  Iterable<CatalogProduct> products, {
  int limit = 120,
  int batchSize = 8,
}) async {
  final dpr = MediaQuery.devicePixelRatioOf(context);
  final decodePx = (120 * dpr).clamp(64, 360).round();
  final urls = <String>[];
  for (final product in products) {
    if (urls.length >= limit) break;
    final raw = product.imageUrl.trim();
    if (!raw.toLowerCase().startsWith('https://')) continue;
    urls.add(catalogThumbnailUrl(raw, logicalSize: 120));
  }
  for (var i = 0; i < urls.length; i += batchSize) {
    if (!context.mounted) return;
    final slice = urls.skip(i).take(batchSize);
    await Future.wait(
      slice.map((url) {
        final provider = ResizeImage(
          CachedNetworkImageProvider(url),
          width: decodePx,
          height: decodePx,
        );
        return precacheImage(provider, context).then<void>(
          (_) {},
          onError: (Object error, StackTrace stack) {},
        );
      }),
    );
  }
}

/// Ejecuta la precarga una sola vez por conjunto de productos.
class CatalogImagePrefetch extends StatefulWidget {
  const CatalogImagePrefetch({
    required this.products,
    required this.child,
    super.key,
  });

  final List<CatalogProduct> products;
  final Widget child;

  @override
  State<CatalogImagePrefetch> createState() => _CatalogImagePrefetchState();
}

class _CatalogImagePrefetchState extends State<CatalogImagePrefetch> {
  String? _signature;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefetchIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CatalogImagePrefetch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prefetchIfNeeded();
  }

  void _prefetchIfNeeded() {
    final signature = widget.products
        .map((product) => '${product.id}:${product.imageUrl}')
        .join('|');
    if (signature == _signature || signature.isEmpty) return;
    _signature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      prefetchProductImages(context, widget.products);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
