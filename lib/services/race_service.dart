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
      final responseData = _apiService.handleResponse(response);
      final data = responseData['data'] as List;

      return data.map((json) => Race.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load races: $e');
    }
  }

  Future<List<Race>> getRecentRaces({int limit = 4}) async {
    try {
      final endpoint = '${AppConfig.publicRecentRaces}?limit=$limit';
      final response = await _apiService.get(endpoint);
      final responseData = _apiService.handleResponse(response);
      final data = responseData['data'] as List;

      return data.map((json) => Race.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load recent races: $e');
    }
  }

  Future<List<Race>> getUpcomingRaces({int limit = 4}) async {
    try {
      final endpoint = '${AppConfig.publicUpcomingRaces}?limit=$limit';
      final response = await _apiService.get(endpoint);
      final responseData = _apiService.handleResponse(response);
      final data = responseData['data'] as List;

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

  Future<List<RaceDay>> getRaceDays(String raceId, {int? skip, int? limit}) async {
    try {
      String endpoint = '/public/races/$raceId/days';
      List<String> queryParams = [];

      if (skip != null) queryParams.add('skip=$skip');
      if (limit != null) queryParams.add('limit=$limit');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      final responseData = _apiService.handleResponse(response);
      final data = responseData['data'] as List;

      return data.map((json) => RaceDay.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load race days: $e');
    }
  }

  Future<List<RaceResult>> getDayResults(String dayId, {int? skip, int? limit}) async {
    try {
      String endpoint = '/public/races/days/$dayId/results';
      List<String> queryParams = [];

      if (skip != null) queryParams.add('skip=$skip');
      if (limit != null) queryParams.add('limit=$limit');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      final responseData = _apiService.handleResponse(response);
      final data = responseData['data'] as List;

      return data.map((json) => RaceResult.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load day results: $e');
    }
  }
}
