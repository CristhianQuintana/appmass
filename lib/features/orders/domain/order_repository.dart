import 'order_draft.dart';
import 'order_status.dart';
import 'store_order.dart';

abstract class OrderRepository {
  Future<List<StoreOrder>> listOrders();

  Future<StoreOrder?> findOrder(String id);

  Future<String> createOrder(OrderDraft draft);

  Future<void> transition({
    required String orderId,
    required int expectedVersion,
    required OrderStatus target,
    String note = '',
  });

  Future<List<CourierOption>> listCouriers();

  Future<void> assignCourier({
    required String orderId,
    required int expectedVersion,
    required String courierId,
  });

  Future<void> startDelivery({
    required String orderId,
    required int expectedVersion,
  });

  Future<void> recordResult({
    required String orderId,
    required int expectedVersion,
    required String outcome,
    String reason = '',
    String note = '',
  });

  Future<OperationsSummary> summary();

  Future<List<StaffMember>> listStaff();

  Future<void> setStaffAccess({
    required String userId,
    required String role,
    required bool active,
    required String fullName,
  });

  Future<List<CustomerContact>> listContacts();
}
