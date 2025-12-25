class AppConfig {
  // API Configuration
  // IMPORTANT: Update this URL to match your backend deployment
  // Examples:
  //   - Local development: 'http://localhost:8000/api/v1'
  //   - Android emulator: 'http://10.0.2.2:8000/api/v1'
  //   - Production: 'https://naad-bailgada-api-834379191950.asia-south1.run.app/api/v1'
  static const String apiBaseUrl = 'https://naad-bailgada-api-834379191950.asia-south1.run.app/api/v1';

  // Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authChangePassword = '/auth/change-password';
  static const String authUpdateProfile = '/auth/update-profile';

  static const String publicRaces = '/public/races';
  static const String publicRecentRaces = '/public/races/recent';
  static const String publicUpcomingRaces = '/public/races/upcoming';
  static const String publicRaceDetail = '/public/races';
  static const String publicBulls = '/public/bulls';
  static const String publicBullDetail = '/public/bulls';
  static const String publicOwners = '/public/owners';
  static const String publicOwnerDetail = '/public/owners';
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

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetries = 3;

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 80;
  static const int maxImageDimension = 1024;

  // Search Configuration
  static const int searchDebounceMs = 300;

  // Environment helpers
  static bool get isLocalDevelopment => apiBaseUrl.contains('localhost') || apiBaseUrl.contains('127.0.0.1');
  static bool get isProduction => !isLocalDevelopment;
}
