enum LoginField { email, password }

enum LoginFieldError { required, invalid, tooShort, tooLong }

class LoginValidation {
  const LoginValidation({this.email, this.password});

  final LoginFieldError? email;
  final LoginFieldError? password;

  static const valid = LoginValidation();

  bool get isValid => email == null && password == null;
}

class LoginValidator {
  const LoginValidator();

  static const maxEmailLength = 254;
  static const minPasswordLength = 8;
  static const maxPasswordLength = 128;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  LoginValidation validate({required String email, required String password}) {
    return LoginValidation(
      email: _validateEmail(email),
      password: _validatePassword(password),
    );
  }

  LoginFieldError? validateEmail(String email) => _validateEmail(email);

  LoginFieldError? _validateEmail(String email) {
    final value = email.trim();
    if (value.isEmpty) return LoginFieldError.required;
    if (value.length > maxEmailLength) return LoginFieldError.tooLong;
    if (!_emailPattern.hasMatch(value)) return LoginFieldError.invalid;
    return null;
  }

  LoginFieldError? _validatePassword(String password) {
    if (password.isEmpty) return LoginFieldError.required;
    if (password.length < minPasswordLength) return LoginFieldError.tooShort;
    if (password.length > maxPasswordLength) return LoginFieldError.tooLong;
    return null;
  }
}

String? loginFieldMessage(LoginField field, LoginFieldError? error) {
  if (error == null) return null;
  return switch ((field, error)) {
    (LoginField.email, LoginFieldError.required) =>
      'Ingresa el correo electrónico.',
    (LoginField.email, LoginFieldError.invalid) =>
      'Ingresa un correo electrónico válido.',
    (LoginField.email, LoginFieldError.tooLong) =>
      'El correo electrónico es demasiado largo.',
    (LoginField.email, LoginFieldError.tooShort) =>
      'Ingresa un correo electrónico válido.',
    (LoginField.password, LoginFieldError.required) => 'Ingresa la contraseña.',
    (LoginField.password, LoginFieldError.tooShort) =>
      'La contraseña debe tener al menos 8 caracteres.',
    (LoginField.password, LoginFieldError.tooLong) =>
      'La contraseña es demasiado larga.',
    (LoginField.password, LoginFieldError.invalid) => 'Ingresa la contraseña.',
  };
}
