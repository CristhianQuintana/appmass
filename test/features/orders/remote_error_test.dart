import 'package:app_mass/core/errors/app_failure.dart';
import 'package:app_mass/features/orders/data/remote_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('los errores remotos no exponen el mensaje interno', () {
    expect(
      mapRemoteError(
        const PostgrestException(message: 'detalle interno', code: '42501'),
      ),
      isA<UnauthorizedFailure>(),
    );
    expect(
      mapRemoteError(
        const PostgrestException(message: 'version', code: '40001'),
      ),
      isA<ConflictFailure>(),
    );
    expect(
      mapRemoteError(const PostgrestException(message: 'dato', code: '22023')),
      isA<ValidationFailure>(),
    );
    expect(
      mapRemoteError(
        const PostgrestException(message: 'secreto sql', code: 'XX000'),
      ).userMessage,
      isNot(contains('secreto')),
    );
  });
}
