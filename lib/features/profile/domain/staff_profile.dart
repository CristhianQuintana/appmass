import 'staff_role.dart';

class StaffProfile {
  const StaffProfile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String fullName;
  final StaffRole role;
  final bool isActive;

  bool get isOperational => isActive && role.isOperational;

  String get displayName {
    final trimmed = fullName.trim();
    return trimmed.isEmpty ? 'Colaborador' : trimmed;
  }
}
