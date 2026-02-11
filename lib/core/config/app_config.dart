// lib/core/config/app_config.dart
class AppConfig {
  // चाहें तो --dart-define से override करें
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://sevenoath.shofus.com',
  );

  static const connectTimeout = Duration(seconds: 12);
  static const receiveTimeout = Duration(seconds: 20);
}
