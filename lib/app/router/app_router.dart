import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/mass_loading.dart';
import '../../features/authentication/application/auth_providers.dart';
import '../../features/authentication/application/session_controller.dart';
import '../../features/authentication/presentation/access_gate_screens.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/password_recovery_screen.dart';
import '../../features/profile/application/profile_controller.dart';
import '../../features/simulation/demo_mode.dart';
import '../../features/customer/presentation/customer_catalog_screen.dart';
import '../../features/customer/presentation/customer_home_screen.dart';
import '../../features/customer/presentation/customer_orders_screen.dart';
import '../../features/orders/presentation/admin_summary_screen.dart';
import '../../features/orders/presentation/catalog_screen.dart';
import '../../features/orders/presentation/delivery_detail_screen.dart';
import '../../features/orders/presentation/new_order_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/orders_list_screen.dart';
import '../../features/orders/presentation/role_shell.dart';
import '../../features/orders/presentation/staff_screen.dart';
import '../../features/profile/domain/staff_role.dart';
import 'app_redirect.dart';
import 'app_routes.dart';

class RouterRefresh extends ChangeNotifier {
  void notifyRouter() => notifyListeners();
}

final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh();
  ref.listen(sessionControllerProvider, (_, _) => refresh.notifyRouter());
  ref.listen(profileControllerProvider, (_, _) => refresh.notifyRouter());
  ref.listen(demoModeProvider, (_, _) => refresh.notifyRouter());
  ref.onDispose(refresh.dispose);
  return refresh;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);
  final router = GoRouter(
    initialLocation: AppRoutes.loading,
    refreshListenable: refresh,
    redirect: (context, state) {
      final startup = ref.read(startupProvider);
      final session = ref.read(sessionControllerProvider);
      final profile = ref.read(profileControllerProvider);
      final gate = profileGateFor(
        sessionStatus: session.status,
        profileLoading: profile.isLoading,
        profileFailed: profile.hasError,
        profile: profile.asData?.value,
      );
      return resolveRedirect(
        configurationReady:
            startup.canUseSupabase || ref.read(demoModeProvider),
        sessionStatus: session.status,
        profileGate: gate,
        role: profile.asData?.value?.role,
        location: state.uri.toString(),
      );
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.loading),
      GoRoute(
        path: AppRoutes.loading,
        builder: (context, state) =>
            const MassLoading(message: 'Comprobando acceso'),
      ),
      GoRoute(
        path: AppRoutes.configuration,
        builder: (context, state) => const ConfigurationScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        builder: (context, state) => const PasswordRecoveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            RoleShell(role: StaffRole.administrator, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.administratorHome,
            builder: (context, state) => const AdminSummaryScreen(),
            routes: [
              GoRoute(
                path: 'pedidos',
                builder: (context, state) => const OrdersListScreen(),
              ),
              GoRoute(
                path: 'catalogo',
                builder: (context, state) => const CatalogScreen(),
              ),
              GoRoute(
                path: 'personal',
                builder: (context, state) => const StaffScreen(),
              ),
              GoRoute(
                path: 'pedido/:orderId',
                builder: (context, state) => OrderDetailScreen(
                  orderId: state.pathParameters['orderId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) =>
            RoleShell(role: StaffRole.operator, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.operatorHome,
            builder: (context, state) => const OrdersListScreen(),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (context, state) => const NewOrderScreen(),
              ),
              GoRoute(
                path: 'catalogo',
                builder: (context, state) => const CatalogScreen(),
              ),
              GoRoute(
                path: 'pedido/:orderId',
                builder: (context, state) => OrderDetailScreen(
                  orderId: state.pathParameters['orderId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) =>
            RoleShell(role: StaffRole.courier, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.courierHome,
            builder: (context, state) =>
                const OrdersListScreen(courierView: true),
            routes: [
              GoRoute(
                path: 'entrega/:orderId',
                builder: (context, state) => DeliveryDetailScreen(
                  orderId: state.pathParameters['orderId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) =>
            RoleShell(role: StaffRole.customer, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.customerHome,
            builder: (context, state) => const CustomerHomeScreen(),
            routes: [
              GoRoute(
                path: 'catalogo',
                builder: (context, state) => CustomerCatalogScreen(
                  category: state.uri.queryParameters['categoria'],
                ),
              ),
              GoRoute(
                path: 'producto/:productId',
                builder: (context, state) => CustomerProductScreen(
                  productId: state.pathParameters['productId']!,
                ),
              ),
              GoRoute(
                path: 'carrito',
                redirect: (context, state) => AppRoutes.customerHome,
              ),
              GoRoute(
                path: 'pedidos',
                builder: (context, state) => const CustomerOrdersScreen(),
              ),
              GoRoute(
                path: 'pedido/:orderId',
                builder: (context, state) => CustomerOrderScreen(
                  orderId: state.pathParameters['orderId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
