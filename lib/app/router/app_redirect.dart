import '../../features/authentication/domain/session_status.dart';
import '../../features/profile/domain/staff_profile.dart';
import '../../features/profile/domain/staff_role.dart';
import 'app_routes.dart';
import 'profile_gate.dart';

ProfileGate profileGateFor({
  required SessionStatus sessionStatus,
  required bool profileLoading,
  required bool profileFailed,
  required StaffProfile? profile,
}) {
  if (sessionStatus != SessionStatus.signedIn) {
    return ProfileGate.notRequested;
  }
  if (profileLoading) return ProfileGate.loading;
  if (profileFailed) return ProfileGate.failed;
  if (profile == null) return ProfileGate.missing;
  if (!profile.isActive) return ProfileGate.inactive;
  if (!profile.role.isOperational) return ProfileGate.unassigned;
  return ProfileGate.ready;
}

/// Decide la ruta sin conceder permisos. El backend sigue siendo la autoridad.
String? resolveRedirect({
  required bool configurationReady,
  required SessionStatus sessionStatus,
  required ProfileGate profileGate,
  required StaffRole? role,
  required String location,
}) {
  final uri = Uri.parse(location.isEmpty ? '/' : location);
  final path = _normalize(uri.path);
  final next = uri.queryParameters['next'];

  if (!configurationReady || sessionStatus == SessionStatus.unconfigured) {
    return path == AppRoutes.configuration ? null : AppRoutes.configuration;
  }

  if (sessionStatus == SessionStatus.unknown) {
    return path == AppRoutes.loading ? null : AppRoutes.loading;
  }

  if (sessionStatus == SessionStatus.signedOut) {
    if (path == AppRoutes.login || path == AppRoutes.recovery) return null;
    if (isCustomerOrdersPath(path)) {
      return loginWithNext(path);
    }
    if (_isCustomerGuestPath(path)) return null;
    // Invitados entran a la tienda; el personal inicia sesión desde ahí.
    return AppRoutes.customerHome;
  }

  if (profileGate == ProfileGate.loading ||
      profileGate == ProfileGate.notRequested) {
    return path == AppRoutes.loading ? null : AppRoutes.loading;
  }

  if (profileGate != ProfileGate.ready || role == null || !role.isOperational) {
    return path == AppRoutes.unauthorized ? null : AppRoutes.unauthorized;
  }

  final home = AppRoutes.homeFor(role);

  // Tras iniciar sesión, respetar "next" solo si es zona de cliente y el
  // usuario es cliente; el personal va a su inicio.
  if (path == AppRoutes.login || path == AppRoutes.recovery || path == AppRoutes.loading) {
    if (role == StaffRole.customer && next != null && next.isNotEmpty) {
      final decoded = Uri.decodeComponent(next);
      final nextPath = _normalize(Uri.parse(decoded).path);
      if (_isCustomerArea(nextPath)) return decoded;
    }
    return home;
  }

  if (path == home || path.startsWith('$home/')) return null;

  // Cliente puede quedarse en tienda; personal siempre a su área.
  if (role == StaffRole.customer && _isCustomerArea(path)) return null;
  return home;
}

bool _isCustomerArea(String path) {
  final home = AppRoutes.customerHome;
  return path == home || path.startsWith('$home/');
}

/// Invitados pueden ver tienda, catálogo, producto y carrito (no pedidos).
bool _isCustomerGuestPath(String path) {
  final home = AppRoutes.customerHome;
  if (path == home) return true;
  if (path.startsWith('$home/catalogo')) return true;
  if (path.startsWith('$home/producto/')) return true;
  if (path.startsWith('$home/carrito')) return true;
  return false;
}

String _normalize(String location) {
  final path = location.isEmpty ? '/' : location;
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}

/// Ruta de ingreso con retorno opcional tras autenticarse.
String loginWithNext(String absoluteOrPath) {
  final encoded = Uri.encodeComponent(absoluteOrPath);
  return '${AppRoutes.login}?next=$encoded';
}

/// Destino al cancelar el ingreso: vuelve a la tienda (nunca a pedidos).
String loginCancelTarget(String? next) {
  if (next == null || next.isEmpty) return AppRoutes.customerHome;
  final decoded = Uri.decodeComponent(next);
  final path = _normalize(Uri.parse(decoded).path);
  if (_isCustomerGuestPath(path)) return decoded;
  return AppRoutes.customerHome;
}

bool isCustomerOrdersPath(String path) {
  final home = AppRoutes.customerHome;
  final normalized = _normalize(path);
  return normalized.startsWith('$home/pedidos') ||
      normalized.contains('/pedido/');
}
