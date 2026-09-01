import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import 'product_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, this.product, this.productId})
    : assert(product != null || productId != null);

  final Product? product;
  final int? productId;

  @override
  Widget build(BuildContext context) {
    if (product != null) {
      return _ProductDetailsBody(product: product!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Product>(
        future: ProductService().getById(productId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Unable to load product.\n${snapshot.error}'),
              ),
            );
          }
          return _ProductDetailsBody(product: snapshot.data!);
        },
      ),
    );
  }
}

class _ProductDetailsBody extends StatelessWidget {
  const _ProductDetailsBody({required this.product});

  final Product product;

  Future<void> _addToCart(BuildContext context) async {
    try {
      // Lab Activity 3: submit the selected product id and quantity to /carts/add.
      final cart = await CartService().addToCart(
        userId: cartUserId,
        productId: product.id,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.title} added to simulated cart #${cart.id}.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to add to cart: $error')));
    }
  }

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
                url: product.images.isNotEmpty
                    ? product.images.first
                    : product.thumbnail,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
          Text(
            product.category.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _addToCart(context),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
