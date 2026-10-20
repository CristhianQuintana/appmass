import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/auth_providers.dart';
import '../../authentication/application/session_controller.dart';
import '../../catalog/data/supabase_catalog_repository.dart';
import '../../catalog/data/unavailable_catalog_repository.dart';
import '../../catalog/domain/catalog_product.dart';
import '../../profile/application/profile_controller.dart';
import '../../simulation/demo_mode.dart';
import '../../simulation/simulated_repositories.dart';
import '../../profile/domain/staff_role.dart';
import '../data/supabase_order_repository.dart';
import '../data/unavailable_order_repository.dart';
import '../domain/idempotency_key.dart';
import '../domain/order_draft.dart';
import '../domain/order_repository.dart';
import '../domain/order_status.dart';
import '../domain/store_order.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  if (ref.watch(demoModeProvider)) {
    return SimulatedCatalogRepository(ref.watch(simulationStoreProvider));
  }
  final startup = ref.watch(startupProvider);
  if (!startup.canUseSupabase) return const UnavailableCatalogRepository();
  return SupabaseCatalogRepository(ref.watch(supabaseClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  if (ref.watch(demoModeProvider)) {
    return SimulatedOrderRepository(ref.watch(simulationStoreProvider));
  }
  final startup = ref.watch(startupProvider);
  if (!startup.canUseSupabase) return const UnavailableOrderRepository();
  return SupabaseOrderRepository(ref.watch(supabaseClientProvider));
});

final catalogQueryProvider = NotifierProvider<CatalogQueryController, String>(
  CatalogQueryController.new,
);

class CatalogQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = sanitizeCatalogQuery(value);
}

final catalogListProvider = FutureProvider<List<CatalogProduct>>((ref) async {
  final query = ref.watch(catalogQueryProvider);
  final role = ref.watch(profileControllerProvider).asData?.value?.role;
  return ref
      .watch(catalogRepositoryProvider)
      .search(query: query, includeInactive: role == StaffRole.administrator);
});

final ordersListProvider = FutureProvider<List<StoreOrder>>((ref) async {
  ref.watch(
    sessionControllerProvider.select((session) => session.identity?.id),
  );
  return ref.watch(orderRepositoryProvider).listOrders();
});

final orderDetailProvider = FutureProvider.family<StoreOrder?, String>((
  ref,
  id,
) async {
  ref.watch(
    sessionControllerProvider.select((session) => session.identity?.id),
  );
  return ref.watch(orderRepositoryProvider).findOrder(id);
});

final couriersProvider = FutureProvider<List<CourierOption>>((ref) async {
  return ref.watch(orderRepositoryProvider).listCouriers();
});

final staffListProvider = FutureProvider<List<StaffMember>>((ref) async {
  return ref.watch(orderRepositoryProvider).listStaff();
});

class AdminHomeData {
  const AdminHomeData({required this.summary, required this.contacts});

  final OperationsSummary summary;
  final List<CustomerContact> contacts;
}

final adminHomeProvider = FutureProvider<AdminHomeData>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  final summary = await repository.summary();
  final contacts = await repository.listContacts();
  return AdminHomeData(summary: summary, contacts: contacts);
});

final draftControllerProvider = NotifierProvider<DraftController, OrderDraft>(
  DraftController.new,
);

class DraftController extends Notifier<OrderDraft> {
  @override
  OrderDraft build() => OrderDraft.empty(newIdempotencyKey());

  void setCustomerName(String value) =>
      state = state.copyWith(customerName: value);

  void setCustomerPhone(String value) =>
      state = state.copyWith(customerPhone: value);

  void setAddressLine(String value) =>
      state = state.copyWith(addressLine: value);

  void setAddressReference(String value) =>
      state = state.copyWith(addressReference: value);

  void setNotes(String value) => state = state.copyWith(notes: value);

  void setModality(OrderModality modality) =>
      state = state.copyWith(modality: modality);

  void addProduct(CatalogProduct product) => state = state.addProduct(product);

  void changeQuantity(String productId, int quantity) =>
      state = state.changeQuantity(productId, quantity);

  void reset() => state = OrderDraft.empty(newIdempotencyKey());
}
