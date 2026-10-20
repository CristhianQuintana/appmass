import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../core/security/secure_session_storage.dart';
import '../core/startup/startup_state.dart';

const sessionStorageKey = 'mass-auth-session';

Future<StartupState> bootstrap() async {
  final config = AppConfig.fromEnvironment();
  if (!config.isConfigured) {
    return StartupState(config: config, supabaseInitialized: false);
  }

  try {
    await Supabase.initialize(
      url: config.supabaseUrl.trim(),
      publishableKey: config.supabaseAnonKey.trim(),
      debug: false,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        localStorage: SecureLocalStorage(persistSessionKey: sessionStorageKey),
        pkceAsyncStorage: SecureGotrueStorage(),
      ),
    );
    return StartupState(config: config, supabaseInitialized: true);
  } on Object {
    return StartupState(
      config: config,
      supabaseInitialized: false,
      initializationFailed: true,
    );
  }
}
