import 'dart:convert';
import '../config/app_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasToken();
  }

  Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.getUser();
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.authLogin,
        request.toJson(),
      );

      final data = _apiService.handleResponse(response);
      final authResponse = AuthResponse.fromJson(data);

      // Store token securely
      await _secureStorage.saveToken(authResponse.accessToken);

      // Fetch and store full user profile from backend
      await getCurrentUserFromApi();

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.authRegister,
        request.toJson(),
      );

      final data = _apiService.handleResponse(response);
      final user = User.fromJson(data);

      // Auto login after registration
      await login(LoginRequest(
        username: request.username,
        password: request.password,
      ));

      // Store full user data after login (securely)
      await _secureStorage.saveUser(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<User> getCurrentUserFromApi() async {
    try {
      final response = await _apiService.get(
        AppConfig.authMe,
        withAuth: true,
      );

      final data = _apiService.handleResponse(response);
      final user = User.fromJson(data);

      // Update stored user info securely
      await _secureStorage.saveUser(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  Future<void> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        AppConfig.authChangePassword,
        {
          'username': username,
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      _apiService.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<User> updateProfile(UpdateUserRequest request) async {
    try {
      final response = await _apiService.put(
        AppConfig.authUpdateProfile,
        request.toJson(),
        withAuth: true,
      );

      final data = _apiService.handleResponse(response);
      final user = User.fromJson(data);

      // Update stored user info securely
      await _secureStorage.saveUser(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
