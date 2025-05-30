import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/products.dart';
import '../utils/constants.dart';

class ApiService {
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}'),
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON.
        List<dynamic> body = jsonDecode(response.body);
        List<ProductModel> products = body
            .map((dynamic item) => ProductModel.fromJson(item))
            .toList();
        return products;
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception(
          'Failed to load products (Status code: ${response.statusCode})',
        );
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
}
