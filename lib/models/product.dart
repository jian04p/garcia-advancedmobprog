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
    required this.discountPercentage,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.dimensions,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.reviews,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.meta,
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
  final double discountPercentage;
  final String brand;
  final String sku;
  final double weight;
  final ProductDimensions dimensions;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<ProductReview> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final ProductMeta meta;

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
      discountPercentage: (json['discountPercentage'] as num? ?? 0).toDouble(),
      brand: json['brand'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      weight: (json['weight'] as num? ?? 0).toDouble(),
      dimensions: ProductDimensions.fromJson(
        json['dimensions'] as Map<String, dynamic>? ?? const {},
      ),
      warrantyInformation: json['warrantyInformation'] as String? ?? '',
      shippingInformation: json['shippingInformation'] as String? ?? '',
      availabilityStatus: json['availabilityStatus'] as String? ?? '',
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProductReview.fromJson)
          .toList(),
      returnPolicy: json['returnPolicy'] as String? ?? '',
      minimumOrderQuantity: (json['minimumOrderQuantity'] as num? ?? 0).toInt(),
      meta: ProductMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ProductDimensions {
  const ProductDimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  final double width;
  final double height;
  final double depth;

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      width: (json['width'] as num? ?? 0).toDouble(),
      height: (json['height'] as num? ?? 0).toDouble(),
      depth: (json['depth'] as num? ?? 0).toDouble(),
    );
  }
}

class ProductReview {
  const ProductReview({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  final int rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      rating: (json['rating'] as num? ?? 0).toInt(),
      comment: json['comment'] as String? ?? '',
      date: json['date'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? '',
      reviewerEmail: json['reviewerEmail'] as String? ?? '',
    );
  }
}

class ProductMeta {
  const ProductMeta({
    required this.createdAt,
    required this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });

  final String createdAt;
  final String updatedAt;
  final String barcode;
  final String qrCode;

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
    );
  }
}
