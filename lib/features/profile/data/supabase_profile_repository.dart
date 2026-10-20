import 'dart:io';

import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/profile_repository.dart';
import '../domain/staff_profile.dart';
import 'profile_row_mapper.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<StaffProfile?> fetchOwnProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final row = await _client
          .from('profiles')
          .select('id, full_name, role, is_active')
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      return mapProfileRow(row);
    } on ProfileDataFailure {
      rethrow;
    } on PostgrestException {
      throw const UnexpectedFailure();
    } on SocketException {
      throw const NetworkFailure();
    } on ClientException {
      throw const NetworkFailure();
    } on AuthException {
      throw const UnexpectedFailure();
    }
  }
}
