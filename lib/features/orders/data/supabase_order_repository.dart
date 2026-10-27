import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/order_draft.dart';
import '../domain/order_repository.dart';
import '../domain/order_status.dart';
import '../domain/store_order.dart';
import 'order_row_mapper.dart';
import 'remote_error.dart';

class SupabaseOrderRepository implements OrderRepository {
  SupabaseOrderRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<StoreOrder>> listOrders() {
    return guardRemote(() async {
      final rows = await _client
          .from('orders')
          .select(
            'id, public_code, modality, status, customer_name, customer_phone, address_line, address_reference, notes, created_by, total_cents, version, created_at, order_items(product_name, quantity, unit_price_cents, line_total_cents, products(image_url, category))',
          )
          .order('created_at', ascending: false)
          .limit(50);
      return [for (final row in rows) mapOrderRow(row)];
    });
  }

  @override
  Future<StoreOrder?> findOrder(String id) {
    return guardRemote(() async {
      final row = await _client
          .from('orders')
          .select(
            'id, public_code, modality, status, customer_name, customer_phone, address_line, address_reference, notes, created_by, total_cents, version, created_at, order_items(product_name, quantity, unit_price_cents, line_total_cents, products(image_url, category))',
          )
          .eq('id', id)
          .maybeSingle();
      if (row == null) return null;
      final events = await _client
          .from('order_events')
          .select('action, from_status, to_status, note, created_at')
          .eq('order_id', id)
          .order('created_at');
      final order = mapOrderRow(row);
      return StoreOrder(
        id: order.id,
        publicCode: order.publicCode,
        modality: order.modality,
        status: order.status,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        addressLine: order.addressLine,
        addressReference: order.addressReference,
        notes: order.notes,
        createdBy: order.createdBy,
        totalCents: order.totalCents,
        version: order.version,
        createdAt: order.createdAt,
        items: order.items,
        events: [for (final event in events) mapEventRow(event)],
      );
    });
  }

  @override
  Future<String> createOrder(OrderDraft draft) {
    return guardRemote(() async {
      final id = await _client.rpc(
        'create_order',
        params: {
          'p_idempotency_key': draft.idempotencyKey,
          'p_modality': modalityToStorage(draft.modality),
          'p_customer_name': draft.customerName.trim(),
          'p_customer_phone': draft.customerPhone.trim(),
          'p_address': draft.addressLine.trim(),
          'p_reference': draft.addressReference.trim(),
          'p_notes': draft.notes.trim(),
          'p_items': orderItemsPayload(draft),
        },
      );
      if (id is! String || id.isEmpty) {
        throw const UnexpectedFailure();
      }
      return id;
    });
  }

  @override
  Future<void> transition({
    required String orderId,
    required int expectedVersion,
    required OrderStatus target,
    String note = '',
  }) {
    return guardRemote(() async {
      await _client.rpc(
        'transition_order',
        params: {
          'p_order_id': orderId,
          'p_expected_version': expectedVersion,
          'p_target_status': orderStatusToStorage(target),
          'p_note': note.trim(),
        },
      );
    });
  }

  @override
  Future<List<CourierOption>> listCouriers() {
    return guardRemote(() async {
      final rows = await _client.rpc('list_couriers');
      if (rows is! List) return const [];
      return [
        for (final row in rows)
          CourierOption(
            id: _text(_asMap(row), 'id'),
            fullName: _text(_asMap(row), 'full_name'),
          ),
      ];
    });
  }

  @override
  Future<void> assignCourier({
    required String orderId,
    required int expectedVersion,
    required String courierId,
  }) {
    return guardRemote(() async {
      await _client.rpc(
        'assign_courier',
        params: {
          'p_order_id': orderId,
          'p_expected_version': expectedVersion,
          'p_courier_id': courierId,
        },
      );
    });
  }

  @override
  Future<void> startDelivery({
    required String orderId,
    required int expectedVersion,
  }) {
    return guardRemote(() async {
      await _client.rpc(
        'start_delivery',
        params: {'p_order_id': orderId, 'p_expected_version': expectedVersion},
      );
    });
  }

  @override
  Future<void> recordResult({
    required String orderId,
    required int expectedVersion,
    required String outcome,
    String reason = '',
    String note = '',
  }) {
    return guardRemote(() async {
      await _client.rpc(
        'record_delivery_result',
        params: {
          'p_order_id': orderId,
          'p_expected_version': expectedVersion,
          'p_outcome': outcome,
          'p_reason': reason,
          'p_note': note.trim(),
        },
      );
    });
  }

  @override
  Future<OperationsSummary> summary() {
    return guardRemote(() async {
      final row = await _client.rpc('operational_summary');
      if (row is! Map) throw const UnexpectedFailure();
      final data = Map<String, dynamic>.from(row);
      final counts = data['counts'];
      if (counts is! Map) throw const UnexpectedFailure();
      return OperationsSummary(
        total: _count(data['total']),
        countsByStatus: {
          for (final entry in counts.entries)
            if (entry.key is String) entry.key as String: _count(entry.value),
        },
      );
    });
  }

  @override
  Future<List<StaffMember>> listStaff() {
    return guardRemote(() async {
      final rows = await _client.rpc('list_staff');
      if (rows is! List) return const [];
      return [
        for (final raw in rows)
          StaffMember(
            id: _text(_asMap(raw), 'id'),
            fullName: _text(_asMap(raw), 'full_name'),
            role: _text(_asMap(raw), 'role'),
            isActive: _flag(_asMap(raw), 'is_active'),
          ),
      ];
    });
  }

  @override
  Future<void> setStaffAccess({
    required String userId,
    required String role,
    required bool active,
    required String fullName,
  }) {
    return guardRemote(() async {
      await _client.rpc(
        'admin_set_staff_access',
        params: {
          'p_user_id': userId,
          'p_role': role,
          'p_active': active,
          'p_full_name': fullName.trim(),
        },
      );
    });
  }

  @override
  Future<List<CustomerContact>> listContacts() {
    return guardRemote(() async {
      final rows = await _client.rpc('list_order_contacts');
      if (rows is! List) return const [];
      return [
        for (final raw in rows)
          CustomerContact(
            name: _text(_asMap(raw), 'customer_name'),
            phone: _text(_asMap(raw), 'customer_phone'),
            orderCount: _count(_asMap(raw)['order_count']),
          ),
      ];
    });
  }
}

Map<String, dynamic> _asMap(Object? row) {
  if (row is Map<String, dynamic>) return row;
  if (row is Map) return Map<String, dynamic>.from(row);
  throw const ValidationFailure('La respuesta del servicio está incompleta.');
}

String _text(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is String) return value;
  throw const ValidationFailure('La respuesta del servicio está incompleta.');
}

bool _flag(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is bool) return value;
  throw const ValidationFailure('La respuesta del servicio está incompleta.');
}

int _count(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const ValidationFailure('La respuesta del servicio está incompleta.');
}
