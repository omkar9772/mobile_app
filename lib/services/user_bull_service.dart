import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_bull_sell.dart';

class UserBullService {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Get all bulls listed by the current user
  Future<UserBullSellList> getMyBulls() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final url = Uri.parse('$baseUrl${AppConfig.userBulls}');

    try {
      final response = await http.get(
        url,
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserBullSellList.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load bulls');
      }
    } catch (e) {
      throw Exception('Failed to load bulls: $e');
    }
  }

  /// Get details of a specific bull
  Future<UserBullSell> getBullById(String id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final url = Uri.parse('$baseUrl${AppConfig.userBulls}/$id');

    try {
      final response = await http.get(
        url,
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserBullSell.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load bull details');
      }
    } catch (e) {
      throw Exception('Failed to load bull details: $e');
    }
  }

  /// Create a new bull listing
  Future<UserBullSell> createBull({
    required String name,
    required double price,
    File? imageFile,
    XFile? imageXFile,
    String? breed,
    int? birthYear,
    String? color,
    String? description,
    String? location,
    String? ownerMobile,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final url = Uri.parse('$baseUrl${AppConfig.userBulls}');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll(_getAuthHeaders(token));

      // Add fields
      request.fields['name'] = name;
      request.fields['price'] = price.toString();

      if (breed != null) request.fields['breed'] = breed;
      if (birthYear != null) request.fields['birth_year'] = birthYear.toString();
      if (color != null) request.fields['color'] = color;
      if (description != null) request.fields['description'] = description;
      if (location != null) request.fields['location'] = location;
      if (ownerMobile != null) request.fields['owner_mobile'] = ownerMobile;

      // Add image file - use bytes for web compatibility
      if (kIsWeb && imageXFile != null) {
        final bytes = await imageXFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageXFile.name,
          ),
        );
      } else if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      } else {
        throw Exception('No image provided');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserBullSell.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to create bull listing');
      }
    } catch (e) {
      throw Exception('Failed to create bull listing: $e');
    }
  }

  /// Update an existing bull listing
  Future<UserBullSell> updateBull({
    required String id,
    String? name,
    double? price,
    File? imageFile,
    String? breed,
    int? birthYear,
    String? color,
    String? description,
    String? location,
    String? ownerMobile,
    String? status,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final url = Uri.parse('$baseUrl${AppConfig.userBulls}/$id');

    try {
      var request = http.MultipartRequest('PUT', url);

      // Add headers
      request.headers.addAll(_getAuthHeaders(token));

      // Add fields (only if provided)
      if (name != null) request.fields['name'] = name;
      if (price != null) request.fields['price'] = price.toString();
      if (breed != null) request.fields['breed'] = breed;
      if (birthYear != null) request.fields['birth_year'] = birthYear.toString();
      if (color != null) request.fields['color'] = color;
      if (description != null) request.fields['description'] = description;
      if (location != null) request.fields['location'] = location;
      if (ownerMobile != null) request.fields['owner_mobile'] = ownerMobile;
      if (status != null) request.fields['status'] = status;

      // Add image file if provided
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserBullSell.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to update bull listing');
      }
    } catch (e) {
      throw Exception('Failed to update bull listing: $e');
    }
  }

  /// Delete a bull listing
  Future<void> deleteBull(String id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final url = Uri.parse('$baseUrl${AppConfig.userBulls}/$id');

    try {
      final response = await http.delete(
        url,
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete bull listing');
      }
    } catch (e) {
      throw Exception('Failed to delete bull listing: $e');
    }
  }

  /// Get all available user bulls (public endpoint)
  Future<List<UserBullSell>> getAvailableUserBulls({int skip = 0, int limit = 20}) async {
    final url = Uri.parse(
      '$baseUrl${AppConfig.publicUserBullsSell}?skip=$skip&limit=$limit',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => UserBullSell.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load available bulls');
      }
    } catch (e) {
      throw Exception('Failed to load available bulls: $e');
    }
  }

  /// Get details of a specific user bull (public endpoint)
  Future<UserBullSell> getPublicBullById(String id) async {
    final url = Uri.parse('$baseUrl${AppConfig.publicUserBullsSell}/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserBullSell.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to load bull details');
      }
    } catch (e) {
      throw Exception('Failed to load bull details: $e');
    }
  }
}
