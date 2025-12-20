import 'package:flutter/material.dart';
import '../models/race.dart';
import '../services/race_service.dart';

class RaceProvider extends ChangeNotifier {
  final RaceService _raceService = RaceService();
  
  // Lists
  List<Race> _allRaces = [];
  List<Race> _recentRaces = [];
  List<Race> _upcomingRaces = [];
  List<RaceDay> _raceDays = [];
  List<RaceResult> _dayResults = [];
  
  // Loading states
  bool _isLoadingAll = false;
  bool _isLoadingHome = false;
  bool _isLoadingDays = false;
  bool _isLoadingResults = false;
  
  // Loaded states
  bool _isLoadedAll = false;
  bool _isLoadedHome = false;
  
  // Error states
  String? _errorAll;
  String? _errorHome;
  String? _errorDays;
  String? _errorResults;

  // Getters
  List<Race> get allRaces => _allRaces;
  List<Race> get recentRaces => _recentRaces;
  List<Race> get upcomingRaces => _upcomingRaces;
  List<RaceDay> get raceDays => _raceDays;
  List<RaceResult> get dayResults => _dayResults;
  
  bool get isLoadingAll => _isLoadingAll;
  bool get isLoadingHome => _isLoadingHome;
  bool get isLoadingDays => _isLoadingDays;
  bool get isLoadingResults => _isLoadingResults;
  
  bool get isLoadedAll => _isLoadedAll;
  bool get isLoadedHome => _isLoadedHome;
  
  String? get errorAll => _errorAll;
  String? get errorHome => _errorHome;
  String? get errorDays => _errorDays;
  String? get errorResults => _errorResults;

  Future<void> loadAllRaces() async {
    _isLoadingAll = true;
    _errorAll = null;
    notifyListeners();

    try {
      _allRaces = await _raceService.getAllRaces(limit: 50);
      _isLoadedAll = true;
    } catch (e) {
      _errorAll = e.toString();
    } finally {
      _isLoadingAll = false;
      notifyListeners();
    }
  }

  Future<void> loadHomeRaces() async {
    _isLoadingHome = true;
    _errorHome = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _raceService.getRecentRaces(limit: 4),
        _raceService.getUpcomingRaces(limit: 4),
      ]);
      
      _recentRaces = results[0];
      _upcomingRaces = results[1];
      _isLoadedHome = true;
    } catch (e) {
      _errorHome = e.toString();
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  Future<void> loadRaceDays(String raceId) async {
    _isLoadingDays = true;
    _errorDays = null;
    _raceDays = []; // Clear previous
    notifyListeners();

    try {
      _raceDays = await _raceService.getRaceDays(raceId, limit: 100);
    } catch (e) {
      _errorDays = e.toString();
    } finally {
      _isLoadingDays = false;
      notifyListeners();
    }
  }

  Future<void> loadDayResults(String dayId) async {
    _isLoadingResults = true;
    _errorResults = null;
    _dayResults = []; // Clear previous
    notifyListeners();

    try {
      _dayResults = await _raceService.getDayResults(dayId);
    } catch (e) {
      _errorResults = e.toString();
    } finally {
      _isLoadingResults = false;
      notifyListeners();
    }
  }
}
