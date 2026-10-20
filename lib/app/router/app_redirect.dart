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
  final path = _normalize(location);

  if (!configurationReady || sessionStatus == SessionStatus.unconfigured) {
    return path == AppRoutes.configuration ? null : AppRoutes.configuration;
  }

  if (sessionStatus == SessionStatus.unknown) {
    return path == AppRoutes.loading ? null : AppRoutes.loading;
  }

  if (sessionStatus == SessionStatus.signedOut) {
    if (path == AppRoutes.login || path == AppRoutes.recovery) return null;
    return AppRoutes.login;
  }

  if (profileGate == ProfileGate.loading ||
      profileGate == ProfileGate.notRequested) {
    return path == AppRoutes.loading ? null : AppRoutes.loading;
  }

  if (profileGate != ProfileGate.ready || role == null || !role.isOperational) {
    return path == AppRoutes.unauthorized ? null : AppRoutes.unauthorized;
  }

  final home = AppRoutes.homeFor(role);
  if (path == home || path.startsWith('$home/')) return null;
  return home;
}

String _normalize(String location) {
  final path = location.isEmpty ? '/' : location;
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}
