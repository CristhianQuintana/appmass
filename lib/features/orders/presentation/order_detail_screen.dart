import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../application/order_providers.dart';
import '../domain/order_rules.dart';
import '../domain/order_status.dart';
import '../domain/store_order.dart';
import 'order_widgets.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  static const _rules = OrderRules();
  String? _message;
  bool _busy = false;
  String? _courierId;

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderDetailProvider(widget.orderId));
    return order.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AsyncFeedback(
        message: userFacingMessage(error),
        onRetry: () => ref.invalidate(orderDetailProvider(widget.orderId)),
      ),
      data: (value) {
        if (value == null) {
          return const AsyncFeedback(
            message: 'No se encontró el pedido o no tienes acceso a él.',
          );
        }
        return _content(value);
      },
    );
  }

  Widget _content(StoreOrder order) {
    final next = _rules.preparationTarget(order.status, order.modality);
    final couriers = _rules.canAssign(order.status, order.modality)
        ? ref.watch(couriersProvider)
        : const AsyncData<List<CourierOption>>([]);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                order.publicCode,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: MassColors.ink,
                ),
              ),
            ),
            StatusChip(status: order.status),
            const MassHelpIcon(
              message: 'Avanza el pedido solo al siguiente paso. El cambio lo confirma el servidor.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(modalityLabel(order.modality)),
        const SizedBox(height: 16),
        Text(
          order.customerName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        if (order.customerPhone.isNotEmpty) Text(order.customerPhone),
        if (order.addressLine.isNotEmpty) Text(order.addressLine),
        if (order.addressReference.isNotEmpty) Text(order.addressReference),
        if (order.notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(order.notes),
        ],
        const SizedBox(height: 16),
        for (final item in order.items)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: ProductArtwork(label: item.productName, size: 48),
              title: Text(item.productName),
              subtitle: Text('${item.quantity}'),
              trailing: MoneyText(item.lineTotalCents),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: MoneyText(order.totalCents, emphasize: true),
        ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          MassNotice(message: _message!),
        ],
        if (next != null) ...[
          const SizedBox(height: 16),
          MassButton(
            label: orderStatusLabel(next),
            isLoading: _busy,
            onPressed: () => _transition(order, next),
          ),
        ],
        if (_rules.canCancel(order.status)) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy ? null : () => _cancel(order),
            child: const Text('Cancelar pedido'),
          ),
        ],
        if (_rules.canAssign(order.status, order.modality)) ...[
          const SizedBox(height: 16),
          couriers.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text(userFacingMessage(error)),
            data: (options) {
              if (options.isEmpty) {
                return const Text('No hay transportistas activos.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _courierId,
                    decoration: const InputDecoration(
                      labelText: 'Transportista',
                    ),
                    items: [
                      for (final option in options)
                        DropdownMenuItem(
                          value: option.id,
                          child: Text(option.fullName),
                        ),
                    ],
                    onChanged: (value) => setState(() => _courierId = value),
                  ),
                  const SizedBox(height: 12),
                  MassButton(
                    label: order.status == OrderStatus.assigned
                        ? 'Reasignar'
                        : 'Asignar',
                    isLoading: _busy,
                    onPressed: _courierId == null
                        ? null
                        : () => _assign(order, _courierId!),
                  ),
                ],
              );
            },
          ),
        ],
        if (order.events.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Historial',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final event in order.events)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_statusLabel(event.toStatus)}'
                '${event.note.isEmpty ? '' : ' · ${event.note}'}',
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _transition(StoreOrder order, OrderStatus target) async {
    await _run(() {
      return ref
          .read(orderRepositoryProvider)
          .transition(
            orderId: order.id,
            expectedVersion: order.version,
            target: target,
          );
    });
  }

  Future<void> _assign(StoreOrder order, String courierId) async {
    await _run(() {
      return ref
          .read(orderRepositoryProvider)
          .assignCourier(
            orderId: order.id,
            expectedVersion: order.version,
            courierId: courierId,
          );
    });
  }

  Future<void> _cancel(StoreOrder order) async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => const _CancelDialog(),
    );
    if (note == null) return;
    await _run(() {
      return ref
          .read(orderRepositoryProvider)
          .transition(
            orderId: order.id,
            expectedVersion: order.version,
            target: OrderStatus.cancelled,
            note: note,
          );
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
      ref.invalidate(orderDetailProvider(widget.orderId));
      ref.invalidate(ordersListProvider);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _message = userFacingMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

String _statusLabel(String storage) {
  try {
    return orderStatusLabel(orderStatusFromStorage(storage));
  } on FormatException {
    return 'Actualización';
  }
}

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _note = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancelar pedido'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'Motivo'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: const TextStyle(color: MassColors.onDanger)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
        TextButton(
          onPressed: () {
            if (_note.text.trim().length < 3) {
              setState(() => _message = 'Escribe un motivo breve.');
              return;
            }
            Navigator.pop(context, _note.text.trim());
          },
          child: const Text('Cancelar pedido'),
        ),
      ],
    );
  }
}
