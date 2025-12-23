import '../config/app_config.dart';
import '../models/owner.dart';
import '../models/bull.dart';
import 'api_service.dart';

class OwnerService {
  final ApiService _apiService = ApiService();

  Future<List<Owner>> getAllOwners({int? skip, int? limit, String? search}) async {
    try {
      String endpoint = AppConfig.publicOwners;
      List<String> queryParams = [];

      if (skip != null) queryParams.add('skip=$skip');
      if (limit != null) queryParams.add('limit=$limit');
      if (search != null && search.isNotEmpty) queryParams.add('search=$search');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      final data = _apiService.handleListResponse(response);

      return data.map((json) => Owner.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load owners: $e');
    }
  }

  Future<Owner> getOwnerById(String id) async {
    try {
      final endpoint = '${AppConfig.publicOwnerDetail}/$id';
      final response = await _apiService.get(endpoint);
      final data = _apiService.handleResponse(response);

      return Owner.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load owner details: $e');
    }
  }

  Future<List<Bull>> getOwnerBulls(String ownerId, {int? skip, int? limit}) async {
    try {
      String endpoint = '${AppConfig.publicOwnerDetail}/$ownerId/bulls';
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
      throw Exception('Failed to load owner bulls: $e');
    }
  }
}
