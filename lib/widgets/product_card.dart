import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:prolist/models/products.dart';
import 'package:provider/provider.dart';
import '../models/products.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product_provider.dart'; // For toggling favorite directly

class ProductCard extends StatelessWidget {
  final ProductModel productModel;

  const ProductCard({Key? key, required this.productModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(productId: productModel.id),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Hero(
                    tag:
                        'product_image_${productModel.id}', // Unique tag for Hero animation
                    child: CachedNetworkImage(
                      imageUrl: productModel.image,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, color: Colors.red[300]),
                      fit: BoxFit.contain, // Use contain to see the whole image
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    productModel.title,
                    style: textTheme.titleLarge?.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${productModel.price.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${productModel.rating.rate} (${productModel.rating.count})',
                            style: textTheme.bodySmall?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      // Use a Consumer for the favorite icon to rebuild only this part
                      Consumer<ProductProvider>(
                        builder: (context, provider, child) {
                          // Find the product in the provider's list to get the most up-to-date favorite status
                          final currentProduct = provider.products.firstWhere(
                            (p) => p.id == productModel.id,
                            orElse: () =>
                                productModel, // Fallback to the passed product
                          );
                          return IconButton(
                            icon: Icon(
                              currentProduct.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: currentProduct.isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              // Toggle favorite status using ProductProvider
                              productProvider.toggleProductFavoriteStatus(
                                productModel,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
