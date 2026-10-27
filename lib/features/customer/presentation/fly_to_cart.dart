import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/theme/mass_colors.dart';
import '../../catalog/presentation/product_artwork.dart';

/// Clave global del ícono del carrito en el AppBar del cliente.
final GlobalKey customerCartIconKey = GlobalKey(debugLabel: 'customer-cart-icon');

/// Anima una miniatura desde [fromKey] hasta el ícono del carrito.
Future<void> playFlyToCart({
  required BuildContext context,
  required GlobalKey fromKey,
  required String category,
  required String imageUrl,
}) async {
  final overlay = Overlay.maybeOf(context);
  final fromContext = fromKey.currentContext;
  final cartContext = customerCartIconKey.currentContext;
  if (overlay == null || fromContext == null || cartContext == null) return;

  final fromBox = fromContext.findRenderObject() as RenderBox?;
  final cartBox = cartContext.findRenderObject() as RenderBox?;
  if (fromBox == null || cartBox == null || !fromBox.hasSize || !cartBox.hasSize) {
    return;
  }

  final from = fromBox.localToGlobal(Offset.zero);
  final fromSize = fromBox.size;
  final cart = cartBox.localToGlobal(
    Offset(cartBox.size.width / 2, cartBox.size.height / 2),
  );

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return _FlyToCartOverlay(
        start: from,
        startSize: fromSize,
        end: cart,
        category: category,
        imageUrl: imageUrl,
        onDone: () => entry.remove(),
      );
    },
  );
  overlay.insert(entry);
  await Future<void>.delayed(const Duration(milliseconds: 620));
}

class _FlyToCartOverlay extends StatefulWidget {
  const _FlyToCartOverlay({
    required this.start,
    required this.startSize,
    required this.end,
    required this.category,
    required this.imageUrl,
    required this.onDone,
  });

  final Offset start;
  final Size startSize;
  final Offset end;
  final String category;
  final String imageUrl;
  final VoidCallback onDone;

  @override
  State<_FlyToCartOverlay> createState() => _FlyToCartOverlayState();
}

class _FlyToCartOverlayState extends State<_FlyToCartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 580),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _scale = Tween<double>(begin: 1, end: 0.18).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1, curve: Curves.easeIn),
      ),
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1, curve: Curves.easeIn),
      ),
    );
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final arc = Offset(
          lerpDouble(widget.start.dx, widget.end.dx, _t.value)!,
          lerpDouble(widget.start.dy, widget.end.dy, _t.value)! -
              (1 - (2 * _t.value - 1).abs()) * 72,
        );
        final size = widget.startSize.shortestSide * _scale.value;
        return Positioned(
          left: arc.dx,
          top: arc.dy,
          child: Opacity(
            opacity: _opacity.value,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: size.clamp(18, 120),
                height: size.clamp(18, 120),
                child: ProductArtwork(
                  label: widget.category,
                  imageUrl: widget.imageUrl,
                  expand: true,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void showAddedToCartSnack(
  BuildContext context, {
  required String productName,
  VoidCallback? onViewCart,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text('$productName agregado al carrito'),
      action: onViewCart == null
          ? null
          : SnackBarAction(
              label: 'Ver',
              textColor: MassColors.yellow,
              onPressed: onViewCart,
            ),
    ),
  );
}
