import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/products.dart';
import '../providers/product_provider.dart';
import 'product_card.dart'; // Re-use ProductCard for displaying search results

class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.white, // Search bar background
        iconTheme: IconThemeData(color: Colors.grey[700]), // Back button color
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: InputBorder.none, // Remove underline from search field
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: theme.primaryColor, // Cursor color
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search products...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Actions for the app bar (e.g., clear query button)
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context); // Refresh suggestions
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Leading icon on the left of the app bar (e.g., back button)
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Pass empty string or null if search is cancelled
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Show when user submits the search query (e.g., presses enter)
    // We are doing real-time search, so suggestions will cover this.
    // For a non-realtime search, you'd implement result display here.
    // For now, just rebuild suggestions.
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.searchProducts(query); // Trigger search
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show when the user types in the search field (real-time filtering)
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    // Debounce or throttle could be added here for performance on very large lists
    productProvider.searchProducts(query);
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.products.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage.isNotEmpty && provider.products.isEmpty) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }
        if (provider.products.isEmpty && query.isNotEmpty) {
          return Center(child: Text('No products found for "$query"'));
        }
        if (provider.products.isEmpty && query.isEmpty) {
          // This case might occur if initial load failed or if search cleared and list is empty
          return Center(child: Text('No products available.'));
        }

        // Use GridView for better layout
        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            childAspectRatio: 0.65, // Adjust for card height
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return ProductCard(productModel: product);
          },
        );
      },
    );
  }
}
