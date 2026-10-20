import 'dart:async';

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
import '../../profile/application/profile_controller.dart';
import '../application/order_providers.dart';
import '../domain/order_status.dart';
import 'order_widgets.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  final _search = TextEditingController();
  Timer? _debounce;
  String? _message;
  bool _submitting = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _reference.dispose();
    _notes.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(draftControllerProvider);
    final catalog = ref.watch(catalogListProvider);
    final delivery = draft.modality == OrderModality.delivery;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const MassSectionTitle(
          title: 'Nuevo pedido',
          help: 'Selecciona los productos que formarán parte del pedido.',
        ),
        const SizedBox(height: 8),
        const SampleCatalogNotice(),
        const SizedBox(height: 16),
        SegmentedButton<OrderModality>(
          segments: const [
            ButtonSegment(
              value: OrderModality.inStore,
              label: Text('Presencial'),
            ),
            ButtonSegment(
              value: OrderModality.delivery,
              label: Text('A domicilio'),
            ),
          ],
          selected: {draft.modality},
          onSelectionChanged: (selection) {
            ref
                .read(draftControllerProvider.notifier)
                .setModality(selection.first);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('order-customer-name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre de contacto'),
          onChanged: ref.read(draftControllerProvider.notifier).setCustomerName,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Teléfono'),
          onChanged: ref
              .read(draftControllerProvider.notifier)
              .setCustomerPhone,
        ),
        if (delivery) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: const InputDecoration(
              labelText: 'Dirección de entrega',
            ),
            onChanged: ref
                .read(draftControllerProvider.notifier)
                .setAddressLine,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reference,
            decoration: const InputDecoration(labelText: 'Referencia'),
            onChanged: ref
                .read(draftControllerProvider.notifier)
                .setAddressReference,
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLength: 400,
          decoration: const InputDecoration(labelText: 'Observación'),
          onChanged: ref.read(draftControllerProvider.notifier).setNotes,
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('order-product-search'),
          controller: _search,
          decoration: const InputDecoration(
            labelText: 'Buscar producto',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 300), () {
              ref.read(catalogQueryProvider.notifier).setQuery(value);
            });
          },
        ),
        const SizedBox(height: 12),
        catalog.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(userFacingMessage(error)),
          data: (products) {
            if (products.isEmpty) {
              return const Text('No hay productos para esta búsqueda.');
            }
            return SizedBox(
              height: 236,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: 168,
                    child: ProductCard(
                      product: product,
                      onAdd: () => ref
                          .read(draftControllerProvider.notifier)
                          .addProduct(product),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        for (final line in draft.lines)
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
                        .read(draftControllerProvider.notifier)
                        .changeQuantity(line.product.id, line.quantity - 1),
                    icon: const Icon(Icons.remove),
                  ),
                  Text('${line.quantity}'),
                  IconButton(
                    tooltip: 'Agregar uno',
                    onPressed: () => ref
                        .read(draftControllerProvider.notifier)
                        .changeQuantity(line.product.id, line.quantity + 1),
                    icon: const Icon(Icons.add),
                  ),
                  MoneyText(line.lineTotalCents),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: MoneyText(draft.totalCents, emphasize: true),
        ),
        const SizedBox(height: 4),
        const Text(
          'El servidor confirma el importe.',
          style: TextStyle(color: MassColors.muted, fontSize: 12),
        ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          MassNotice(message: _message!),
        ],
        const SizedBox(height: 16),
        MassButton(
          buttonKey: const Key('order-submit'),
          label: 'Registrar pedido',
          isLoading: _submitting,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final draft = ref.read(draftControllerProvider);
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
      ref.read(draftControllerProvider.notifier).reset();
      ref.invalidate(ordersListProvider);
      _clearFields();
      if (!mounted) return;
      final role = ref.read(profileControllerProvider).asData?.value?.role;
      if (role == null) return;
      context.go('${AppRoutes.homeFor(role)}/pedido/$id');
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _message = userFacingMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _clearFields() {
    _name.clear();
    _phone.clear();
    _address.clear();
    _reference.clear();
    _notes.clear();
    _search.clear();
    ref.read(catalogQueryProvider.notifier).setQuery('');
  }
}
