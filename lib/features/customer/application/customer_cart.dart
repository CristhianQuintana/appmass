import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/auth_providers.dart';
import '../../authentication/application/session_controller.dart';
import '../../catalog/domain/catalog_product.dart';
import '../../orders/domain/idempotency_key.dart';
import '../../orders/domain/order_draft.dart';
import '../../simulation/demo_mode.dart';
import '../data/supabase_cart_repository.dart';

class CustomerCart {
  const CustomerCart({required this.lines, required this.idempotencyKey});

  final List<DraftLine> lines;
  final String idempotencyKey;

  int get quantity => lines.fold(0, (sum, line) => sum + line.quantity);

  int get totalCents => lines.fold(0, (sum, line) => sum + line.lineTotalCents);
}

final cartRepositoryProvider = Provider((ref) {
  if (ref.watch(demoModeProvider)) return const LocalCartRepository();
  final startup = ref.watch(startupProvider);
  if (!startup.canUseSupabase) return const LocalCartRepository();
  return SupabaseCartRepository(ref.watch(supabaseClientProvider));
});

class CustomerCartController extends Notifier<CustomerCart> {
  @override
  CustomerCart build() {
    ref.listen(sessionControllerProvider, (previous, next) {
      if (previous?.identity?.id != next.identity?.id) {
        state = CustomerCart(
          lines: const [],
          idempotencyKey: newIdempotencyKey(),
        );
        if (next.identity != null) {
          Future.microtask(reload);
        }
      }
    });
    Future.microtask(reload);
    return CustomerCart(lines: const [], idempotencyKey: newIdempotencyKey());
  }

  Future<void> reload() async {
    final session = ref.read(sessionControllerProvider);
    if (session.identity == null) return;
    final repository = ref.read(cartRepositoryProvider);
    if (repository is LocalCartRepository) return;
    try {
      final lines = await (repository as SupabaseCartRepository).listItems();
      state = CustomerCart(lines: lines, idempotencyKey: state.idempotencyKey);
    } on Object {
      // El carrito local sigue usable si la sincronización falla.
    }
  }

  void add(CatalogProduct product, {int quantity = 1}) {
    if (!product.isActive || quantity < 1) return;
    final index = state.lines.indexWhere(
      (line) => line.product.id == product.id,
    );
    if (index == -1) {
      final qty = quantity.clamp(1, 99);
      state = CustomerCart(
        lines: [
          ...state.lines,
          DraftLine(product: product, quantity: qty),
        ],
        idempotencyKey: state.idempotencyKey,
      );
      _persist(product.id, qty);
      return;
    }
    change(product.id, state.lines[index].quantity + quantity);
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
    _persist(productId, quantity < 1 ? 0 : quantity);
  }

  void clear() {
    state = CustomerCart(lines: const [], idempotencyKey: newIdempotencyKey());
    final repository = ref.read(cartRepositoryProvider);
    if (repository is SupabaseCartRepository) {
      repository.clear().ignore();
    }
  }

  void _persist(String productId, int quantity) {
    final repository = ref.read(cartRepositoryProvider);
    if (repository is SupabaseCartRepository) {
      repository.upsert(productId: productId, quantity: quantity).ignore();
    }
  }
}

extension on Future<void> {
  void ignore() {
    then((_) {}, onError: (_) {});
  }
}

final customerCartProvider =
    NotifierProvider<CustomerCartController, CustomerCart>(
      CustomerCartController.new,
    );
