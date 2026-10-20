/// Identidad autenticada. No contiene tokens ni el rol de negocio.
class AuthIdentity {
  const AuthIdentity({required this.id, required this.email});

  final String id;
  final String email;
}
