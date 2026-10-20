import 'dart:io';

import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/auth_identity.dart';
import '../domain/auth_repository.dart';
import '../domain/password_reset_outcome.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthIdentity?> watchSession() async* {
    yield _identityOf(_client.auth.currentSession);
    yield* _client.auth.onAuthStateChange.map(
      (event) => _identityOf(event.session),
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on Object catch (error) {
      throw _mapSignInError(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on Object {
      try {
        await _client.auth.signOut(scope: SignOutScope.local);
      } on Object {
        throw const UnexpectedFailure();
      }
    }
  }

  @override
  Future<PasswordResetOutcome> requestPasswordReset({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return PasswordResetOutcome.accepted;
    } on AuthRetryableFetchException {
      return PasswordResetOutcome.network;
    } on AuthException catch (error) {
      if (error.statusCode == '429') return PasswordResetOutcome.rateLimited;
      return PasswordResetOutcome.accepted;
    } on SocketException {
      return PasswordResetOutcome.network;
    } on ClientException {
      return PasswordResetOutcome.network;
    } on Object {
      return PasswordResetOutcome.unavailable;
    }
  }

  AuthIdentity? _identityOf(Session? session) {
    final user = session?.user;
    if (user == null) return null;
    return AuthIdentity(id: user.id, email: user.email ?? '');
  }

  AppFailure _mapSignInError(Object error) {
    if (error is AuthRetryableFetchException ||
        error is SocketException ||
        error is ClientException) {
      return const NetworkFailure();
    }
    if (error is AuthException && error.statusCode == '429') {
      return const RateLimitFailure();
    }
    if (error is AuthException) return const InvalidCredentialsFailure();
    return const UnexpectedFailure();
  }
}
