import 'package:app_mass/app/router/app_redirect.dart';
import 'package:app_mass/app/router/app_routes.dart';
import 'package:app_mass/app/router/profile_gate.dart';
import 'package:app_mass/features/authentication/domain/session_status.dart';
import 'package:app_mass/features/profile/domain/staff_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? redirect({
    bool configurationReady = true,
    SessionStatus sessionStatus = SessionStatus.signedOut,
    ProfileGate profileGate = ProfileGate.notRequested,
    StaffRole? role,
    required String location,
  }) {
    return resolveRedirect(
      configurationReady: configurationReady,
      sessionStatus: sessionStatus,
      profileGate: profileGate,
      role: role,
      location: location,
    );
  }

  test('sin configuración no abre rutas internas', () {
    expect(
      redirect(configurationReady: false, location: AppRoutes.operatorHome),
      AppRoutes.configuration,
    );
    expect(
      redirect(configurationReady: false, location: AppRoutes.configuration),
      isNull,
    );
  });

  test('una sesión desconocida permanece en la comprobación', () {
    expect(
      redirect(
        sessionStatus: SessionStatus.unknown,
        location: AppRoutes.operatorHome,
      ),
      AppRoutes.loading,
    );
  });

  test('un usuario anónimo no permanece en una ruta protegida', () {
    expect(redirect(location: AppRoutes.administratorHome), AppRoutes.login);
    expect(redirect(location: AppRoutes.login), isNull);
    expect(redirect(location: AppRoutes.recovery), isNull);
  });

  test(
    'un perfil ausente, inactivo o desconocido no recibe inicio privilegiado',
    () {
      for (final gate in [
        ProfileGate.missing,
        ProfileGate.inactive,
        ProfileGate.unassigned,
        ProfileGate.failed,
      ]) {
        expect(
          redirect(
            sessionStatus: SessionStatus.signedIn,
            profileGate: gate,
            location: AppRoutes.login,
          ),
          AppRoutes.unauthorized,
        );
      }
      expect(
        redirect(
          sessionStatus: SessionStatus.signedIn,
          profileGate: ProfileGate.failed,
          location: AppRoutes.unauthorized,
        ),
        isNull,
      );
    },
  );

  test('cada rol llega solo a su inicio y no conserva el de otro', () {
    expect(
      redirect(
        sessionStatus: SessionStatus.signedIn,
        profileGate: ProfileGate.ready,
        role: StaffRole.operator,
        location: AppRoutes.administratorHome,
      ),
      AppRoutes.operatorHome,
    );
    expect(
      redirect(
        sessionStatus: SessionStatus.signedIn,
        profileGate: ProfileGate.ready,
        role: StaffRole.operator,
        location: '${AppRoutes.operatorHome}/nuevo',
      ),
      isNull,
    );
    expect(
      redirect(
        sessionStatus: SessionStatus.signedIn,
        profileGate: ProfileGate.ready,
        role: StaffRole.operator,
        location: '${AppRoutes.courierHome}/entrega/pedido-1',
      ),
      AppRoutes.operatorHome,
    );
    expect(
      redirect(
        sessionStatus: SessionStatus.signedIn,
        profileGate: ProfileGate.ready,
        role: StaffRole.courier,
        location: AppRoutes.courierHome,
      ),
      isNull,
    );
    expect(
      redirect(
        sessionStatus: SessionStatus.signedIn,
        profileGate: ProfileGate.ready,
        role: StaffRole.administrator,
        location: '${AppRoutes.administratorHome}/',
      ),
      isNull,
    );
  });

  test('cerrar sesión devuelve cualquier ruta interna al ingreso', () {
    expect(
      redirect(
        sessionStatus: SessionStatus.signedOut,
        location: AppRoutes.courierHome,
      ),
      AppRoutes.login,
    );
  });
}
