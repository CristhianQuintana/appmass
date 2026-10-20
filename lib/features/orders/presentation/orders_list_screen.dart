import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/domain/staff_role.dart';
import '../application/order_providers.dart';
import '../domain/store_order.dart';
import 'order_widgets.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({this.courierView = false, super.key});

  final bool courierView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersListProvider);
    final role = ref.watch(profileControllerProvider).asData?.value?.role;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          child: MassSectionTitle(
            title: courierView ? 'Entregas' : 'Pedidos',
            help: courierView
                ? 'Selecciona un pedido para consultar su dirección y registrar el resultado de la entrega.'
                : 'Selecciona un pedido para ver su estado y continuar la preparación.',
          ),
        ),
        Expanded(child: _orders(context, ref, orders, role)),
      ],
    );
  }

  Widget _orders(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<StoreOrder>> orders,
    StaffRole? role,
  ) {
    return orders.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncFeedback(
        message: userFacingMessage(error),
        onRetry: () => ref.invalidate(ordersListProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    courierView
                        ? Icons.local_shipping_outlined
                        : Icons.receipt_long,
                    size: 72,
                    color: MassColors.muted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    courierView
                        ? 'No tienes entregas asignadas.'
                        : 'Todavía no hay pedidos.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: MassColors.muted),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(ordersListProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final order = items[index];
              return OrderSummaryCard(
                order: order,
                onTap: () {
                  if (role == null) return;
                  final home = AppRoutes.homeFor(role);
                  final target = courierView
                      ? '$home/entrega/${order.id}'
                      : '$home/pedido/${order.id}';
                  context.go(target);
                },
              );
            },
          ),
        );
      },
    );
  }
}
