import 'dart:io';

import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_failure.dart';

AppFailure mapRemoteError(Object error) {
  if (error is AppFailure) return error;
  if (error is SocketException || error is ClientException) {
    return const NetworkFailure();
  }
  if (error is PostgrestException) {
    return switch (error.code) {
      '42501' || 'PGRST301' => const UnauthorizedFailure(),
      '40001' => const ConflictFailure(),
      '22023' || '23514' || '23502' => const ValidationFailure(),
      '23505' => const ValidationFailure(
        'Ya existe un registro con ese código.',
      ),
      'P0002' => const NotFoundFailure(),
      _ => const UnexpectedFailure(),
    };
  }
  return const UnexpectedFailure();
}

Future<T> guardRemote<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on AppFailure {
    rethrow;
  } on Object catch (error) {
    throw mapRemoteError(error);
  }
}
