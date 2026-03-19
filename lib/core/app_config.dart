class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5152',
  );

  static String get _normalizedBaseUrl {
    return apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
  }

  static Uri get registerUri =>
      Uri.parse('$_normalizedBaseUrl/api/Authentication/register');

  static Uri get loginUri =>
      Uri.parse('$_normalizedBaseUrl/api/authentication/login');

  static Uri get refreshUri =>
      Uri.parse('$_normalizedBaseUrl/api/authentication/refresh');

  static Uri get meUri => Uri.parse('$_normalizedBaseUrl/me');

  static Uri get meProfileImageUri =>
      Uri.parse('$_normalizedBaseUrl/me/profile-image');
}
