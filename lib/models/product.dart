class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num? ?? 0).toInt(),
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Uncategorized',
      price: (json['price'] as num? ?? 0).toDouble(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      stock: (json['stock'] as num? ?? 0).toInt(),
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}
