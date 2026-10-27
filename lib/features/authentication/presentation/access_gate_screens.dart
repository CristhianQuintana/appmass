import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mass_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_notice.dart';
import '../application/auth_providers.dart';
import '../application/session_controller.dart';
import '../../profile/application/profile_controller.dart';

class ConfigurationScreen extends ConsumerWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'No se pudo conectar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: MassColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MassNotice(
                    title: 'Conexión no disponible',
                    message: startup.blockedMessage,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Revisa tu conexión a internet e intenta de nuevo más tarde. '
                    'Si el problema continúa, contacta al equipo de la tienda.',
                    style: TextStyle(color: MassColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UnauthorizedScreen extends ConsumerWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final hasProfileError = profile.hasError && !profile.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Acceso no habilitado',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: MassColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MassNotice(
                    message: hasProfileError
                        ? userFacingMessage(profile.error)
                        : 'Esta cuenta aún no está habilitada. Contacta al soporte de la tienda para continuar.',
                  ),
                  const SizedBox(height: 16),
                  if (hasProfileError)
                    MassButton(
                      label: 'Reintentar',
                      onPressed: () =>
                          ref.invalidate(profileControllerProvider),
                    ),
                  if (hasProfileError) const SizedBox(height: 8),
                  MassButton(
                    buttonKey: const Key('unauthorized-sign-out'),
                    label: 'Cerrar sesión',
                    isLoading: session.isSubmitting,
                    onPressed: () =>
                        ref.read(sessionControllerProvider.notifier).signOut(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
