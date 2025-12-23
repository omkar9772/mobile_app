import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Secure storage service for sensitive data like tokens and user info
/// Uses flutter_secure_storage for encryption
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  bool _hasMigrated = false;

  /// Migrate existing data from SharedPreferences to secure storage
  /// This ensures backward compatibility
  Future<void> _migrateFromSharedPreferences() async {
    if (_hasMigrated) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if there's a token in SharedPreferences
      final token = prefs.getString(AppConfig.tokenKey);
      if (token != null) {
        // Migrate to secure storage
        await _secureStorage.write(key: AppConfig.tokenKey, value: token);
        await prefs.remove(AppConfig.tokenKey);
      }

      // Check if there's user data in SharedPreferences
      final userData = prefs.getString(AppConfig.userKey);
      if (userData != null) {
        // Migrate to secure storage
        await _secureStorage.write(key: AppConfig.userKey, value: userData);
        await prefs.remove(AppConfig.userKey);
      }

      _hasMigrated = true;
    } catch (e) {
      // Migration failed, but continue - secure storage will work for new data
      _hasMigrated = true;
    }
  }

  /// Save authentication token securely
  Future<void> saveToken(String token) async {
    await _migrateFromSharedPreferences();
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    await _migrateFromSharedPreferences();
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
  }

  /// Save user data securely
  Future<void> saveUser(String userData) async {
    await _migrateFromSharedPreferences();
    await _secureStorage.write(key: AppConfig.userKey, value: userData);
  }

  /// Get user data
  Future<String?> getUser() async {
    await _migrateFromSharedPreferences();
    return await _secureStorage.read(key: AppConfig.userKey);
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _secureStorage.delete(key: AppConfig.userKey);
  }

  /// Check if user is logged in (has token)
  Future<bool> hasToken() async {
    await _migrateFromSharedPreferences();
    final token = await _secureStorage.read(key: AppConfig.tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Clear all secure storage (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
