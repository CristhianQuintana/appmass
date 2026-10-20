import '../../../core/errors/app_failure.dart';
import '../domain/profile_repository.dart';
import '../domain/staff_profile.dart';

class DisabledProfileRepository implements ProfileRepository {
  const DisabledProfileRepository();

  @override
  Future<StaffProfile?> fetchOwnProfile() {
    throw const ConfigurationFailure();
  }
}
