import 'package:flutter/material.dart';

import '../../../app/theme/mass_colors.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../domain/money.dart';
import '../domain/order_status.dart';
import '../domain/store_order.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      OrderStatus.completed || OrderStatus.delivered => (
        MassColors.successContainer,
        MassColors.success,
      ),
      OrderStatus.cancelled || OrderStatus.deliveryFailed => (
        MassColors.dangerContainer,
        MassColors.onDanger,
      ),
      OrderStatus.inDelivery || OrderStatus.assigned => (
        const Color(0xFFE7EEFF),
        const Color(0xFF1D3F8A),
      ),
      _ => (MassColors.yellow, MassColors.ink),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        orderStatusLabel(status),
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MoneyText extends StatelessWidget {
  const MoneyText(this.cents, {this.emphasize = false, super.key});

  final int cents;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Text(
      Money(cents).label,
      style: TextStyle(
        color: MassColors.ink,
        fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
        fontSize: emphasize ? 20 : 14,
      ),
    );
  }
}

class SampleCatalogNotice extends StatelessWidget {
  const SampleCatalogNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Catálogo de prueba. No son precios oficiales de Tiendas MASS.',
      style: TextStyle(color: MassColors.muted, fontWeight: FontWeight.w600),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({required this.order, required this.onTap, super.key});

  final StoreOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProductArtwork(
                label: order.modality == OrderModality.delivery
                    ? 'entrega'
                    : 'abarrotes',
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.publicCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: MassColors.ink,
                            ),
                          ),
                        ),
                        StatusChip(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(order.customerName),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          modalityLabel(order.modality),
                          style: const TextStyle(color: MassColors.muted),
                        ),
                        const Spacer(),
                        MoneyText(order.totalCents),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AsyncFeedback extends StatelessWidget {
  const AsyncFeedback({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: MassColors.muted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
