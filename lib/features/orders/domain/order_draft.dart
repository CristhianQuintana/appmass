import '../../catalog/domain/catalog_product.dart';
import 'order_status.dart';

class DraftLine {
  const DraftLine({required this.product, required this.quantity});

  final CatalogProduct product;
  final int quantity;

  int get lineTotalCents => product.priceCents * quantity;
}

class OrderDraft {
  const OrderDraft({
    required this.customerName,
    required this.customerPhone,
    required this.addressLine,
    required this.addressReference,
    required this.notes,
    required this.modality,
    required this.lines,
    required this.idempotencyKey,
  });

  final String customerName;
  final String customerPhone;
  final String addressLine;
  final String addressReference;
  final String notes;
  final OrderModality modality;
  final List<DraftLine> lines;
  final String idempotencyKey;

  factory OrderDraft.empty(String idempotencyKey) {
    return OrderDraft(
      customerName: '',
      customerPhone: '',
      addressLine: '',
      addressReference: '',
      notes: '',
      modality: OrderModality.inStore,
      lines: const [],
      idempotencyKey: idempotencyKey,
    );
  }

  int get totalCents => lines.fold(0, (sum, line) => sum + line.lineTotalCents);

  OrderDraft copyWith({
    String? customerName,
    String? customerPhone,
    String? addressLine,
    String? addressReference,
    String? notes,
    OrderModality? modality,
    List<DraftLine>? lines,
  }) {
    return OrderDraft(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      addressLine: addressLine ?? this.addressLine,
      addressReference: addressReference ?? this.addressReference,
      notes: notes ?? this.notes,
      modality: modality ?? this.modality,
      lines: lines ?? this.lines,
      idempotencyKey: idempotencyKey,
    );
  }

  /// Agrega o acumula. Un producto inactivo no entra al pedido.
  OrderDraft addProduct(CatalogProduct product) {
    if (!product.isActive) return this;
    final index = lines.indexWhere((line) => line.product.id == product.id);
    if (index == -1) {
      return copyWith(
        lines: [
          ...lines,
          DraftLine(product: product, quantity: 1),
        ],
      );
    }
    return changeQuantity(product.id, lines[index].quantity + 1);
  }

  OrderDraft changeQuantity(String productId, int quantity) {
    if (quantity > 99) return this;
    if (quantity < 1) {
      return copyWith(
        lines: lines.where((line) => line.product.id != productId).toList(),
      );
    }
    return copyWith(
      lines: [
        for (final line in lines)
          if (line.product.id == productId)
            DraftLine(product: line.product, quantity: quantity)
          else
            line,
      ],
    );
  }

  String? validate() {
    if (customerName.trim().isEmpty || customerName.trim().length > 120) {
      return 'Ingresa el nombre de contacto.';
    }
    if (lines.isEmpty) return 'Agrega al menos un producto.';
    if (modality == OrderModality.delivery) {
      final phone = customerPhone.trim();
      final address = addressLine.trim();
      if (phone.length < 6 || phone.length > 20) {
        return 'Ingresa un teléfono de contacto válido.';
      }
      if (address.length < 8 || address.length > 200) {
        return 'Ingresa una dirección suficiente para la entrega.';
      }
    }
    if (notes.trim().length > 400) return 'La observación es demasiado larga.';
    return null;
  }
}

/// El cliente solo envía producto y cantidad. El precio lo resuelve el servidor.
List<Map<String, Object>> orderItemsPayload(OrderDraft draft) {
  return [
    for (final line in draft.lines)
      {'product_id': line.product.id, 'quantity': line.quantity},
  ];
}
