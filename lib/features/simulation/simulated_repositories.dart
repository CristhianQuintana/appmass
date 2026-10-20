import '../authentication/domain/auth_identity.dart';
import '../authentication/domain/auth_repository.dart';
import '../authentication/domain/password_reset_outcome.dart';
import '../catalog/domain/catalog_product.dart';
import '../orders/domain/order_draft.dart';
import '../orders/domain/order_repository.dart';
import '../orders/domain/order_status.dart';
import '../orders/domain/store_order.dart';
import '../profile/domain/profile_repository.dart';
import '../profile/domain/staff_profile.dart';
import 'simulation_store.dart';

class SimulatedAuthRepository implements AuthRepository {
  SimulatedAuthRepository(this._store);

  final SimulationStore _store;

  @override
  Stream<AuthIdentity?> watchSession() => _store.watchSession();

  @override
  Future<void> signIn({required String email, required String password}) {
    return _store.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() => _store.signOut();

  @override
  Future<PasswordResetOutcome> requestPasswordReset({required String email}) {
    return _store.requestPasswordReset(email: email);
  }
}

class SimulatedProfileRepository implements ProfileRepository {
  SimulatedProfileRepository(this._store);

  final SimulationStore _store;

  @override
  Future<StaffProfile?> fetchOwnProfile() => _store.ownProfile();
}

class SimulatedCatalogRepository implements CatalogRepository {
  SimulatedCatalogRepository(this._store);

  final SimulationStore _store;

  @override
  Future<List<CatalogProduct>> search({
    required String query,
    required bool includeInactive,
  }) {
    return _store.search(query: query, includeInactive: includeInactive);
  }

  @override
  Future<String> saveProduct(ProductInput input) => _store.saveProduct(input);
}

class SimulatedOrderRepository implements OrderRepository {
  SimulatedOrderRepository(this._store);

  final SimulationStore _store;

  @override
  Future<List<StoreOrder>> listOrders() => _store.listOrders();

  @override
  Future<StoreOrder?> findOrder(String id) => _store.findOrder(id);

  @override
  Future<String> createOrder(OrderDraft draft) => _store.createOrder(draft);

  @override
  Future<void> transition({
    required String orderId,
    required int expectedVersion,
    required OrderStatus target,
    String note = '',
  }) {
    return _store.transition(
      orderId: orderId,
      expectedVersion: expectedVersion,
      target: target,
      note: note,
    );
  }

  @override
  Future<List<CourierOption>> listCouriers() => _store.listCouriers();

  @override
  Future<void> assignCourier({
    required String orderId,
    required int expectedVersion,
    required String courierId,
  }) {
    return _store.assignCourier(
      orderId: orderId,
      expectedVersion: expectedVersion,
      courierId: courierId,
    );
  }

  @override
  Future<void> startDelivery({
    required String orderId,
    required int expectedVersion,
  }) {
    return _store.startDelivery(
      orderId: orderId,
      expectedVersion: expectedVersion,
    );
  }

  @override
  Future<void> recordResult({
    required String orderId,
    required int expectedVersion,
    required String outcome,
    String reason = '',
    String note = '',
  }) {
    return _store.recordResult(
      orderId: orderId,
      expectedVersion: expectedVersion,
      outcome: outcome,
      reason: reason,
      note: note,
    );
  }

  @override
  Future<OperationsSummary> summary() => _store.summary();

  @override
  Future<List<StaffMember>> listStaff() => _store.listStaff();

  @override
  Future<void> setStaffAccess({
    required String userId,
    required String role,
    required bool active,
    required String fullName,
  }) {
    return _store.setStaffAccess(
      userId: userId,
      role: role,
      active: active,
      fullName: fullName,
    );
  }

  @override
  Future<List<CustomerContact>> listContacts() => _store.listContacts();
}
