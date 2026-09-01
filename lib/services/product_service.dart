import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$host/products?limit=100'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load products (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final products = data['products'] as List<dynamic>? ?? const [];
    return products
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<Product> getById(int productId) async {
    final response = await http.get(Uri.parse('$host/products/$productId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load product (${response.statusCode}).');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
