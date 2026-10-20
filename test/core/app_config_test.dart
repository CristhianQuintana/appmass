import 'dart:convert';

import 'package:app_mass/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rechaza una configuración vacía', () {
    expect(AppConfig.empty.isConfigured, isFalse);
    expect(AppConfig.empty.problem, ConfigProblem.missingUrl);
    expect(AppConfig.fromEnvironment().isConfigured, isFalse);
  });

  test('exige HTTPS y una clave pública de cliente', () {
    const insecure = AppConfig(
      supabaseUrl: 'http://example.supabase.co',
      supabaseAnonKey: 'sb_publishable_test',
    );
    const withUserInfo = AppConfig(
      supabaseUrl: 'https://user:secret@example.supabase.co',
      supabaseAnonKey: 'sb_publishable_test',
    );
    const missingKey = AppConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: '',
    );
    const ready = AppConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'sb_publishable_test',
    );

    expect(insecure.problem, ConfigProblem.insecureUrl);
    expect(withUserInfo.problem, ConfigProblem.insecureUrl);
    expect(missingKey.problem, ConfigProblem.missingKey);
    expect(ready.isConfigured, isTrue);
  });

  test('rechaza una clave privilegiada', () {
    final serviceRole = AppConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: _jwt('service_role'),
    );
    final secretKey = AppConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'sb_secret_test',
    );
    final anonKey = AppConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: _jwt('anon'),
    );

    expect(serviceRole.problem, ConfigProblem.privilegedKey);
    expect(secretKey.problem, ConfigProblem.privilegedKey);
    expect(anonKey.isConfigured, isTrue);
  });
}

String _jwt(String role) {
  String encode(String value) {
    return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
  }

  return '${encode('{"alg":"none"}')}.${encode('{"role":"$role"}')}.sig';
}
