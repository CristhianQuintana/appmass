import 'staff_profile.dart';

abstract class ProfileRepository {
  /// Consulta únicamente el perfil de la identidad autenticada.
  Future<StaffProfile?> fetchOwnProfile();
}
