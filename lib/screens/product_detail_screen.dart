import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/products.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch the specific product using the provider
    // Listen is true here because if the favorite status changes elsewhere, we want this screen to reflect it.
    final productProvider = Provider.of<ProductProvider>(context);
    final product = productProvider.getProductById(productId);
    final textTheme = Theme.of(context).textTheme;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Not Found')),
        body: const Center(
          child: Text('Sorry, this product could not be loaded.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, style: TextStyle(fontSize: 16)),
        actions: [
          // Use Consumer for the favorite icon to rebuild only this part
          // Or, since ProductProvider is already listened to, direct access is fine.
          IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: product.isFavorite
                  ? Colors.red
                  : Colors.white, // White for appbar contrast
            ),
            onPressed: () {
              productProvider.toggleProductFavoriteStatus(product);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Hero(
                tag:
                    'product_image_${product.id}', // Same tag as in ProductCard
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  height: 250,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    child: Icon(Icons.error, size: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 5),
                Text(
                  '${product.rating.rate} (${product.rating.count} ratings)',
                  style: textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Category: ${product.category}',
              style: textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Description:',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            // Example: Add to cart button (not part of requirements but common)
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // Add to cart logic
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text('${product.title} added to cart!')),
            //       );
            //     },
            //     child: Text('Add to Cart'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
