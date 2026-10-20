import 'package:app_mass/features/profile/domain/profile_repository.dart';
import 'package:app_mass/features/profile/domain/staff_profile.dart';

import 'fake_auth_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this.auth);

  final FakeAuthRepository auth;
  final profiles = <String, StaffProfile?>{};
  Object? error;

  @override
  Future<StaffProfile?> fetchOwnProfile() async {
    final failure = error;
    if (failure != null) throw failure;
    final id = auth.current?.id;
    if (id == null) return null;
    return profiles[id];
  }
}
