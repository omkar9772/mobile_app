import '../config/app_config.dart';
import '../models/race.dart';
import 'api_service.dart';

class RaceService {
  final ApiService _apiService = ApiService();

  Future<List<Race>> getAllRaces({int? skip, int? limit}) async {
    try {
      String endpoint = AppConfig.publicRaces;
      List<String> queryParams = [];

      if (skip != null) queryParams.add('skip=$skip');
      if (limit != null) queryParams.add('limit=$limit');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      final data = _apiService.handleListResponse(response);

      return data.map((json) => Race.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load races: $e');
    }
  }

  Future<List<Race>> getRecentRaces({int limit = 4}) async {
    try {
      final endpoint = '${AppConfig.publicRecentRaces}?limit=$limit';
      final response = await _apiService.get(endpoint);
      final data = _apiService.handleListResponse(response);

      return data.map((json) => Race.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load recent races: $e');
    }
  }

  Future<List<Race>> getUpcomingRaces({int limit = 4}) async {
    try {
      final endpoint = '${AppConfig.publicUpcomingRaces}?limit=$limit';
      final response = await _apiService.get(endpoint);
      final data = _apiService.handleListResponse(response);

      return data.map((json) => Race.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load upcoming races: $e');
    }
  }

  Future<Race> getRaceById(String id) async {
    try {
      final endpoint = '${AppConfig.publicRaceDetail}/$id';
      final response = await _apiService.get(endpoint);
      final data = _apiService.handleResponse(response);

      return Race.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load race details: $e');
    }
  }
}
