import 'package:flutter/material.dart';
import '../models/marketplace_listing.dart';
import '../services/marketplace_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceService _marketplaceService = MarketplaceService();
  
  List<MarketplaceListing> _listings = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;

  List<MarketplaceListing> get listings => _listings;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  Future<void> loadListings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _listings = await _marketplaceService.getAvailableBulls(limit: 50);
      _isLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
