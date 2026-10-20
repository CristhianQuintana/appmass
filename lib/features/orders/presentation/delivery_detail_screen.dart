import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../delivery/domain/maps_link.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../application/order_providers.dart';
import '../domain/order_rules.dart';
import '../domain/store_order.dart';
import 'order_widgets.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  const DeliveryDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<DeliveryDetailScreen> createState() =>
      _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  static const _rules = OrderRules();
  String? _message;
  bool _busy = false;
  String _reason = 'customer_absent';
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

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
    final maps = deliveryMapsUri(order.addressLine);
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
                ),
              ),
            ),
            const MassHelpIcon(
              message: 'Abre el mapa con la dirección y registra si la entrega se completó o no.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        StatusChip(status: order.status),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const ProductArtwork(label: 'entrega', size: 72),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (order.customerPhone.isNotEmpty)
                        Text(order.customerPhone),
                      if (order.addressLine.isNotEmpty) Text(order.addressLine),
                      if (order.addressReference.isNotEmpty)
                        Text(order.addressReference),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final item in order.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ProductArtwork(label: item.productName, size: 48),
            title: Text(item.productName),
            trailing: Text('${item.quantity}'),
          ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          MassNotice(message: _message!),
        ],
        const SizedBox(height: 16),
        if (maps == null)
          const Text(
            'La dirección no es suficiente para abrir el mapa.',
            style: TextStyle(color: MassColors.muted),
          )
        else
          MassButton(
            label: 'Abrir en el mapa',
            icon: Icons.map,
            onPressed: () => _openMaps(maps),
          ),
        if (_rules.canStartDelivery(order.status)) ...[
          const SizedBox(height: 12),
          MassButton(
            label: 'Iniciar reparto',
            isLoading: _busy,
            onPressed: () => _start(order),
          ),
        ],
        if (_rules.canRecordResult(order.status)) ...[
          const SizedBox(height: 12),
          MassButton(
            label: 'Marcar entregado',
            isLoading: _busy,
            onPressed: () => _result(order, 'delivered'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _reason,
            decoration: const InputDecoration(
              labelText: 'Motivo si no se entrega',
            ),
            items: [
              for (final entry in deliveryFailureReasons.entries)
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _reason = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLength: 400,
            decoration: const InputDecoration(labelText: 'Nota'),
          ),
          MassButton(
            label: 'Registrar entrega fallida',
            isLoading: _busy,
            onPressed: () => _result(order, 'failed', reason: _reason),
          ),
        ],
      ],
    );
  }

  Future<void> _openMaps(Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        setState(() => _message = const UnexpectedFailure().userMessage);
      }
    } on Object {
      if (!mounted) return;
      setState(() => _message = const UnexpectedFailure().userMessage);
    }
  }

  Future<void> _start(StoreOrder order) async {
    await _run(() {
      return ref
          .read(orderRepositoryProvider)
          .startDelivery(orderId: order.id, expectedVersion: order.version);
    });
  }

  Future<void> _result(
    StoreOrder order,
    String outcome, {
    String reason = '',
  }) async {
    await _run(() {
      return ref
          .read(orderRepositoryProvider)
          .recordResult(
            orderId: order.id,
            expectedVersion: order.version,
            outcome: outcome,
            reason: reason,
            note: _note.text,
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
