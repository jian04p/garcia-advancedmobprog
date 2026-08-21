import 'package:flutter/material.dart';

import '../models/product.dart';
import 'product_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ProductImage(
                url: product.images.isNotEmpty ? product.images.first : product.thumbnail,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber),
              const SizedBox(width: 4),
              Text('${product.rating.toStringAsFixed(1)} rating'),
              const Spacer(),
              Text('${product.stock} in stock'),
            ],
          ),
          const SizedBox(height: 20),
          Text(product.category.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(product.description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
