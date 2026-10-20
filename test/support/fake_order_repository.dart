import 'package:app_mass/features/orders/domain/order_draft.dart';
import 'package:app_mass/features/orders/domain/order_repository.dart';
import 'package:app_mass/features/orders/domain/order_status.dart';
import 'package:app_mass/features/orders/domain/store_order.dart';

class FakeOrderRepository implements OrderRepository {
  final orders = <String, StoreOrder>{};
  final createdPayloads = <List<Map<String, Object>>>[];
  final createdKeys = <String, String>{};
  Object? error;

  @override
  Future<List<StoreOrder>> listOrders() async {
    _throwIfNeeded();
    return orders.values.toList();
  }

  @override
  Future<StoreOrder?> findOrder(String id) async {
    _throwIfNeeded();
    return orders[id];
  }

  @override
  Future<String> createOrder(OrderDraft draft) async {
    _throwIfNeeded();
    final existing = createdKeys[draft.idempotencyKey];
    if (existing != null) return existing;
    createdPayloads.add(orderItemsPayload(draft));
    final id = 'order-${createdKeys.length + 1}';
    createdKeys[draft.idempotencyKey] = id;
    return id;
  }

  @override
  Future<void> transition({
    required String orderId,
    required int expectedVersion,
    required OrderStatus target,
    String note = '',
  }) async {
    _throwIfNeeded();
    final current = orders[orderId];
    if (current == null) return;
    if (current.version != expectedVersion) {
      throw StateError('version');
    }
    orders[orderId] = StoreOrder(
      id: current.id,
      publicCode: current.publicCode,
      modality: current.modality,
      status: target,
      customerName: current.customerName,
      customerPhone: current.customerPhone,
      addressLine: current.addressLine,
      addressReference: current.addressReference,
      notes: current.notes,
      createdBy: current.createdBy,
      totalCents: current.totalCents,
      version: current.version + 1,
      createdAt: current.createdAt,
      items: current.items,
      events: current.events,
    );
  }

  @override
  Future<List<CourierOption>> listCouriers() async => const [];

  @override
  Future<void> assignCourier({
    required String orderId,
    required int expectedVersion,
    required String courierId,
  }) async {}

  @override
  Future<void> startDelivery({
    required String orderId,
    required int expectedVersion,
  }) async {}

  @override
  Future<void> recordResult({
    required String orderId,
    required int expectedVersion,
    required String outcome,
    String reason = '',
    String note = '',
  }) async {}

  @override
  Future<OperationsSummary> summary() async {
    return const OperationsSummary(countsByStatus: {}, total: 0);
  }

  @override
  Future<List<StaffMember>> listStaff() async => const [];

  @override
  Future<void> setStaffAccess({
    required String userId,
    required String role,
    required bool active,
    required String fullName,
  }) async {}

  @override
  Future<List<CustomerContact>> listContacts() async => const [];

  void _throwIfNeeded() {
    final failure = error;
    if (failure != null) throw failure;
  }
}
