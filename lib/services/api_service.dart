import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
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

  Future<http.Response> get(String endpoint, {bool withAuth = false}) async {
    final token = withAuth ? await _getToken() : null;
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(
        url,
        headers: _getHeaders(withAuth: withAuth, token: token),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final token = withAuth ? await _getToken() : null;
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(withAuth: withAuth, token: token),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final token = withAuth ? await _getToken() : null;
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.put(
        url,
        headers: _getHeaders(withAuth: withAuth, token: token),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> delete(String endpoint, {bool withAuth = false}) async {
    final token = withAuth ? await _getToken() : null;
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.delete(
        url,
        headers: _getHeaders(withAuth: withAuth, token: token),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Request failed');
    }
  }

  List<dynamic> handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Request failed');
    }
  }
}
