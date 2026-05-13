import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get appEnv => dotenv.maybeGet('APP_ENV') ?? 'dev';
  static bool get isProduction => appEnv == 'prod';
  static bool get isDevelopment => appEnv == 'dev';

  static String? get apiBaseUrl => dotenv.maybeGet('API_BASE_URL');
  static String? get sentryDsn => dotenv.maybeGet('SENTRY_DSN');
}
