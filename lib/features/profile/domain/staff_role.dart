enum StaffRole {
  administrator,
  operator,
  courier,
  customer,
  unassigned;

  static StaffRole fromStorage(String? value) {
    return switch (value) {
      'administrator' => StaffRole.administrator,
      'operator' => StaffRole.operator,
      'courier' => StaffRole.courier,
      'customer' => StaffRole.customer,
      _ => StaffRole.unassigned,
    };
  }

  bool get isOperational => switch (this) {
    StaffRole.administrator ||
    StaffRole.operator ||
    StaffRole.courier ||
    StaffRole.customer => true,
    StaffRole.unassigned => false,
  };

  String get label => switch (this) {
    StaffRole.administrator => 'Administrador',
    StaffRole.operator => 'Operador',
    StaffRole.courier => 'Transportista',
    StaffRole.customer => 'Cliente',
    StaffRole.unassigned => 'Sin rol operativo',
  };
}
