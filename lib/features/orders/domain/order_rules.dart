import 'order_status.dart';

/// Espejo de las transiciones que también valida PostgreSQL.
class OrderRules {
  const OrderRules();

  OrderStatus? preparationTarget(OrderStatus status, OrderModality modality) {
    return switch ((modality, status)) {
      (OrderModality.inStore, OrderStatus.submitted) => OrderStatus.preparing,
      (OrderModality.inStore, OrderStatus.preparing) =>
        OrderStatus.readyForPickup,
      (OrderModality.inStore, OrderStatus.readyForPickup) =>
        OrderStatus.completed,
      (OrderModality.delivery, OrderStatus.submitted) => OrderStatus.preparing,
      (OrderModality.delivery, OrderStatus.preparing) =>
        OrderStatus.readyForDispatch,
      _ => null,
    };
  }

  bool canCancel(OrderStatus status) {
    return status == OrderStatus.submitted || status == OrderStatus.preparing;
  }

  bool canAssign(OrderStatus status, OrderModality modality) {
    return modality == OrderModality.delivery &&
        (status == OrderStatus.readyForDispatch ||
            status == OrderStatus.assigned);
  }

  bool canStartDelivery(OrderStatus status) => status == OrderStatus.assigned;

  bool canRecordResult(OrderStatus status) => status == OrderStatus.inDelivery;

  bool isTerminal(OrderStatus status) {
    return status == OrderStatus.completed ||
        status == OrderStatus.cancelled ||
        status == OrderStatus.deliveryFailed;
  }
}

const deliveryFailureReasons = <String, String>{
  'customer_absent': 'Cliente ausente',
  'wrong_address': 'Dirección incorrecta',
  'rejected': 'Pedido rechazado',
  'unreachable': 'No se pudo contactar',
  'other': 'Otro motivo',
};

bool isAllowedFailureReason(String code) =>
    deliveryFailureReasons.containsKey(code);
