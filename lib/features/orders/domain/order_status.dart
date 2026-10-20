enum OrderModality { inStore, delivery }

enum OrderStatus {
  submitted,
  preparing,
  readyForPickup,
  readyForDispatch,
  assigned,
  inDelivery,
  delivered,
  completed,
  cancelled,
  deliveryFailed,
}

OrderModality modalityFromStorage(String value) {
  return switch (value) {
    'in_store' => OrderModality.inStore,
    'delivery' => OrderModality.delivery,
    _ => throw FormatException('Modalidad desconocida.'),
  };
}

String modalityToStorage(OrderModality modality) {
  return switch (modality) {
    OrderModality.inStore => 'in_store',
    OrderModality.delivery => 'delivery',
  };
}

OrderStatus orderStatusFromStorage(String value) {
  return switch (value) {
    'submitted' => OrderStatus.submitted,
    'preparing' => OrderStatus.preparing,
    'ready_for_pickup' => OrderStatus.readyForPickup,
    'ready_for_dispatch' => OrderStatus.readyForDispatch,
    'assigned' => OrderStatus.assigned,
    'in_delivery' => OrderStatus.inDelivery,
    'delivered' => OrderStatus.delivered,
    'completed' => OrderStatus.completed,
    'cancelled' => OrderStatus.cancelled,
    'delivery_failed' => OrderStatus.deliveryFailed,
    _ => throw FormatException('Estado desconocido.'),
  };
}

String orderStatusToStorage(OrderStatus status) {
  return switch (status) {
    OrderStatus.submitted => 'submitted',
    OrderStatus.preparing => 'preparing',
    OrderStatus.readyForPickup => 'ready_for_pickup',
    OrderStatus.readyForDispatch => 'ready_for_dispatch',
    OrderStatus.assigned => 'assigned',
    OrderStatus.inDelivery => 'in_delivery',
    OrderStatus.delivered => 'delivered',
    OrderStatus.completed => 'completed',
    OrderStatus.cancelled => 'cancelled',
    OrderStatus.deliveryFailed => 'delivery_failed',
  };
}

String orderStatusLabel(OrderStatus status) {
  return switch (status) {
    OrderStatus.submitted => 'Solicitado',
    OrderStatus.preparing => 'En preparación',
    OrderStatus.readyForPickup => 'Listo para atención',
    OrderStatus.readyForDispatch => 'Listo para despacho',
    OrderStatus.assigned => 'Asignado',
    OrderStatus.inDelivery => 'En reparto',
    OrderStatus.delivered => 'Entregado',
    OrderStatus.completed => 'Cerrado',
    OrderStatus.cancelled => 'Cancelado',
    OrderStatus.deliveryFailed => 'Entrega fallida',
  };
}

String modalityLabel(OrderModality modality) {
  return switch (modality) {
    OrderModality.inStore => 'Presencial',
    OrderModality.delivery => 'A domicilio',
  };
}
