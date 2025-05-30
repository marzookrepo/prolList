import 'package:flutter/material.dart';
import '../models/products.dart';
import '../services/api_service.dart';
import 'favorite_provider.dart'; // To update isFavorite status

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FavoritesProvider _favoritesProvider; // Dependency

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchTerm = '';

  List<ProductModel> get products =>
      _filteredProducts; // Show filtered products
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchTerm => _searchTerm;

  // Constructor to accept FavoritesProvider
  ProductProvider(this._favoritesProvider) {
    fetchProducts();
  }

  // Fetch products from API
  Future<void> fetchProducts({bool refresh = false}) async {
    if (_products.isNotEmpty && !refresh) {
      // If products are already loaded and not a refresh, apply existing filter
      _applySearchFilter();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await _apiService.fetchProducts();
      // Sync favorite status from FavoritesProvider
      _syncFavoriteStatus();
      _applySearchFilter(); // Apply initial filter (empty search term)
    } catch (e) {
      _errorMessage = e.toString();
      print("Error in ProductProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sync favorite status with the FavoritesProvider
  void _syncFavoriteStatus() {
    for (var product in _products) {
      product.isFavorite = _favoritesProvider.isFavorite(product);
    }
  }

  // Update favorite status for a single product (called by UI)
  void toggleProductFavoriteStatus(ProductModel product) {
    _favoritesProvider.toggleFavoriteStatus(product);
    // Update the local product's favorite status to reflect change immediately
    final productInList = _products.firstWhere(
      (p) => p.id == product.id,
      orElse: () => product,
    );
    productInList.isFavorite = _favoritesProvider.isFavorite(product);

    // Re-apply filter to ensure UI updates correctly if filtered list is affected
    _applySearchFilter();
    notifyListeners();
  }

  // Search functionality
  void searchProducts(String query) {
    _searchTerm = query;
    _applySearchFilter();
  }

  void _applySearchFilter() {
    if (_searchTerm.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where(
            (product) =>
                product.title.toLowerCase().contains(_searchTerm.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  // Pull to refresh
  Future<void> refreshProducts() async {
    await fetchProducts(refresh: true);
  }

  // Helper to find a product by ID
  ProductModel? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null; // Product not found
    }
  }
}
