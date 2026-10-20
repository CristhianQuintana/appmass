import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_info.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../../core/widgets/mass_text_field.dart';
import '../../../core/widgets/mass_wordmark.dart';
import '../application/session_controller.dart';
import '../domain/login_validator.dart';
import '../../simulation/demo_accounts.dart';
import '../../simulation/demo_mode.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    return ref
        .read(sessionControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final demo = ref.watch(demoModeProvider);
    final emailError = loginFieldMessage(
      LoginField.email,
      session.validation.email,
    );
    final passwordError = loginFieldMessage(
      LoginField.password,
      session.validation.password,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: MassWordmark()),
                    const SizedBox(height: 12),
                    const Center(child: _PhaseBadge()),
                    const SizedBox(height: 24),
                    Text(
                      'Inicia sesión',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: MassColors.ink,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Accede con la cuenta que te asignó un administrador.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MassColors.muted),
                    ),
                    const SizedBox(height: 24),
                    MassTextField(
                      fieldKey: const Key('login-email'),
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hintText: 'nombre@ejemplo.com',
                      errorText: emailError,
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                    ),
                    const SizedBox(height: 16),
                    MassTextField(
                      fieldKey: const Key('login-password'),
                      controller: _passwordController,
                      label: 'Contraseña',
                      errorText: passwordError,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      suffix: IconButton(
                        key: const Key('login-password-visibility'),
                        tooltip: _obscurePassword
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: session.isSubmitting
                            ? null
                            : () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: session.isSubmitting
                            ? null
                            : () => context.go(AppRoutes.recovery),
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    if (session.failure != null) ...[
                      MassNotice(message: session.failure!.userMessage),
                      const SizedBox(height: 12),
                    ],
                    MassButton(
                      buttonKey: const Key('login-submit'),
                      label: 'Iniciar sesión',
                      icon: Icons.arrow_forward,
                      isLoading: session.isSubmitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    const MassNotice(
                      tone: MassNoticeTone.info,
                      title: 'Acceso de personal',
                      message: 'El rol no se elige en esta pantalla. Lo asigna un administrador y el servidor lo verifica.',
                    ),
                    if (demo) ...[
                      const SizedBox(height: 16),
                      const MassNotice(
                        tone: MassNoticeTone.info,
                        title: 'Demostración local',
                        message: 'Estas cuentas solo existen en este dispositivo. El perfil ya viene asignado; esta pantalla no elige el rol.',
                      ),
                      const SizedBox(height: 12),
                      for (final account in demoAccounts) ...[
                        OutlinedButton(
                          key: Key(account.buttonKey),
                          onPressed: session.isSubmitting
                              ? null
                              : () => ref
                                    .read(sessionControllerProvider.notifier)
                                    .signIn(
                                      email: account.email,
                                      password: demoPassword,
                                    ),
                          child: Text(
                            '${account.fullName} · ${account.role.label}',
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextButton(
                        onPressed: session.isSubmitting
                            ? null
                            : () =>
                                  ref.read(demoModeProvider.notifier).disable(),
                        child: const Text('Salir de la demostración'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      '${AppInfo.name} · ${AppInfo.versionLabel}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MassColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MassColors.yellow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'MVP OPERATIVO',
        style: TextStyle(
          color: MassColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
