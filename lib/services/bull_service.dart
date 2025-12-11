import '../config/app_config.dart';
import '../models/bull.dart';
import 'api_service.dart';

class BullService {
  final ApiService _apiService = ApiService();

  Future<List<Bull>> getAllBulls({int? skip, int? limit}) async {
    try {
      String endpoint = AppConfig.publicBulls;
      List<String> queryParams = [];

      if (skip != null) queryParams.add('skip=$skip');
      if (limit != null) queryParams.add('limit=$limit');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      final data = _apiService.handleListResponse(response);

      return data.map((json) => Bull.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load bulls: $e');
    }
  }

  Future<Bull> getBullById(String id) async {
    try {
      final endpoint = '${AppConfig.publicBullDetail}/$id';
      final response = await _apiService.get(endpoint);
      final data = _apiService.handleResponse(response);

      return Bull.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load bull details: $e');
    }
  }
}
