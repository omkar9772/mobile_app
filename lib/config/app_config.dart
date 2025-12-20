class AppConfig {
  // API Configuration
  // IMPORTANT: Update this URL to match your backend deployment
  // Examples:
  //   - Local development: 'http://localhost:8000/api/v1'
  //   - Android emulator: 'http://10.0.2.2:8000/api/v1'
  //   - Production: 'https://your-backend-url.com/api/v1'
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';

  // Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authChangePassword = '/auth/change-password';

  static const String publicRaces = '/public/races';
  static const String publicRecentRaces = '/public/races/recent';
  static const String publicUpcomingRaces = '/public/races/upcoming';
  static const String publicRaceDetail = '/public/races';
  static const String publicBulls = '/public/bulls';
  static const String publicBullDetail = '/public/bulls';
  static const String publicSearch = '/public/search';
  static const String publicUserBullsSell = '/public/user-bulls-sell';

  // User Bulls for Sale
  static const String userBulls = '/user/bulls';

  // Pagination
  static const int itemsPerPage = 50;
  static const int homeRecentRaces = 4;
  static const int homeUpcomingRaces = 4;

  // Storage Keys
  static const String tokenKey = 'naad_auth_token';
  static const String userKey = 'naad_user';

  // Environment helpers
  static bool get isLocalDevelopment => apiBaseUrl.contains('localhost') || apiBaseUrl.contains('127.0.0.1');
  static bool get isProduction => !isLocalDevelopment;
}
