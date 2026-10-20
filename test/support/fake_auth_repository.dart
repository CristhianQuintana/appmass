import 'dart:async';

import 'package:app_mass/features/authentication/domain/auth_identity.dart';
import 'package:app_mass/features/authentication/domain/auth_repository.dart';
import 'package:app_mass/features/authentication/domain/password_reset_outcome.dart';

class FakeAuthRepository implements AuthRepository {
  final _changes = StreamController<AuthIdentity?>.broadcast();

  AuthIdentity? current;
  int signInCalls = 0;
  int signOutCalls = 0;
  Object? signInError;
  Completer<void>? signInGate;
  PasswordResetOutcome resetOutcome = PasswordResetOutcome.accepted;
  final resetEmails = <String>[];

  @override
  Stream<AuthIdentity?> watchSession() async* {
    yield current;
    yield* _changes.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls += 1;
    if (signInError != null) throw signInError!;
    final gate = signInGate;
    if (gate != null) await gate.future;
    current = AuthIdentity(id: 'user-1', email: email);
    _changes.add(current);
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    current = null;
    _changes.add(null);
  }

  @override
  Future<PasswordResetOutcome> requestPasswordReset({
    required String email,
  }) async {
    resetEmails.add(email);
    return resetOutcome;
  }

  Future<void> dispose() => _changes.close();
}
