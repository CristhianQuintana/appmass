import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_help_icon.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../catalog/domain/catalog_product.dart';
import '../../catalog/presentation/product_artwork.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/domain/staff_role.dart';
import '../application/order_providers.dart';
import '../domain/money.dart';
import 'order_widgets.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogListProvider);
    final isAdmin =
        ref.watch(profileControllerProvider).asData?.value?.role ==
        StaffRole.administrator;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MassSectionTitle(
                title: 'Catálogo',
                help: 'Busca un producto por nombre o código. Los precios de prueba no son oficiales.',
              ),
              const SizedBox(height: 8),
              const SampleCatalogNotice(),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                decoration: const InputDecoration(
                  labelText: 'Buscar por nombre o código',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    ref.read(catalogQueryProvider.notifier).setQuery(value);
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: catalog.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AsyncFeedback(
              message: userFacingMessage(error),
              onRetry: () => ref.invalidate(catalogListProvider),
            ),
            data: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 72),
                      SizedBox(height: 12),
                      Text('No hay productos para esta búsqueda.'),
                    ],
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onOpen: isAdmin ? () => _edit(product) : null,
                  );
                },
              );
            },
          ),
        ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.all(16),
            child: MassButton(
              label: 'Nuevo producto',
              icon: Icons.add,
              onPressed: () => _edit(null),
            ),
          ),
      ],
    );
  }

  Future<void> _edit(CatalogProduct? product) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _ProductEditor(product: product),
    );
    if (saved == true) ref.invalidate(catalogListProvider);
  }
}

class _ProductEditor extends ConsumerStatefulWidget {
  const _ProductEditor({required this.product});

  final CatalogProduct? product;

  @override
  ConsumerState<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends ConsumerState<_ProductEditor> {
  late final TextEditingController _sku;
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _unit;
  late final TextEditingController _price;
  late bool _active;
  String? _message;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _sku = TextEditingController(text: product?.sku ?? '');
    _name = TextEditingController(text: product?.name ?? '');
    _category = TextEditingController(text: product?.category ?? 'General');
    _unit = TextEditingController(text: product?.unitLabel ?? 'unidad');
    _price = TextEditingController(
      text: product == null ? '' : _priceLabel(product.priceCents),
    );
    _active = product?.isActive ?? true;
  }

  @override
  void dispose() {
    _sku.dispose();
    _name.dispose();
    _category.dispose();
    _unit.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.product == null ? 'Nuevo producto' : 'Editar producto',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SampleCatalogNotice(),
            const SizedBox(height: 12),
            TextField(
              controller: _sku,
              decoration: const InputDecoration(labelText: 'Código'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _unit,
              decoration: const InputDecoration(labelText: 'Unidad'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Precio en soles'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activo'),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
            if (_message != null) MassNotice(message: _message!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Guardando' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final cents = parseSolesToCents(_price.text);
    if (cents == null) {
      setState(() => _message = 'Ingresa un precio válido, por ejemplo 4.50.');
      return;
    }
    final input = ProductInput(
      id: widget.product?.id,
      sku: _sku.text,
      name: _name.text,
      description: widget.product?.description ?? '',
      category: _category.text,
      unitLabel: _unit.text,
      priceCents: cents,
      isActive: _active,
    );
    final validation = input.validate();
    if (validation != null) {
      setState(() => _message = validation);
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref.read(catalogRepositoryProvider).saveProduct(input);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _message = userFacingMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

String _priceLabel(int cents) {
  final soles = cents ~/ 100;
  final fraction = (cents % 100).toString().padLeft(2, '0');
  return '$soles.$fraction';
}
