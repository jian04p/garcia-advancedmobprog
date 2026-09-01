class Cart {
  const Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: (json['id'] as num? ?? 0).toInt(),
      products: (json['products'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CartProduct.fromJson)
          .toList(),
      total: (json['total'] as num? ?? 0).toDouble(),
      discountedTotal: (json['discountedTotal'] as num? ?? 0).toDouble(),
      userId: (json['userId'] as num? ?? 0).toInt(),
      totalProducts: (json['totalProducts'] as num? ?? 0).toInt(),
      totalQuantity: (json['totalQuantity'] as num? ?? 0).toInt(),
    );
  }
}

class CartProduct {
  const CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: (json['id'] as num? ?? 0).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      total: (json['total'] as num? ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] as num? ?? 0).toDouble(),
      discountedTotal:
          ((json['discountedTotal'] ?? json['discountedPrice']) as num? ?? 0)
              .toDouble(),
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }
}
