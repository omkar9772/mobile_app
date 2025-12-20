import '../config/app_config.dart';
import '../models/marketplace_listing.dart';
import 'api_service.dart';

class MarketplaceService {
  final ApiService _apiService = ApiService();

  Future<List<MarketplaceListing>> getAvailableBulls({int? skip, int? limit}) async {
    try {
      String endpoint = '/public/available-bulls';
      List<String> queryParams = [];

      if (skip != null) queryParams.add('skip=$skip');
      if (limit != null) queryParams.add('limit=$limit');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      final data = _apiService.handleListResponse(response);

      return data.map((json) => MarketplaceListing.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load available bulls: $e');
    }
  }

  Future<MarketplaceListing> getListingById(String id) async {
    try {
      final endpoint = '/public/available-bulls/$id';
      final response = await _apiService.get(endpoint);
      final data = _apiService.handleResponse(response);

      return MarketplaceListing.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load listing details: $e');
    }
  }
}
