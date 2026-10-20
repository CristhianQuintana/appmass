import '../../../core/errors/app_failure.dart';
import '../domain/staff_profile.dart';
import '../domain/staff_role.dart';

StaffProfile mapProfileRow(Map<String, dynamic> row) {
  final id = row['id'];
  final active = row['is_active'];
  if (id is! String || id.isEmpty || active is! bool) {
    throw const ProfileDataFailure();
  }
  final name = row['full_name'];
  final role = row['role'];
  return StaffProfile(
    id: id,
    fullName: name is String ? name : '',
    role: StaffRole.fromStorage(role is String ? role : null),
    isActive: active,
  );
}
