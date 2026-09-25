import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  /// Replicates the handout's base cart endpoint for callers that need all carts.
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(Uri.parse('$host/carts'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load carts (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final carts = data['carts'] as List<dynamic>? ?? const [];
    return carts.whereType<Map<String, dynamic>>().map(Cart.fromJson).toList();
  }

  /// Lab Activity 3 enhancement: renders one cart returned for a user ID.
  Future<Cart?> getByUserId(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cart (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final carts = data['carts'] as List<dynamic>? ?? const [];
    if (carts.isEmpty || carts.first is! Map<String, dynamic>) return null;
    return Cart.fromJson(carts.first as Map<String, dynamic>);
  }

  /// Supports DummyJSON's get-by-id cart endpoint when a cart id is available.
  Future<Cart> getById(int cartId) async {
    final response = await http.get(Uri.parse('$host/carts/$cartId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cart (${response.statusCode}).');
    }
    return Cart.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lab Activity 3 enhancement: posts a product and quantity to the cart API.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$host/carts/add'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add cart item (${response.statusCode}).');
    }
    return Cart.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
