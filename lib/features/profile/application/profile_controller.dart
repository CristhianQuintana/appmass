import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/auth_providers.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/session_status.dart';
import '../../simulation/demo_mode.dart';
import '../../simulation/simulated_repositories.dart';
import '../data/disabled_profile_repository.dart';
import '../data/supabase_profile_repository.dart';
import '../domain/profile_repository.dart';
import '../domain/staff_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (ref.watch(demoModeProvider)) {
    return SimulatedProfileRepository(ref.watch(simulationStoreProvider));
  }
  final startup = ref.watch(startupProvider);
  if (!startup.canUseSupabase) return const DisabledProfileRepository();
  return SupabaseProfileRepository(ref.watch(supabaseClientProvider));
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, StaffProfile?>(
      ProfileController.new,
      retry: (retryCount, error) => null,
    );

class ProfileController extends AsyncNotifier<StaffProfile?> {
  @override
  Future<StaffProfile?> build() async {
    final session = ref.watch(sessionControllerProvider);
    if (session.status != SessionStatus.signedIn || session.identity == null) {
      return null;
    }
    return ref.read(profileRepositoryProvider).fetchOwnProfile();
  }
}
