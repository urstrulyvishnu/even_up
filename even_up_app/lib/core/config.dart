class AppConfig {
  static const bool isLocal = true;
  static const String localBaseUrl = 'http://localhost:3000';
  static const String cloudBaseUrl = 'https://your-api-gateway-url.amazonaws.com/prod';

  static String get baseUrl => isLocal ? localBaseUrl : cloudBaseUrl;
}
