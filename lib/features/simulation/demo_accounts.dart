import '../profile/domain/staff_role.dart';

/// Cuentas locales para recorrer la interfaz. No existen en ningún servidor.
class DemoAccount {
  const DemoAccount({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.buttonKey,
  });

  final String id;
  final String email;
  final String fullName;
  final StaffRole role;
  final String buttonKey;
}

const demoPassword = 'Demostracion1';

const demoAccounts = <DemoAccount>[
  DemoAccount(
    id: 'operator-1',
    email: 'ana.operadora@demo.local',
    fullName: 'Ana Quispe',
    role: StaffRole.operator,
    buttonKey: 'demo-account-operator',
  ),
  DemoAccount(
    id: 'admin-1',
    email: 'marco.admin@demo.local',
    fullName: 'Marco Salazar',
    role: StaffRole.administrator,
    buttonKey: 'demo-account-administrator',
  ),
  DemoAccount(
    id: 'courier-1',
    email: 'luis.reparto@demo.local',
    fullName: 'Luis Huamán',
    role: StaffRole.courier,
    buttonKey: 'demo-account-courier',
  ),
  DemoAccount(
    id: 'customer-1',
    email: 'rosa.cliente@demo.local',
    fullName: 'Rosa Mendoza',
    role: StaffRole.customer,
    buttonKey: 'demo-account-customer',
  ),
];
