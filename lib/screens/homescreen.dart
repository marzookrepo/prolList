import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart'; // Import search delegate
import 'favorite_items.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Optionally, you could add pagination logic here if the API supported it
    // _scrollController.addListener(_onScroll);

    // Initial fetch if not already done by provider constructor
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    // });
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
  //     // Fetch more products if API supports pagination
  //     // Provider.of<ProductProvider>(context, listen: false).fetchMoreProducts();
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty && provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => provider.refreshProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (provider.products.isEmpty) {
            return Center(
              child: Text(
                provider.searchTerm.isEmpty
                    ? 'No products available.'
                    : 'No products found for "${provider.searchTerm}".',
              ),
            );
          }

          // Pull-to-refresh implementation (Bonus)
          return RefreshIndicator(
            onRefresh: () => provider.refreshProducts(),
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns for a grid view
                childAspectRatio: 0.65, // Adjust this ratio for card height
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return ProductCard(productModel: product);
              },
            ),
          );
        },
      ),
    );
  }
}
