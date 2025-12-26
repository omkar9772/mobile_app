import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'secure_storage_service.dart';

class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<String?> _getToken() async {
    return await _secureStorage.getToken();
  }

  Map<String, String> _getHeaders({bool withAuth = false, String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (withAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Retry logic with exponential backoff
  Future<T> _retryRequest<T>(
    Future<T> Function() request, {
    int maxRetries = AppConfig.maxRetries,
  }) async {
    int retryCount = 0;
    Duration delay = const Duration(seconds: 1);

    while (true) {
      try {
        return await request();
      } on SocketException {
        if (retryCount >= maxRetries) {
          throw Exception('No internet connection. Please check your network and try again.');
        }
      } on TimeoutException {
        if (retryCount >= maxRetries) {
          throw Exception('Connection timeout. Please check your internet connection.');
        }
      } catch (e) {
        // Don't retry on other errors (like 4xx, 5xx)
        rethrow;
      }

      retryCount++;
      await Future.delayed(delay);
      delay *= 2; // Exponential backoff: 1s, 2s, 4s
    }
  }

  /// Handle better error messages
  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is TimeoutException) {
      return 'Connection timeout. Please try again.';
    } else if (error is HttpException) {
      return 'Server error. Please try again later.';
    } else {
      return error.toString();
    }
  }

  Future<http.Response> get(String endpoint, {bool withAuth = false}) async {
    return await _retryRequest(() async {
      final token = withAuth ? await _getToken() : null;
      final url = Uri.parse('$baseUrl$endpoint');

      try {
        final response = await http
            .get(
              url,
              headers: _getHeaders(withAuth: withAuth, token: token),
            )
            .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
        return response;
      } catch (e) {
        throw Exception(_getErrorMessage(e));
      }
    });
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    return await _retryRequest(() async {
      final token = withAuth ? await _getToken() : null;
      final url = Uri.parse('$baseUrl$endpoint');

      try {
        final response = await http
            .post(
              url,
              headers: _getHeaders(withAuth: withAuth, token: token),
              body: jsonEncode(body),
            )
            .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
        return response;
      } catch (e) {
        throw Exception(_getErrorMessage(e));
      }
    });
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    return await _retryRequest(() async {
      final token = withAuth ? await _getToken() : null;
      final url = Uri.parse('$baseUrl$endpoint');

      try {
        final response = await http
            .put(
              url,
              headers: _getHeaders(withAuth: withAuth, token: token),
              body: jsonEncode(body),
            )
            .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
        return response;
      } catch (e) {
        throw Exception(_getErrorMessage(e));
      }
    });
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    return await _retryRequest(() async {
      final token = withAuth ? await _getToken() : null;
      final url = Uri.parse('$baseUrl$endpoint');

      try {
        final response = await http
            .delete(
              url,
              headers: _getHeaders(withAuth: withAuth, token: token),
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));
        return response;
      } catch (e) {
        throw Exception(_getErrorMessage(e));
      }
    });
  }

  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired or unauthorized - logout user
      _handleUnauthorized();
      throw Exception('Session expired. Please login again.');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Request failed');
    }
  }

  List<dynamic> handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List;
    } else if (response.statusCode == 401) {
      // Token expired or unauthorized - logout user
      _handleUnauthorized();
      throw Exception('Session expired. Please login again.');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Request failed');
    }
  }

  /// Handle unauthorized (401) responses by clearing stored credentials
  Future<void> _handleUnauthorized() async {
    await _secureStorage.clearAll();
  }
}
