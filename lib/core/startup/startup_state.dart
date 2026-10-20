import '../config/app_config.dart';

/// Resultado del arranque. El cliente de Supabase solo se usa si quedó listo.
class StartupState {
  const StartupState({
    required this.config,
    required this.supabaseInitialized,
    this.initializationFailed = false,
  });

  final AppConfig config;
  final bool supabaseInitialized;
  final bool initializationFailed;

  bool get canUseSupabase =>
      config.isConfigured && supabaseInitialized && !initializationFailed;

  String get blockedMessage {
    if (initializationFailed) {
      return 'No se pudo iniciar la conexión segura. Revisa la configuración local y vuelve a abrir la aplicación.';
    }
    return switch (config.problem) {
      ConfigProblem.missingUrl => 'Falta la URL pública del proyecto de desarrollo. Configúrala con --dart-define-from-file.',
      ConfigProblem.insecureUrl =>
        'La URL del servicio debe usar HTTPS y no puede incluir credenciales.',
      ConfigProblem.missingKey =>
        'Falta la clave pública del cliente. No uses la clave service_role.',
      ConfigProblem.privilegedKey => 'La clave configurada es privilegiada y no puede incluirse en la aplicación.',
      ConfigProblem.none => 'La conexión con el servicio no está disponible.',
    };
  }
}
