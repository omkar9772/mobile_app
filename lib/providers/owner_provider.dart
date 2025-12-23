import 'package:flutter/material.dart';
import '../models/owner.dart';
import '../services/owner_service.dart';

class OwnerProvider extends ChangeNotifier {
  final OwnerService _ownerService = OwnerService();

  List<Owner> _owners = [];
  List<Owner> _filteredOwners = [];
  bool _isLoading = false;
  String? _error;

  // Search query
  String _searchQuery = '';

  // Detail state
  Owner? _currentOwner;
  bool _isLoadingDetails = false;
  String? _errorDetails;

  // Lazy loading state
  bool _isLoaded = false;

  // Pagination state
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<Owner> get owners => _filteredOwners;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  Owner? get currentOwner => _currentOwner;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorDetails => _errorDetails;

  // Pagination getters
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadOwners({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      // Reset pagination
      _currentPage = 0;
      _hasMore = true;
      _owners = [];
      _filteredOwners = [];
      notifyListeners();
    }

    try {
      final owners = await _ownerService.getAllOwners(skip: 0, limit: 50);
      _owners = owners;
      _filteredOwners = owners;
      _isLoaded = true;
      _currentPage = 1;

      if (owners.length < 50) {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreOwners() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final skip = _currentPage * 50;
      final newOwners = await _ownerService.getAllOwners(skip: skip, limit: 50);

      if (newOwners.isEmpty || newOwners.length < 50) {
        _hasMore = false;
      }

      _owners.addAll(newOwners);
      _filteredOwners = List.from(_owners);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadOwnerById(String id) async {
    // If we're already showing this owner, don't clear it to prevent UI flicker
    if (_currentOwner?.id != id) {
      _currentOwner = null;
    }

    _isLoadingDetails = true;
    _errorDetails = null;
    notifyListeners();

    try {
      final detailedOwner = await _ownerService.getOwnerById(id);
      _currentOwner = detailedOwner;
    } catch (e) {
      _errorDetails = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;

    // If search is empty, reload all owners
    if (_searchQuery.isEmpty) {
      await loadOwners();
      return;
    }

    // Server-side search - queries entire database
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final owners = await _ownerService.getAllOwners(
        skip: 0,
        limit: 50,
        search: _searchQuery,
      );
      _owners = owners;
      _filteredOwners = owners;
      _isLoaded = true;

      // Reset pagination for search results
      _currentPage = 1;
      _hasMore = owners.length >= 50;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
