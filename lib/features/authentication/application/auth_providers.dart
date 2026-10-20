import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/startup/startup_state.dart';
import '../../simulation/demo_mode.dart';
import '../../simulation/simulated_repositories.dart';
import '../../simulation/simulation_store.dart';
import '../data/disabled_auth_repository.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';

final startupProvider = Provider<StartupState>(
  (ref) =>
      const StartupState(config: AppConfig.empty, supabaseInitialized: false),
);

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final startup = ref.watch(startupProvider);
  if (!startup.canUseSupabase) {
    throw StateError('Supabase no está inicializado.');
  }
  return Supabase.instance.client;
});

final simulationStoreProvider = Provider<SimulationStore>((ref) {
  final store = SimulationStore.seeded();
  ref.onDispose(store.dispose);
  return store;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(demoModeProvider)) {
    return SimulatedAuthRepository(ref.watch(simulationStoreProvider));
  }
  final startup = ref.watch(startupProvider);
  if (!startup.canUseSupabase) return const DisabledAuthRepository();
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});
