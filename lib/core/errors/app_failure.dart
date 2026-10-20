/// Error seguro para la interfaz. No transporta respuestas internas.
sealed class AppFailure implements Exception {
  const AppFailure();

  String get userMessage;
}

final class InvalidCredentialsFailure extends AppFailure {
  const InvalidCredentialsFailure();

  @override
  String get userMessage =>
      'No se pudo iniciar sesión con los datos proporcionados.';
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure();

  @override
  String get userMessage =>
      'No hay conexión con el servicio. Inténtalo de nuevo cuando la red esté disponible.';
}

final class RateLimitFailure extends AppFailure {
  const RateLimitFailure();

  @override
  String get userMessage =>
      'Hay demasiados intentos. Espera un momento antes de volver a intentarlo.';
}

final class ConfigurationFailure extends AppFailure {
  const ConfigurationFailure();

  @override
  String get userMessage =>
      'La aplicación no tiene una configuración válida para conectar con el servicio.';
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure();

  @override
  String get userMessage =>
      'No se pudo completar la operación. Inténtalo de nuevo.';
}

final class ProfileDataFailure extends AppFailure {
  const ProfileDataFailure();

  @override
  String get userMessage => 'No se pudo verificar el perfil de esta cuenta.';
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure([
    this.userMessage = 'Revisa los datos e inténtalo de nuevo.',
  ]);

  @override
  final String userMessage;
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure();

  @override
  String get userMessage =>
      'El pedido cambió mientras lo actualizabas. Vuelve a cargarlo antes de continuar.';
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();

  @override
  String get userMessage => 'No se encontró el pedido o no tienes acceso a él.';
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure();

  @override
  String get userMessage => 'No tienes permiso para realizar esta operación.';
}

String userFacingMessage(Object? error) {
  if (error is AppFailure) return error.userMessage;
  return const UnexpectedFailure().userMessage;
}
