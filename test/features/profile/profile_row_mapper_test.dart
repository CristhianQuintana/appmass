import 'package:app_mass/core/errors/app_failure.dart';
import 'package:app_mass/features/profile/data/profile_row_mapper.dart';
import 'package:app_mass/features/profile/domain/staff_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interpreta un perfil operativo y niega un rol desconocido', () {
    final profile = mapProfileRow({
      'id': 'user-1',
      'full_name': 'Ana',
      'role': 'operator',
      'is_active': true,
    });

    expect(profile.role, StaffRole.operator);
    expect(profile.isOperational, isTrue);

    final unknown = mapProfileRow({
      'id': 'user-1',
      'full_name': 'Ana',
      'role': 'owner',
      'is_active': true,
    });
    expect(unknown.role, StaffRole.unassigned);
    expect(unknown.isOperational, isFalse);
  });

  test('un estado de cuenta ilegible no se asume activo', () {
    expect(
      () => mapProfileRow({
        'id': 'user-1',
        'full_name': 'Ana',
        'role': 'administrator',
        'is_active': 'true',
      }),
      throwsA(isA<ProfileDataFailure>()),
    );
  });
}
