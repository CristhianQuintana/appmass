import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mass_colors.dart';
import '../../../core/widgets/mass_button.dart';
import '../../orders/domain/money.dart';
import '../application/customer_catalog_filters.dart';

Future<void> showCustomerFilterSheet(
  BuildContext context, {
  required List<String> categories,
  required int catalogMinCents,
  required int catalogMaxCents,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: MassColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _CustomerFilterSheet(
          categories: categories,
          catalogMinCents: catalogMinCents,
          catalogMaxCents: catalogMaxCents,
        ),
      );
    },
  );
}

class _CustomerFilterSheet extends ConsumerStatefulWidget {
  const _CustomerFilterSheet({
    required this.categories,
    required this.catalogMinCents,
    required this.catalogMaxCents,
  });

  final List<String> categories;
  final int catalogMinCents;
  final int catalogMaxCents;

  @override
  ConsumerState<_CustomerFilterSheet> createState() =>
      _CustomerFilterSheetState();
}

class _CustomerFilterSheetState extends ConsumerState<_CustomerFilterSheet> {
  late RangeValues _price;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(customerCatalogFiltersProvider);
    final min = widget.catalogMinCents.toDouble();
    final max = widget.catalogMaxCents
        .clamp(widget.catalogMinCents + 1, 100000)
        .toDouble();
    _price = RangeValues(
      filters.minPriceCents.clamp(min, max).toDouble(),
      filters.maxPriceCents.clamp(min, max).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(customerCatalogFiltersProvider);
    final notifier = ref.read(customerCatalogFiltersProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: MassColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Afina precio, ofertas, unidad y orden del catálogo.',
              style: TextStyle(color: MassColors.muted),
            ),
            const SizedBox(height: 20),
            const _Label('Ordenar por'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sort in CatalogSort.values)
                  ChoiceChip(
                    label: Text(_sortLabel(sort)),
                    selected: filters.sort == sort,
                    onSelected: (_) => notifier.setSort(sort),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const _Label('Precio'),
            RangeSlider(
              values: _price,
              min: widget.catalogMinCents.toDouble(),
              max: widget.catalogMaxCents
                  .clamp(widget.catalogMinCents + 1, 100000)
                  .toDouble(),
              labels: RangeLabels(
                Money(_price.start.round()).label,
                Money(_price.end.round()).label,
              ),
              activeColor: MassColors.yellowDim,
              onChanged: (value) => setState(() => _price = value),
              onChangeEnd: (value) => notifier.setPriceRange(
                value.start.round(),
                value.end.round(),
              ),
            ),
            Row(
              children: [
                Text(
                  Money(_price.start.round()).label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  Money(_price.end.round()).label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Solo ofertas',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('Productos con descuento vigente'),
              value: filters.offersOnly,
              activeThumbColor: MassColors.ink,
              activeTrackColor: MassColors.yellow,
              onChanged: notifier.setOffersOnly,
            ),
            const SizedBox(height: 8),
            const _Label('Unidad de venta'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final unit in UnitFilter.values)
                  ChoiceChip(
                    label: Text(_unitLabel(unit)),
                    selected: filters.unit == unit,
                    onSelected: (_) => notifier.setUnit(unit),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const _Label('Categorías'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in widget.categories)
                  FilterChip(
                    label: Text(category),
                    selected: filters.categories.contains(category),
                    onSelected: (_) => notifier.toggleCategory(category),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      notifier.reset();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MassButton(
                    label: 'Aplicar',
                    onPressed: () {
                      notifier.setPriceRange(
                        _price.start.round(),
                        _price.end.round(),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _sortLabel(CatalogSort sort) {
    return switch (sort) {
      CatalogSort.relevance => 'Relevancia',
      CatalogSort.priceAsc => 'Menor precio',
      CatalogSort.priceDesc => 'Mayor precio',
      CatalogSort.nameAsc => 'Nombre A-Z',
    };
  }

  String _unitLabel(UnitFilter unit) {
    return switch (unit) {
      UnitFilter.all => 'Todas',
      UnitFilter.piece => 'Por unidad',
      UnitFilter.weight => 'Por kilo',
    };
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 15,
        color: MassColors.ink,
      ),
    );
  }
}
