import 'order_status.dart';

class OrderItem {
  const OrderItem({
    required this.productName,
    required this.quantity,
    required this.unitPriceCents,
    required this.lineTotalCents,
    this.imageUrl = '',
    this.category = '',
  });

  final String productName;
  final int quantity;
  final int unitPriceCents;
  final int lineTotalCents;
  final String imageUrl;
  final String category;
}

class OrderEvent {
  const OrderEvent({
    required this.action,
    required this.toStatus,
    required this.createdAt,
    this.fromStatus,
    this.note = '',
  });

  final String action;
  final String? fromStatus;
  final String toStatus;
  final String note;
  final DateTime createdAt;
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.publicCode,
    required this.modality,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.addressLine,
    required this.addressReference,
    required this.notes,
    required this.createdBy,
    required this.totalCents,
    required this.version,
    required this.createdAt,
    this.items = const [],
    this.events = const [],
  });

  final String id;
  final String publicCode;
  final OrderModality modality;
  final OrderStatus status;
  final String customerName;
  final String customerPhone;
  final String addressLine;
  final String addressReference;
  final String notes;
  final String createdBy;
  final int totalCents;
  final int version;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderEvent> events;
}

class CourierOption {
  const CourierOption({required this.id, required this.fullName});

  final String id;
  final String fullName;
}

class StaffMember {
  const StaffMember({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String fullName;
  final String role;
  final bool isActive;
}

class CustomerContact {
  const CustomerContact({
    required this.name,
    required this.phone,
    required this.orderCount,
  });

  final String name;
  final String phone;
  final int orderCount;
}

class OperationsSummary {
  const OperationsSummary({required this.countsByStatus, required this.total});

  final Map<String, int> countsByStatus;
  final int total;
}
