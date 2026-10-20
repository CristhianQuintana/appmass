import '../../../core/errors/app_failure.dart';
import '../domain/order_draft.dart';
import '../domain/order_repository.dart';
import '../domain/order_status.dart';
import '../domain/store_order.dart';

class UnavailableOrderRepository implements OrderRepository {
  const UnavailableOrderRepository();

  @override
  Future<List<StoreOrder>> listOrders() async => const [];

  @override
  Future<StoreOrder?> findOrder(String id) async => null;

  @override
  Future<String> createOrder(OrderDraft draft) async {
    throw const ConfigurationFailure();
  }

  @override
  Future<void> transition({
    required String orderId,
    required int expectedVersion,
    required OrderStatus target,
    String note = '',
  }) async {
    throw const ConfigurationFailure();
  }

  @override
  Future<List<CourierOption>> listCouriers() async => const [];

  @override
  Future<void> assignCourier({
    required String orderId,
    required int expectedVersion,
    required String courierId,
  }) async {
    throw const ConfigurationFailure();
  }

  @override
  Future<void> startDelivery({
    required String orderId,
    required int expectedVersion,
  }) async {
    throw const ConfigurationFailure();
  }

  @override
  Future<void> recordResult({
    required String orderId,
    required int expectedVersion,
    required String outcome,
    String reason = '',
    String note = '',
  }) async {
    throw const ConfigurationFailure();
  }

  @override
  Future<OperationsSummary> summary() async {
    throw const ConfigurationFailure();
  }

  @override
  Future<List<StaffMember>> listStaff() async => const [];

  @override
  Future<void> setStaffAccess({
    required String userId,
    required String role,
    required bool active,
    required String fullName,
  }) async {
    throw const ConfigurationFailure();
  }

  @override
  Future<List<CustomerContact>> listContacts() async => const [];
}
