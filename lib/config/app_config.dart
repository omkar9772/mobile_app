class AppConfig {
  // API Configuration
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

  // Pagination
  static const int itemsPerPage = 50;
  static const int homeRecentRaces = 4;
  static const int homeUpcomingRaces = 4;

  // Storage Keys
  static const String tokenKey = 'naad_auth_token';
  static const String userKey = 'naad_user';
}
