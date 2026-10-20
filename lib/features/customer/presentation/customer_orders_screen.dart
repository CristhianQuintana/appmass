import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/order_status.dart';
import '../../orders/presentation/order_widgets.dart';

class CustomerOrdersScreen extends ConsumerWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersListProvider);
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: MassSectionTitle(
            title: 'Mis pedidos',
            help: 'Aquí ves solo tus pedidos y el estado que registra el personal.',
          ),
        ),
        Expanded(
          child: orders.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AsyncFeedback(
              message: userFacingMessage(error),
              onRetry: () => ref.invalidate(ordersListProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 72,
                        color: MassColors.muted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Todavía no tienes pedidos.',
                        style: TextStyle(color: MassColors.muted),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final order = items[index];
                  return OrderSummaryCard(
                    order: order,
                    onTap: () => context.go(
                      '${AppRoutes.customerHome}/pedido/${order.id}',
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

class CustomerOrderScreen extends ConsumerWidget {
  const CustomerOrderScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));
    return order.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncFeedback(
        message: userFacingMessage(error),
        onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
      ),
      data: (value) {
        if (value == null) {
          return const Center(child: Text('No encontramos ese pedido.'));
        }
        final steps = value.modality == OrderModality.delivery
            ? const [
                OrderStatus.submitted,
                OrderStatus.preparing,
                OrderStatus.readyForDispatch,
                OrderStatus.assigned,
                OrderStatus.inDelivery,
                OrderStatus.completed,
              ]
            : const [
                OrderStatus.submitted,
                OrderStatus.preparing,
                OrderStatus.readyForPickup,
                OrderStatus.completed,
              ];
        final current = steps.indexOf(value.status);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    value.publicCode,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                StatusChip(status: value.status),
              ],
            ),
            const SizedBox(height: 16),
            if (current >= 0)
              for (var index = 0; index < steps.length; index++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    index <= current
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: index <= current
                        ? MassColors.success
                        : MassColors.muted,
                  ),
                  title: Text(orderStatusLabel(steps[index])),
                )
            else
              const Text(
                'Este pedido ya no sigue el recorrido habitual.',
                style: TextStyle(color: MassColors.muted),
              ),
            const SizedBox(height: 8),
            for (final item in value.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ProductArtwork(label: item.productName, size: 48),
                title: Text(item.productName),
                trailing: Text('${item.quantity}'),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: MoneyText(value.totalCents, emphasize: true),
            ),
          ],
        );
      },
    );
  }
}
