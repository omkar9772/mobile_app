import 'package:flutter/material.dart';
import '../models/bull.dart';
import '../services/bull_service.dart';

class BullProvider extends ChangeNotifier {
  final BullService _bullService = BullService();
  
  List<Bull> _bulls = [];
  List<Bull> _filteredBulls = [];
  bool _isLoading = false;
  String? _error;
  
  // Filter state
  String _filterType = 'all';
  String _searchQuery = '';

  // Detail state
  Bull? _currentBull;
  bool _isLoadingDetails = false;
  String? _errorDetails;
  
  // Lazy loading state
  bool _isLoaded = false;

  List<Bull> get bulls => _filteredBulls;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;
  String get filterType => _filterType;

  Bull? get currentBull => _currentBull;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorDetails => _errorDetails;

  Future<void> loadBulls({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _bulls = await _bullService.getAllBulls(limit: 50);
      _filteredBulls = List.from(_bulls); // Initial copy for filtering
      _applyFilters();
      _isLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBullById(String id) async {
    // If we're already showing this bull, don't clear it to prevent UI flicker
    if (_currentBull?.id != id) {
      _currentBull = null;
    }
    
    _isLoadingDetails = true;
    _errorDetails = null;
    notifyListeners();

    try {
      _currentBull = await _bullService.getBullById(id);
    } catch (e) {
      _errorDetails = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  void setFilterType(String type) {
    _filterType = type;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredBulls = List.from(_bulls);
    } else {
      _filteredBulls = _bulls.where((bull) {
        switch (_filterType) {
          case 'name':
            return bull.name.toLowerCase().contains(_searchQuery);
          case 'owner':
            return bull.ownerName?.toLowerCase().contains(_searchQuery) ?? false;
          case 'location':
            return bull.ownerAddress?.toLowerCase().contains(_searchQuery) ?? false;
          case 'all':
          default:
            return bull.name.toLowerCase().contains(_searchQuery) ||
                   (bull.ownerName?.toLowerCase().contains(_searchQuery) ?? false) ||
                   (bull.ownerAddress?.toLowerCase().contains(_searchQuery) ?? false);
        }
      }).toList();
    }
  }
}
