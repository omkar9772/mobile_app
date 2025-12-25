import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../models/user_bull_sell.dart';
import '../utils/image_compression_helper.dart';
import 'secure_storage_service.dart';

class UserBullService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<String?> _getToken() async {
    return await _secureStorage.getToken();
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
    required String ownerName,
    required String ownerMobile,
    File? imageFile,
    XFile? imageXFile,
    String? breed,
    int? birthYear,
    String? color,
    String? description,
    String? location,
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
      request.fields['owner_name'] = ownerName;
      request.fields['owner_mobile'] = ownerMobile;

      if (breed != null) request.fields['breed'] = breed;
      if (birthYear != null) request.fields['birth_year'] = birthYear.toString();
      if (color != null) request.fields['color'] = color;
      if (description != null) request.fields['description'] = description;
      if (location != null) request.fields['location'] = location;

      // Add image file - compress first, then upload
      if (kIsWeb && imageXFile != null) {
        final bytes = await imageXFile.readAsBytes();
        final extension = imageXFile.name.toLowerCase().split('.').last;
        final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageXFile.name,
            contentType: http.MediaType.parse(contentType),
          ),
        );
      } else if (imageFile != null) {
        // Validate and compress image before upload
        if (!await ImageCompressionHelper.validateImage(imageFile)) {
          throw Exception('Invalid image file. Please select a valid image (max 5MB).');
        }

        // Compress the image
        final compressedImage = await ImageCompressionHelper.compressImage(imageFile);
        final extension = compressedImage.path.toLowerCase().split('.').last;
        final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            compressedImage.path,
            contentType: http.MediaType.parse(contentType),
          ),
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
    String? ownerName,
    String? ownerMobile,
    File? imageFile,
    XFile? imageXFile,
    String? breed,
    int? birthYear,
    String? color,
    String? description,
    String? location,
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

      // Add required fields (always sent if provided)
      if (name != null) request.fields['name'] = name;
      if (price != null) request.fields['price'] = price.toString();
      if (ownerName != null) request.fields['owner_name'] = ownerName;
      if (ownerMobile != null) request.fields['owner_mobile'] = ownerMobile;

      // Add optional fields (only if provided and not empty)
      if (breed != null && breed.isNotEmpty) request.fields['breed'] = breed;
      if (birthYear != null) request.fields['birth_year'] = birthYear.toString();
      if (color != null && color.isNotEmpty) request.fields['color'] = color;
      if (description != null && description.isNotEmpty) request.fields['description'] = description;
      if (location != null && location.isNotEmpty) request.fields['location'] = location;
      if (status != null && status.isNotEmpty) request.fields['status'] = status;

      // Add image file if provided - compress first
      if (kIsWeb && imageXFile != null) {
        final bytes = await imageXFile.readAsBytes();
        final extension = imageXFile.name.toLowerCase().split('.').last;
        final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageXFile.name,
            contentType: http.MediaType.parse(contentType),
          ),
        );
      } else if (imageFile != null) {
        // Validate and compress image before upload
        if (!await ImageCompressionHelper.validateImage(imageFile)) {
          throw Exception('Invalid image file. Please select a valid image (max 5MB).');
        }

        // Compress the image
        final compressedImage = await ImageCompressionHelper.compressImage(imageFile);
        final extension = compressedImage.path.toLowerCase().split('.').last;
        final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            compressedImage.path,
            contentType: http.MediaType.parse(contentType),
          ),
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
