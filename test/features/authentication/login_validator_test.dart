import 'package:app_mass/features/authentication/domain/login_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validator = LoginValidator();

  test('acepta un correo y una contraseña dentro de los límites', () {
    final result = validator.validate(
      email: ' ana@example.com ',
      password: 'password1',
    );
    expect(result.isValid, isTrue);
  });

  test('rechaza campos vacíos, correo inválido y longitudes extremas', () {
    final empty = validator.validate(email: '   ', password: '');
    expect(empty.email, LoginFieldError.required);
    expect(empty.password, LoginFieldError.required);

    final malformed = validator.validate(
      email: 'no-es-correo',
      password: 'short',
    );
    expect(malformed.email, LoginFieldError.invalid);
    expect(malformed.password, LoginFieldError.tooShort);

    final tooLong = validator.validate(
      email: '${'a' * 250}@example.com',
      password: 'p' * 129,
    );
    expect(tooLong.email, LoginFieldError.tooLong);
    expect(tooLong.password, LoginFieldError.tooLong);
  });

  test('los mensajes no dependen solo del color', () {
    expect(
      loginFieldMessage(LoginField.email, LoginFieldError.invalid),
      'Ingresa un correo electrónico válido.',
    );
    expect(
      loginFieldMessage(LoginField.password, LoginFieldError.tooShort),
      contains('8 caracteres'),
    );
  });
}
