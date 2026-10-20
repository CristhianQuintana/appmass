import 'dart:async';

import '../../core/errors/app_failure.dart';
import '../authentication/domain/auth_identity.dart';
import '../authentication/domain/password_reset_outcome.dart';
import '../catalog/domain/catalog_product.dart';
import '../orders/domain/order_draft.dart';
import '../orders/domain/order_rules.dart';
import '../orders/domain/order_status.dart';
import '../orders/domain/store_order.dart';
import '../profile/domain/staff_profile.dart';
import '../profile/domain/staff_role.dart';
import 'demo_accounts.dart';

/// Copia local de la operación. No abre red ni guarda secretos.
class SimulationStore {
  SimulationStore.seeded() {
    _products.addAll(_sampleProducts);
    _orders.addAll(_sampleOrders());
  }

  final _session = StreamController<AuthIdentity?>.broadcast();
  final _profiles = <String, StaffProfile>{
    for (final account in demoAccounts)
      account.id: StaffProfile(
        id: account.id,
        fullName: account.fullName,
        role: account.role,
        isActive: true,
      ),
    'inactive-1': const StaffProfile(
      id: 'inactive-1',
      fullName: 'Nora Inactiva',
      role: StaffRole.unassigned,
      isActive: false,
    ),
  };
  final _products = <CatalogProduct>[];
  final _orders = <StoreOrder>[];
  final _assignments = <String, String>{
    'order-assigned': 'courier-1',
    'order-delivery': 'courier-1',
  };
  final _idempotency = <String, String>{};
  AuthIdentity? current;
  var _orderSequence = 20;

  Stream<AuthIdentity?> watchSession() async* {
    yield current;
    yield* _session.stream;
  }

  Future<void> signIn({required String email, required String password}) async {
    final account = demoAccounts.cast<DemoAccount?>().firstWhere(
      (item) => item!.email == email.trim().toLowerCase(),
      orElse: () => null,
    );
    if (account == null || password != demoPassword) {
      throw const InvalidCredentialsFailure();
    }
    current = AuthIdentity(id: account.id, email: account.email);
    _session.add(current);
  }

  Future<void> signOut() async {
    current = null;
    _session.add(null);
  }

  Future<PasswordResetOutcome> requestPasswordReset({
    required String email,
  }) async {
    return PasswordResetOutcome.accepted;
  }

  Future<StaffProfile?> ownProfile() async {
    final id = current?.id;
    if (id == null) return null;
    return _profiles[id];
  }

  Future<List<CatalogProduct>> search({
    required String query,
    required bool includeInactive,
  }) async {
    _requireRole(const {
      StaffRole.administrator,
      StaffRole.operator,
      StaffRole.customer,
    });
    if (includeInactive) _requireRole(const {StaffRole.administrator});
    final term = sanitizeCatalogQuery(query).toLowerCase();
    return [
      for (final product in _products)
        if ((includeInactive || product.isActive) &&
            (term.isEmpty ||
                product.name.toLowerCase().contains(term) ||
                product.sku.toLowerCase().contains(term)))
          product,
    ];
  }

  Future<String> saveProduct(ProductInput input) async {
    _requireRole(const {StaffRole.administrator});
    final validation = input.validate();
    if (validation != null) throw ValidationFailure(validation);
    if (_products.any(
      (product) =>
          product.sku.toLowerCase() == input.sku.trim().toLowerCase() &&
          product.id != input.id,
    )) {
      throw const ValidationFailure('Ya existe un registro con ese código.');
    }
    if (input.id == null) {
      final id = 'product-$_orderSequence';
      _orderSequence += 1;
      _products.add(
        CatalogProduct(
          id: id,
          sku: input.sku.trim(),
          name: input.name.trim(),
          description: input.description.trim(),
          category: input.category.trim(),
          unitLabel: input.unitLabel.trim(),
          priceCents: input.priceCents,
          isActive: input.isActive,
          isSample: true,
        ),
      );
      return id;
    }
    final index = _products.indexWhere((product) => product.id == input.id);
    if (index == -1) throw const NotFoundFailure();
    final current = _products[index];
    _products[index] = CatalogProduct(
      id: current.id,
      sku: input.sku.trim(),
      name: input.name.trim(),
      description: input.description.trim(),
      category: input.category.trim(),
      unitLabel: input.unitLabel.trim(),
      priceCents: input.priceCents,
      isActive: input.isActive,
      isSample: current.isSample,
    );
    return current.id;
  }

  Future<List<StoreOrder>> listOrders() async {
    final actor = _actor();
    final visible = _visibleOrders(actor);
    visible.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return visible;
  }

  Future<StoreOrder?> findOrder(String id) async {
    final actor = _actor();
    final matches = _visibleOrders(actor).where((order) => order.id == id);
    if (matches.isEmpty) return null;
    return matches.first;
  }

  Future<String> createOrder(OrderDraft draft) async {
    final actor = _actor();
    _requireRole(const {
      StaffRole.administrator,
      StaffRole.operator,
      StaffRole.customer,
    });
    final validation = draft.validate();
    if (validation != null) throw ValidationFailure(validation);
    final existing = _idempotency['${actor.id}|${draft.idempotencyKey}'];
    if (existing != null) return existing;

    final items = <OrderItem>[];
    var total = 0;
    for (final line in draft.lines) {
      final product = _products.cast<CatalogProduct?>().firstWhere(
        (item) => item!.id == line.product.id && item.isActive,
        orElse: () => null,
      );
      if (product == null || line.quantity < 1 || line.quantity > 99) {
        throw const ValidationFailure('Revisa los productos del pedido.');
      }
      final lineTotal = product.priceCents * line.quantity;
      total += lineTotal;
      items.add(
        OrderItem(
          productName: product.name,
          quantity: line.quantity,
          unitPriceCents: product.priceCents,
          lineTotalCents: lineTotal,
        ),
      );
    }

    final id = 'order-$_orderSequence';
    _orderSequence += 1;
    final now = DateTime.now();
    _orders.add(
      StoreOrder(
        id: id,
        publicCode: 'PED-DEMO-${id.substring(id.length - 4).toUpperCase()}',
        modality: draft.modality,
        status: OrderStatus.submitted,
        customerName: draft.customerName.trim(),
        customerPhone: draft.customerPhone.trim(),
        addressLine: draft.addressLine.trim(),
        addressReference: draft.addressReference.trim(),
        notes: draft.notes.trim(),
        createdBy: actor.id,
        totalCents: total,
        version: 1,
        createdAt: now,
        items: items,
        events: [
          OrderEvent(
            action: 'create',
            toStatus: orderStatusToStorage(OrderStatus.submitted),
            createdAt: now,
          ),
        ],
      ),
    );
    _idempotency['${actor.id}|${draft.idempotencyKey}'] = id;
    return id;
  }

  Future<void> transition({
    required String orderId,
    required int expectedVersion,
    required OrderStatus target,
    String note = '',
  }) async {
    _requireRole(const {StaffRole.administrator, StaffRole.operator});
    final order = _requireOrder(orderId, expectedVersion);
    final rules = const OrderRules();
    final allowed =
        rules.preparationTarget(order.status, order.modality) == target ||
        (rules.canCancel(order.status) && target == OrderStatus.cancelled);
    if (!allowed) throw const ValidationFailure();
    if (target == OrderStatus.cancelled && note.trim().length < 3) {
      throw const ValidationFailure('Escribe el motivo de la cancelación.');
    }
    _replace(order, status: target, note: note.trim(), action: 'transition');
  }

  Future<List<CourierOption>> listCouriers() async {
    _requireRole(const {StaffRole.administrator, StaffRole.operator});
    return [
      for (final profile in _profiles.values)
        if (profile.role == StaffRole.courier && profile.isActive)
          CourierOption(id: profile.id, fullName: profile.displayName),
    ];
  }

  Future<void> assignCourier({
    required String orderId,
    required int expectedVersion,
    required String courierId,
  }) async {
    _requireRole(const {StaffRole.administrator, StaffRole.operator});
    final courier = _profiles[courierId];
    if (courier == null ||
        courier.role != StaffRole.courier ||
        !courier.isActive) {
      throw const ValidationFailure('El transportista no está disponible.');
    }
    final order = _requireOrder(orderId, expectedVersion);
    if (!const OrderRules().canAssign(order.status, order.modality)) {
      throw const ValidationFailure();
    }
    _assignments[orderId] = courierId;
    _replace(order, status: OrderStatus.assigned, action: 'assign');
  }

  Future<void> startDelivery({
    required String orderId,
    required int expectedVersion,
  }) async {
    final actor = _requireRole(const {StaffRole.courier});
    final order = _requireOrder(orderId, expectedVersion);
    if (_assignments[orderId] != actor.id ||
        order.status != OrderStatus.assigned) {
      throw const UnauthorizedFailure();
    }
    _replace(order, status: OrderStatus.inDelivery, action: 'start_delivery');
  }

  Future<void> recordResult({
    required String orderId,
    required int expectedVersion,
    required String outcome,
    String reason = '',
    String note = '',
  }) async {
    final actor = _requireRole(const {StaffRole.courier});
    if (_assignments[orderId] != actor.id) throw const UnauthorizedFailure();
    final order = _orders.cast<StoreOrder?>().firstWhere(
      (item) => item!.id == orderId,
      orElse: () => null,
    );
    if (order == null) throw const NotFoundFailure();
    if (outcome == 'delivered' && order.status == OrderStatus.completed) return;
    if (outcome == 'failed' && order.status == OrderStatus.deliveryFailed) {
      return;
    }
    if (order.version != expectedVersion) throw const ConflictFailure();
    if (order.status != OrderStatus.inDelivery) throw const ValidationFailure();
    if (outcome == 'delivered') {
      _replace(order, status: OrderStatus.completed, action: 'complete');
      return;
    }
    if (outcome != 'failed' || !isAllowedFailureReason(reason)) {
      throw const ValidationFailure('Elige un motivo de la lista.');
    }
    _replace(
      order,
      status: OrderStatus.deliveryFailed,
      action: 'delivery_failed',
      note: reason,
    );
  }

  Future<OperationsSummary> summary() async {
    _requireRole(const {StaffRole.administrator});
    final counts = <String, int>{};
    for (final order in _orders) {
      final key = orderStatusToStorage(order.status);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return OperationsSummary(countsByStatus: counts, total: _orders.length);
  }

  Future<List<StaffMember>> listStaff() async {
    _requireRole(const {StaffRole.administrator});
    return [
      for (final profile in _profiles.values)
        if (profile.role != StaffRole.customer)
          StaffMember(
            id: profile.id,
            fullName: profile.fullName,
            role: profile.role.name,
            isActive: profile.isActive,
          ),
    ];
  }

  Future<void> setStaffAccess({
    required String userId,
    required String role,
    required bool active,
    required String fullName,
  }) async {
    final actor = _requireRole(const {StaffRole.administrator});
    if (userId == actor.id) throw const UnauthorizedFailure();
    final current = _profiles[userId];
    if (current == null) throw const NotFoundFailure();
    if (fullName.trim().isEmpty || fullName.trim().length > 120) {
      throw const ValidationFailure('Ingresa un nombre válido.');
    }
    final parsed = StaffRole.fromStorage(role);
    if (parsed == StaffRole.customer ||
        (parsed == StaffRole.unassigned && role != 'unassigned')) {
      throw const ValidationFailure('Ese rol no se asigna desde personal.');
    }
    _profiles[userId] = StaffProfile(
      id: userId,
      fullName: fullName.trim(),
      role: parsed,
      isActive: active,
    );
  }

  Future<List<CustomerContact>> listContacts() async {
    _requireRole(const {StaffRole.administrator});
    final counts = <String, int>{};
    final phones = <String, String>{};
    for (final order in _orders) {
      final key = '${order.customerName}|${order.customerPhone}';
      counts[key] = (counts[key] ?? 0) + 1;
      phones[key] = order.customerPhone;
    }
    return [
      for (final entry in counts.entries)
        CustomerContact(
          name: entry.key.split('|').first,
          phone: phones[entry.key] ?? '',
          orderCount: entry.value,
        ),
    ];
  }

  void dispose() {
    _session.close();
  }

  StaffProfile _actor() {
    final id = current?.id;
    final profile = id == null ? null : _profiles[id];
    if (profile == null || !profile.isOperational) {
      throw const UnauthorizedFailure();
    }
    return profile;
  }

  StaffProfile _requireRole(Set<StaffRole> roles) {
    final actor = _actor();
    if (!roles.contains(actor.role)) throw const UnauthorizedFailure();
    return actor;
  }

  List<StoreOrder> _visibleOrders(StaffProfile actor) {
    if (actor.role == StaffRole.courier) {
      return [
        for (final order in _orders)
          if (_assignments[order.id] == actor.id) order,
      ];
    }
    if (actor.role == StaffRole.customer) {
      return [
        for (final order in _orders)
          if (order.createdBy == actor.id) order,
      ];
    }
    return List<StoreOrder>.of(_orders);
  }

  StoreOrder _requireOrder(String id, int expectedVersion) {
    final order = _orders.cast<StoreOrder?>().firstWhere(
      (item) => item!.id == id,
      orElse: () => null,
    );
    if (order == null) throw const NotFoundFailure();
    if (order.version != expectedVersion) throw const ConflictFailure();
    return order;
  }

  void _replace(
    StoreOrder order, {
    required OrderStatus status,
    required String action,
    String note = '',
  }) {
    final index = _orders.indexWhere((item) => item.id == order.id);
    final now = DateTime.now();
    _orders[index] = StoreOrder(
      id: order.id,
      publicCode: order.publicCode,
      modality: order.modality,
      status: status,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      addressLine: order.addressLine,
      addressReference: order.addressReference,
      notes: order.notes,
      createdBy: order.createdBy,
      totalCents: order.totalCents,
      version: order.version + 1,
      createdAt: order.createdAt,
      items: order.items,
      events: [
        ...order.events,
        OrderEvent(
          action: action,
          fromStatus: orderStatusToStorage(order.status),
          toStatus: orderStatusToStorage(status),
          note: note,
          createdAt: now,
        ),
      ],
    );
  }
}

const _sampleProducts = <CatalogProduct>[
  CatalogProduct(
    id: '11111111-1111-4111-8111-111111111111',
    sku: 'PRB-001',
    name: 'Agua de mesa 625 ml',
    description: 'Dato de prueba',
    category: 'Bebidas',
    unitLabel: 'botella',
    priceCents: 150,
    isActive: true,
    isSample: true,
  ),
  CatalogProduct(
    id: '22222222-2222-4222-8222-222222222222',
    sku: 'PRB-002',
    name: 'Pan de molde',
    description: 'Dato de prueba',
    category: 'Panadería',
    unitLabel: 'bolsa',
    priceCents: 750,
    isActive: true,
    isSample: true,
  ),
  CatalogProduct(
    id: '33333333-3333-4333-8333-333333333333',
    sku: 'PRB-003',
    name: 'Leche evaporada',
    description: 'Dato de prueba',
    category: 'Lácteos',
    unitLabel: 'tarro',
    priceCents: 420,
    isActive: true,
    isSample: true,
  ),
  CatalogProduct(
    id: '44444444-4444-4444-8444-444444444444',
    sku: 'PRB-004',
    name: 'Arroz extra 1 kg',
    description: 'Dato de prueba',
    category: 'Abarrotes',
    unitLabel: 'bolsa',
    priceCents: 450,
    isActive: true,
    isSample: true,
  ),
  CatalogProduct(
    id: '55555555-5555-4555-8555-555555555555',
    sku: 'PRB-005',
    name: 'Aceite vegetal 1 L',
    description: 'Dato de prueba',
    category: 'Abarrotes',
    unitLabel: 'botella',
    priceCents: 890,
    isActive: true,
    isSample: true,
  ),
  CatalogProduct(
    id: '66666666-6666-4666-8666-666666666666',
    sku: 'PRB-006',
    name: 'Gaseosa cola 500 ml',
    description: 'Producto inactivo de prueba',
    category: 'Bebidas',
    unitLabel: 'botella',
    priceCents: 250,
    isActive: false,
    isSample: true,
  ),
  CatalogProduct(
    id: '77777777-7777-4777-8777-777777777777',
    sku: 'PRB-007',
    name: 'Detergente 400 g',
    description: 'Dato de prueba',
    category: 'Limpieza',
    unitLabel: 'bolsa',
    priceCents: 320,
    isActive: true,
    isSample: true,
  ),
  CatalogProduct(
    id: '88888888-8888-4888-8888-888888888888',
    sku: 'PRB-008',
    name: 'Huevos x 10',
    description: 'Dato de prueba',
    category: 'Abarrotes',
    unitLabel: 'maple',
    priceCents: 800,
    isActive: true,
    isSample: true,
  ),
];

List<StoreOrder> _sampleOrders() {
  OrderItem item(String name, int quantity, int price) {
    return OrderItem(
      productName: name,
      quantity: quantity,
      unitPriceCents: price,
      lineTotalCents: quantity * price,
    );
  }

  StoreOrder order({
    required String id,
    required String code,
    required OrderModality modality,
    required OrderStatus status,
    required String customer,
    required String phone,
    required String address,
    required List<OrderItem> items,
    required DateTime createdAt,
    String createdBy = 'operator-1',
  }) {
    final total = items.fold<int>(0, (sum, line) => sum + line.lineTotalCents);
    return StoreOrder(
      id: id,
      publicCode: code,
      modality: modality,
      status: status,
      customerName: customer,
      customerPhone: phone,
      addressLine: address,
      addressReference: '',
      notes: '',
      createdBy: createdBy,
      totalCents: total,
      version: 1,
      createdAt: createdAt,
      items: items,
      events: [
        OrderEvent(
          action: 'create',
          toStatus: orderStatusToStorage(OrderStatus.submitted),
          createdAt: createdAt,
        ),
      ],
    );
  }

  return [
    order(
      id: 'order-submitted',
      code: 'PED-DEMO-1001',
      modality: OrderModality.inStore,
      status: OrderStatus.submitted,
      customer: 'Rosa Mendoza',
      phone: '987111222',
      address: '',
      items: [item('Pan de molde', 1, 750), item('Leche evaporada', 2, 420)],
      createdAt: DateTime(2026, 10, 15, 9, 10),
      createdBy: 'customer-1',
    ),
    order(
      id: 'order-preparing',
      code: 'PED-DEMO-1002',
      modality: OrderModality.inStore,
      status: OrderStatus.preparing,
      customer: 'Carlos Vega',
      phone: '987111333',
      address: '',
      items: [item('Arroz extra 1 kg', 2, 450)],
      createdAt: DateTime(2026, 10, 15, 9, 40),
    ),
    order(
      id: 'order-ready',
      code: 'PED-DEMO-1003',
      modality: OrderModality.delivery,
      status: OrderStatus.readyForDispatch,
      customer: 'Lucía Torres',
      phone: '987111444',
      address: 'Jr. Ayacucho 123, Huancayo',
      items: [item('Aceite vegetal 1 L', 1, 890), item('Huevos x 10', 1, 800)],
      createdAt: DateTime(2026, 10, 15, 10, 5),
    ),
    order(
      id: 'order-assigned',
      code: 'PED-DEMO-1004',
      modality: OrderModality.delivery,
      status: OrderStatus.assigned,
      customer: 'Pedro Ramos',
      phone: '987111555',
      address: 'Av. Ferrocarril 450, Huancayo',
      items: [item('Detergente 400 g', 3, 320)],
      createdAt: DateTime(2026, 10, 15, 10, 30),
    ),
    order(
      id: 'order-delivery',
      code: 'PED-DEMO-1005',
      modality: OrderModality.delivery,
      status: OrderStatus.inDelivery,
      customer: 'Elena Cruz',
      phone: '987111666',
      address: 'Calle Real 890, El Tambo',
      items: [item('Agua de mesa 625 ml', 6, 150)],
      createdAt: DateTime(2026, 10, 15, 11),
    ),
    order(
      id: 'order-closed',
      code: 'PED-DEMO-1006',
      modality: OrderModality.inStore,
      status: OrderStatus.completed,
      customer: 'Jorge Paredes',
      phone: '987111777',
      address: '',
      items: [item('Pan de molde', 2, 750)],
      createdAt: DateTime(2026, 10, 15, 8, 20),
    ),
  ];
}
