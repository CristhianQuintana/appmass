import '../../features/profile/domain/staff_role.dart';

abstract final class AppRoutes {
  static const loading = '/comprobando-acceso';
  static const login = '/ingreso';
  static const recovery = '/recuperar-acceso';
  static const unauthorized = '/sin-autorizacion';
  static const configuration = '/configuracion';
  static const administratorHome = '/inicio/administrador';
  static const operatorHome = '/inicio/operador';
  static const courierHome = '/inicio/transportista';
  static const customerHome = '/inicio/cliente';

  static String homeFor(StaffRole role) {
    return switch (role) {
      StaffRole.administrator => administratorHome,
      StaffRole.operator => operatorHome,
      StaffRole.courier => courierHome,
      StaffRole.customer => customerHome,
      StaffRole.unassigned => unauthorized,
    };
  }
}
