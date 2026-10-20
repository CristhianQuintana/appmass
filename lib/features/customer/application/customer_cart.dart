import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/session_controller.dart';
import '../../catalog/domain/catalog_product.dart';
import '../../orders/domain/idempotency_key.dart';
import '../../orders/domain/order_draft.dart';

class CustomerCart {
  const CustomerCart({required this.lines, required this.idempotencyKey});

  final List<DraftLine> lines;
  final String idempotencyKey;

  int get quantity => lines.fold(0, (sum, line) => sum + line.quantity);

  int get totalCents => lines.fold(0, (sum, line) => sum + line.lineTotalCents);
}

class CustomerCartController extends Notifier<CustomerCart> {
  @override
  CustomerCart build() {
    ref.listen(sessionControllerProvider, (previous, next) {
      if (previous?.identity?.id != next.identity?.id) {
        state = CustomerCart(
          lines: const [],
          idempotencyKey: newIdempotencyKey(),
        );
      }
    });
    return CustomerCart(lines: const [], idempotencyKey: newIdempotencyKey());
  }

  void add(CatalogProduct product) {
    if (!product.isActive) return;
    final index = state.lines.indexWhere(
      (line) => line.product.id == product.id,
    );
    if (index == -1) {
      state = CustomerCart(
        lines: [
          ...state.lines,
          DraftLine(product: product, quantity: 1),
        ],
        idempotencyKey: state.idempotencyKey,
      );
      return;
    }
    change(product.id, state.lines[index].quantity + 1);
  }

  void change(String productId, int quantity) {
    if (quantity > 99) return;
    state = CustomerCart(
      lines: [
        for (final line in state.lines)
          if (line.product.id != productId)
            line
          else if (quantity >= 1)
            DraftLine(product: line.product, quantity: quantity),
      ],
      idempotencyKey: state.idempotencyKey,
    );
  }

  void clear() {
    state = CustomerCart(lines: const [], idempotencyKey: newIdempotencyKey());
  }
}

final customerCartProvider =
    NotifierProvider<CustomerCartController, CustomerCart>(
      CustomerCartController.new,
    );
