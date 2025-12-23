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

  // Pagination state
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<Bull> get bulls => _filteredBulls;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;
  String get filterType => _filterType;

  Bull? get currentBull => _currentBull;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorDetails => _errorDetails;

  // Pagination getters
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadBulls({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      // Reset pagination
      _currentPage = 0;
      _hasMore = true;
      _bulls = [];
      _filteredBulls = [];
      notifyListeners();
    }

    try {
      final bulls = await _bullService.getAllBulls(skip: 0, limit: 50);
      _bulls = bulls;
      _filteredBulls = List.from(_bulls);
      _applyFilters();
      _isLoaded = true;
      _currentPage = 1;

      if (bulls.length < 50) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreBulls() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final skip = _currentPage * 50;
      final newBulls = await _bullService.getAllBulls(skip: skip, limit: 50);

      if (newBulls.isEmpty || newBulls.length < 50) {
        _hasMore = false;
      }

      _bulls.addAll(newBulls);
      _filteredBulls = List.from(_bulls);
      _applyFilters();
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
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
      final detailedBull = await _bullService.getBullById(id);

      // Use the detail API data directly
      // Detail API returns original high-quality image for better viewing
      _currentBull = detailedBull;
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
