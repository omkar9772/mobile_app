import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConfig.tokenKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConfig.userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.authLogin,
        request.toJson(),
      );

      final data = _apiService.handleResponse(response);
      final authResponse = AuthResponse.fromJson(data);

      // Store token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.tokenKey, authResponse.accessToken);

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

      // Store full user data after login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));

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

      // Update stored user info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
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
}
