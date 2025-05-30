import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/products.dart';

class FavoritesProvider with ChangeNotifier {
  List<ProductModel> _favoriteProducts = [];
  static const String _favoritesKey = 'favoriteProducts';

  List<ProductModel> get favoriteProducts => _favoriteProducts;

  FavoritesProvider() {
    _loadFavorites(); // Load favorites when the provider is initialized
  }

  // Toggles the favorite status of a product
  void toggleFavoriteStatus(ProductModel productmodel) {
    final isCurrentlyFavorite = _favoriteProducts.any(
      (favProduct) => favProduct.id == productmodel.id,
    );

    if (isCurrentlyFavorite) {
      _favoriteProducts.removeWhere(
        (favProduct) => favProduct.id == productmodel.id,
      );
      productmodel.isFavorite = false;
    } else {
      productmodel.isFavorite = true;
      _favoriteProducts.add(productmodel);
    }
    _saveFavorites(); // Save after modification
    notifyListeners(); // Notify listeners to update UI
  }

  // Checks if a product is a favorite
  bool isFavorite(ProductModel product) {
    return _favoriteProducts.any((favProduct) => favProduct.id == product.id);
  }

  // Persist favorites to SharedPreferences (Bonus)
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteProductsJson = _favoriteProducts
        .map((p) => jsonEncode(p.toJson()))
        .toList();
    await prefs.setStringList(_favoritesKey, favoriteProductsJson);
  }

  // Load favorites from SharedPreferences (Bonus)
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteProductsJson = prefs.getStringList(_favoritesKey);
    if (favoriteProductsJson != null) {
      _favoriteProducts = favoriteProductsJson.map((jsonString) {
        final productMap = jsonDecode(jsonString) as Map<String, dynamic>;
        // Ensure isFavorite is correctly set from stored data
        ProductModel p = ProductModel.fromJson(productMap);
        p.isFavorite =
            productMap['isFavorite'] ??
            true; // Default to true if missing, as it was saved as favorite
        return p;
      }).toList();
    }
    notifyListeners(); // Update UI after loading
  }
}
