import 'auth_identity.dart';
import 'password_reset_outcome.dart';

abstract class AuthRepository {
  Stream<AuthIdentity?> watchSession();

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<PasswordResetOutcome> requestPasswordReset({required String email});
}
