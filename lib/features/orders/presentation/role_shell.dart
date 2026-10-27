import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_redirect.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/widgets/mass_loading.dart';
import '../../../core/widgets/mass_logo.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/session_status.dart';
import '../../customer/application/customer_cart.dart';
import '../../customer/presentation/customer_cart_screen.dart';
import '../../customer/presentation/fly_to_cart.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/domain/staff_profile.dart';
import '../../profile/domain/staff_role.dart';

class RoleShell extends ConsumerWidget {
  const RoleShell({required this.role, required this.child, super.key});

  final StaffRole role;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider).asData?.value;
    final session = ref.watch(sessionControllerProvider);
    final isCustomer = role == StaffRole.customer;
    final isGuest =
        isCustomer && session.status == SessionStatus.signedOut;
    if (!isGuest &&
        (profile == null || profile.role != role || !profile.isOperational)) {
      return const MassLoading(message: 'Comprobando acceso');
    }

    final route = GoRouterState.of(context);
    final path = route.uri.path;
    final categoryQuery = route.uri.queryParameters['categoria'];
    final destinations = _destinations(role);
    final selected = _selectedIndex(path, role);

    final cartCount = isCustomer
        ? ref.watch(customerCartProvider).quantity
        : 0;
    final browsingCategory =
        isCustomer &&
        path.startsWith('${AppRoutes.customerHome}/catalogo') &&
        categoryQuery != null &&
        categoryQuery.isNotEmpty;
    final showBack =
        !_isSectionRoot(path, role) || browsingCategory;

    return Scaffold(
      endDrawer: isCustomer
          ? Drawer(
              width: MediaQuery.sizeOf(context).width * 0.92,
              child: const SafeArea(child: CustomerCartScreen(asDrawer: true)),
            )
          : null,
      appBar: AppBar(
        leading: showBack
            ? IconButton(
                tooltip: 'Volver',
                onPressed: () => context.go(
                  browsingCategory
                      ? '${AppRoutes.customerHome}/catalogo'
                      : _backTarget(path, role),
                ),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: isCustomer
            ? const MassLogo(compact: true)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile!.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: MassColors.ink,
                    ),
                  ),
                  Text(
                    role.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MassColors.muted,
                    ),
                  ),
                ],
              ),
        actions: [
          if (isCustomer)
            Builder(
              builder: (buttonContext) => IconButton(
                key: customerCartIconKey,
                tooltip: 'Abrir carrito',
                onPressed: () => Scaffold.of(buttonContext).openEndDrawer(),
                icon: cartCount > 0
                    ? Badge(
                        label: Text('$cartCount'),
                        child: const Icon(Icons.shopping_cart_outlined),
                      )
                    : const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          if (isGuest)
            TextButton(
              key: const Key('home-sign-in'),
              onPressed: () => context.go(
                loginWithNext(GoRouterState.of(context).uri.toString()),
              ),
              child: const Text('Ingresar'),
            )
          else
            IconButton(
              key: const Key('home-account'),
              tooltip: 'Cuenta',
              onPressed: () => _openAccount(
                context,
                ref,
                profile!,
                session.identity?.email,
              ),
              icon: const Icon(Icons.account_circle_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isCustomer &&
                !isGuest &&
                route.uri.queryParameters['checkout'] == '1')
              const _OpenCartAfterLogin(),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: destinations.length < 2
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (index) {
                context.go(destinations[index].path);
              },
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    label: destination.label,
                  ),
              ],
            ),
    );
  }
}

class _OpenCartAfterLogin extends StatefulWidget {
  const _OpenCartAfterLogin();

  @override
  State<_OpenCartAfterLogin> createState() => _OpenCartAfterLoginState();
}

class _OpenCartAfterLoginState extends State<_OpenCartAfterLogin> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      openCustomerCartDrawer(context);
      context.go(AppRoutes.customerHome);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Abre el carrito desde la derecha (desliza de derecha a izquierda).
void openCustomerCartDrawer(BuildContext context) {
  final scaffold = Scaffold.maybeOf(context);
  if (scaffold != null && scaffold.hasEndDrawer) {
    scaffold.openEndDrawer();
    return;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final next = Scaffold.maybeOf(context);
    if (next != null && next.hasEndDrawer) {
      next.openEndDrawer();
    }
  });
}

class _Destination {
  const _Destination({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

List<_Destination> _destinations(StaffRole role) {
  final home = AppRoutes.homeFor(role);
  return switch (role) {
    StaffRole.operator => [
      _Destination(path: home, label: 'Pedidos', icon: Icons.receipt_long),
      _Destination(
        path: '$home/nuevo',
        label: 'Nuevo',
        icon: Icons.add_shopping_cart,
      ),
      _Destination(
        path: '$home/catalogo',
        label: 'Catálogo',
        icon: Icons.storefront,
      ),
    ],
    StaffRole.administrator => [
      _Destination(path: home, label: 'Resumen', icon: Icons.insights),
      _Destination(
        path: '$home/pedidos',
        label: 'Pedidos',
        icon: Icons.receipt_long,
      ),
      _Destination(
        path: '$home/catalogo',
        label: 'Catálogo',
        icon: Icons.storefront,
      ),
      _Destination(
        path: '$home/personal',
        label: 'Personal',
        icon: Icons.badge,
      ),
    ],
    StaffRole.courier => [
      _Destination(path: home, label: 'Entregas', icon: Icons.local_shipping),
    ],
    StaffRole.customer => [
      _Destination(path: home, label: 'Inicio', icon: Icons.home_outlined),
      _Destination(
        path: '$home/catalogo',
        label: 'Catálogo',
        icon: Icons.storefront,
      ),
      _Destination(
        path: '$home/pedidos',
        label: 'Pedidos',
        icon: Icons.receipt_long,
      ),
    ],
    StaffRole.unassigned => const [],
  };
}

bool _isSectionRoot(String path, StaffRole role) {
  return _destinations(role).any((destination) => destination.path == path);
}

int _selectedIndex(String path, StaffRole role) {
  final home = AppRoutes.homeFor(role);
  if (role == StaffRole.operator) {
    if (path.startsWith('$home/nuevo')) return 1;
    if (path.startsWith('$home/catalogo')) return 2;
    return 0;
  }
  if (role == StaffRole.administrator) {
    if (path.startsWith('$home/pedidos') || path.contains('/pedido/')) return 1;
    if (path.startsWith('$home/catalogo')) return 2;
    if (path.startsWith('$home/personal')) return 3;
    return 0;
  }
  if (role == StaffRole.customer) {
    if (path.startsWith('$home/catalogo') ||
        path.contains('/producto/') ||
        path.startsWith('$home/carrito')) {
      return 1;
    }
    if (path.startsWith('$home/pedidos') || path.contains('/pedido/')) return 2;
    return 0;
  }
  return 0;
}

String _backTarget(String path, StaffRole role) {
  final home = AppRoutes.homeFor(role);
  if (role == StaffRole.administrator && path.contains('/pedido/')) {
    return '$home/pedidos';
  }
  if (role == StaffRole.customer && path.contains('/producto/')) {
    return '$home/catalogo';
  }
  if (role == StaffRole.customer && path.contains('/pedido/')) {
    return '$home/pedidos';
  }
  if (role == StaffRole.customer && path.startsWith('$home/carrito')) {
    return '$home/catalogo';
  }
  return home;
}

void _openAccount(
  BuildContext context,
  WidgetRef ref,
  StaffProfile profile,
  String? email,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                profile.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: MassColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.role.label,
                style: const TextStyle(color: MassColors.muted),
              ),
              if (email != null && email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: MassColors.muted)),
              ],
              const SizedBox(height: 24),
              OutlinedButton(
                key: const Key('account-sign-out'),
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  if (!context.mounted) return;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                        'Tendrás que volver a identificarte para continuar.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          key: const Key('home-sign-out'),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref
                        .read(sessionControllerProvider.notifier)
                        .signOut();
                  }
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
