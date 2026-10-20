import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/order_draft.dart';
import '../../orders/domain/order_status.dart';
import '../../orders/presentation/order_widgets.dart';
import '../../profile/application/profile_controller.dart';
import '../application/customer_cart.dart';

class CustomerCartScreen extends ConsumerStatefulWidget {
  const CustomerCartScreen({super.key});

  @override
  ConsumerState<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends ConsumerState<CustomerCartScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  var _modality = OrderModality.inStore;
  var _submitting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).asData?.value;
    _name = TextEditingController(text: profile?.displayName ?? '');
    _phone = TextEditingController();
    _address = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(customerCartProvider);
    if (cart.lines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: MassColors.muted,
            ),
            SizedBox(height: 12),
            Text(
              'El carrito está vacío.',
              style: TextStyle(color: MassColors.muted),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const MassSectionTitle(
          title: 'Carrito',
          help: 'Revisa los productos y confirma el pedido. No hay cobro en la aplicación.',
        ),
        const SizedBox(height: 12),
        for (final line in cart.lines)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  ProductArtwork(label: line.product.category, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      line.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Quitar uno',
                    onPressed: () => ref
                        .read(customerCartProvider.notifier)
                        .change(line.product.id, line.quantity - 1),
                    icon: const Icon(Icons.remove),
                  ),
                  Text('${line.quantity}'),
                  IconButton(
                    tooltip: 'Agregar uno',
                    onPressed: () => ref
                        .read(customerCartProvider.notifier)
                        .change(line.product.id, line.quantity + 1),
                    icon: const Icon(Icons.add),
                  ),
                  MoneyText(line.lineTotalCents),
                ],
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: MoneyText(cart.totalCents, emphasize: true),
        ),
        const SizedBox(height: 4),
        const Text(
          'El servidor confirma el importe. No se suma envío.',
          style: TextStyle(color: MassColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('customer-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('customer-phone'),
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Teléfono'),
        ),
        const SizedBox(height: 12),
        SegmentedButton<OrderModality>(
          segments: const [
            ButtonSegment(
              value: OrderModality.inStore,
              label: Text('Presencial'),
              icon: Icon(Icons.storefront),
            ),
            ButtonSegment(
              value: OrderModality.delivery,
              label: Text('Domicilio'),
              icon: Icon(Icons.local_shipping),
            ),
          ],
          selected: {_modality},
          onSelectionChanged: (value) =>
              setState(() => _modality = value.first),
        ),
        if (_modality == OrderModality.delivery) ...[
          const SizedBox(height: 12),
          TextField(
            key: const Key('customer-address'),
            controller: _address,
            decoration: const InputDecoration(labelText: 'Dirección'),
          ),
        ],
        if (_message != null) ...[
          const SizedBox(height: 12),
          MassNotice(message: _message!),
        ],
        const SizedBox(height: 16),
        MassButton(
          buttonKey: const Key('customer-confirm'),
          label: 'Confirmar pedido',
          isLoading: _submitting,
          onPressed: _confirm,
        ),
      ],
    );
  }

  Future<void> _confirm() async {
    final cart = ref.read(customerCartProvider);
    final draft = OrderDraft(
      customerName: _name.text,
      customerPhone: _phone.text,
      addressLine: _modality == OrderModality.delivery ? _address.text : '',
      addressReference: '',
      notes: '',
      modality: _modality,
      lines: cart.lines,
      idempotencyKey: cart.idempotencyKey,
    );
    final validation = draft.validate();
    if (validation != null) {
      setState(() => _message = validation);
      return;
    }
    setState(() {
      _submitting = true;
      _message = null;
    });
    try {
      final id = await ref.read(orderRepositoryProvider).createOrder(draft);
      ref.read(customerCartProvider.notifier).clear();
      ref.invalidate(ordersListProvider);
      if (!mounted) return;
      context.go('${AppRoutes.customerHome}/pedido/$id');
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = userFacingMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
