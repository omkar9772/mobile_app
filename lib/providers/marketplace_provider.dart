import 'package:flutter/material.dart';
import '../models/marketplace_listing.dart';
import '../services/marketplace_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceService _marketplaceService = MarketplaceService();

  List<MarketplaceListing> _listings = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;

  // Pagination state
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<MarketplaceListing> get listings => _listings;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  // Pagination getters
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadListings() async {
    _isLoading = true;
    _error = null;
    // Reset pagination
    _currentPage = 0;
    _hasMore = true;
    _listings = [];
    notifyListeners();

    try {
      final listings = await _marketplaceService.getAvailableBulls(skip: 0, limit: 50);
      _listings = listings;
      _isLoaded = true;
      _currentPage = 1;

      if (listings.length < 50) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreListings() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final skip = _currentPage * 50;
      final newListings = await _marketplaceService.getAvailableBulls(skip: skip, limit: 50);

      if (newListings.isEmpty || newListings.length < 50) {
        _hasMore = false;
      }

      _listings.addAll(newListings);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
