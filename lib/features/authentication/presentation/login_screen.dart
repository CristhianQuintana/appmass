import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_info.dart';
import '../../../app/router/app_redirect.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../../core/widgets/mass_text_field.dart';
import '../../../core/widgets/mass_wordmark.dart';
import '../application/session_controller.dart';
import '../domain/login_validator.dart';

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

  void _goBackToStore() {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.of(context).maybePop();
      return;
    }
    final next = GoRouterState.of(context).uri.queryParameters['next'];
    router.go(loginCancelTarget(next));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final emailError = loginFieldMessage(
      LoginField.email,
      session.validation.email,
    );
    final passwordError = loginFieldMessage(
      LoginField.password,
      session.validation.password,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBackToStore();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            key: const Key('login-back'),
            tooltip: 'Volver a la tienda',
            onPressed: session.isSubmitting ? null : _goBackToStore,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: MassWordmark()),
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
                        'Ingresa tu correo y contraseña para continuar.',
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
                      const SizedBox(height: 8),
                      TextButton(
                        key: const Key('login-back-store'),
                        onPressed: session.isSubmitting
                            ? null
                            : _goBackToStore,
                        child: const Text('Volver a la tienda'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '${AppInfo.name} · ${AppInfo.versionLabel}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MassColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
