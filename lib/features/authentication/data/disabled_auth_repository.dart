import '../../../core/errors/app_failure.dart';
import '../domain/auth_identity.dart';
import '../domain/auth_repository.dart';
import '../domain/password_reset_outcome.dart';

class DisabledAuthRepository implements AuthRepository {
  const DisabledAuthRepository();

  @override
  Stream<AuthIdentity?> watchSession() async* {
    yield null;
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    throw const ConfigurationFailure();
  }

  @override
  Future<PasswordResetOutcome> requestPasswordReset({required String email}) {
    return Future.value(PasswordResetOutcome.unavailable);
  }

  @override
  Future<void> signOut() async {}
}
