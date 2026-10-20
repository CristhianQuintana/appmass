import 'dart:convert';

/// Configuración pública del cliente. Nunca incluye `service_role`.
class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.supabaseAnonKey});

  final String supabaseUrl;
  final String supabaseAnonKey;

  static const empty = AppConfig(supabaseUrl: '', supabaseAnonKey: '');

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  ConfigProblem get problem {
    final url = supabaseUrl.trim();
    final key = supabaseAnonKey.trim();
    if (url.isEmpty) return ConfigProblem.missingUrl;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return ConfigProblem.insecureUrl;
    }
    if (key.isEmpty) return ConfigProblem.missingKey;
    if (_isPrivilegedKey(key)) return ConfigProblem.privilegedKey;
    return ConfigProblem.none;
  }

  bool get isConfigured => problem == ConfigProblem.none;
}

enum ConfigProblem { none, missingUrl, insecureUrl, missingKey, privilegedKey }

bool _isPrivilegedKey(String key) {
  final normalized = key.toLowerCase();
  if (normalized.startsWith('sb_secret_')) return true;
  return _jwtRole(key) == 'service_role';
}

String? _jwtRole(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final decoded = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final payload = jsonDecode(decoded);
    if (payload is Map<String, dynamic> && payload['role'] is String) {
      return payload['role'] as String;
    }
  } on Object {
    return null;
  }
  return null;
}
