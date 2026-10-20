import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/mass_colors.dart';
import '../../../core/widgets/mass_button.dart';
import '../../../core/widgets/mass_notice.dart';
import '../../../core/widgets/mass_text_field.dart';
import '../application/session_controller.dart';
import '../domain/login_validator.dart';

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  ConsumerState<PasswordRecoveryScreen> createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState
    extends ConsumerState<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final emailError = loginFieldMessage(
      LoginField.email,
      session.validation.email,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al ingreso',
          onPressed: session.isSubmitting
              ? null
              : () => context.go(AppRoutes.login),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Recuperar acceso'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ingresa el correo de tu cuenta. La respuesta no indica si ese correo está registrado.',
                    style: TextStyle(color: MassColors.muted),
                  ),
                  const SizedBox(height: 16),
                  MassTextField(
                    fieldKey: const Key('recovery-email'),
                    controller: _emailController,
                    label: 'Correo electrónico',
                    errorText: emailError,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 16),
                  if (session.failure != null) ...[
                    MassNotice(message: session.failure!.userMessage),
                    const SizedBox(height: 12),
                  ],
                  if (session.resetMessage != null) ...[
                    MassNotice(
                      tone: MassNoticeTone.info,
                      message: session.resetMessage!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  MassButton(
                    buttonKey: const Key('recovery-submit'),
                    label: 'Enviar instrucciones',
                    isLoading: session.isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() {
    return ref
        .read(sessionControllerProvider.notifier)
        .requestPasswordReset(_emailController.text);
  }
}
