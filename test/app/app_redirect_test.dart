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

  test('un invitado entra a la tienda y no a personal', () {
    expect(redirect(location: AppRoutes.loading), AppRoutes.customerHome);
    expect(redirect(location: AppRoutes.customerHome), isNull);
    expect(
      redirect(location: '${AppRoutes.customerHome}/catalogo'),
      isNull,
    );
    expect(
      redirect(location: '${AppRoutes.customerHome}/producto/abc'),
      isNull,
    );
    expect(redirect(location: AppRoutes.administratorHome), AppRoutes.customerHome);
    expect(redirect(location: AppRoutes.login), isNull);
  });

  test('un invitado debe iniciar sesión para ver pedidos', () {
    expect(
      redirect(location: '${AppRoutes.customerHome}/pedidos'),
      loginWithNext('${AppRoutes.customerHome}/pedidos'),
    );
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

  test('cada área llega solo a su inicio y no conserva el de otro', () {
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
        role: StaffRole.administrator,
        location: AppRoutes.customerHome,
      ),
      AppRoutes.administratorHome,
    );
    expect(
      redirect(
        sessionStatus: SessionStatus.signedIn,
        profileGate: ProfileGate.ready,
        role: StaffRole.customer,
        location: AppRoutes.login,
      ),
      AppRoutes.customerHome,
    );
  });

  test('cerrar sesión lleva a la tienda, no al login forzado', () {
    expect(
      redirect(
        sessionStatus: SessionStatus.signedOut,
        location: AppRoutes.courierHome,
      ),
      AppRoutes.customerHome,
    );
  });

  test('cancelar el ingreso vuelve a la tienda visible sin sesión', () {
    expect(loginCancelTarget(null), AppRoutes.customerHome);
    expect(
      loginCancelTarget(Uri.encodeComponent(AppRoutes.customerHome)),
      AppRoutes.customerHome,
    );
    expect(
      loginCancelTarget(
        Uri.encodeComponent('${AppRoutes.customerHome}/catalogo'),
      ),
      '${AppRoutes.customerHome}/catalogo',
    );
    expect(
      loginCancelTarget(
        Uri.encodeComponent('${AppRoutes.customerHome}/pedidos'),
      ),
      AppRoutes.customerHome,
    );
  });
}
