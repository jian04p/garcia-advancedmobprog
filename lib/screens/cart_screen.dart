import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import 'product_details_screen.dart';
import 'product_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Cart?> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = CartService().getByUserId(cartUserId);
  }

  void _reload() => setState(() {
    _cartFuture = CartService().getByUserId(cartUserId);
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Cart?>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unable to load cart.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        final cart = snapshot.data;
        if (cart == null || cart.products.isEmpty) {
          return const Center(child: Text('This cart is empty.'));
        }

        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Cart', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('User ${cart.userId} • ${cart.totalQuantity} item(s)'),
              const SizedBox(height: 12),
              ...cart.products.map(
                (product) => _CartProductTile(product: product),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _TotalRow(label: 'Subtotal', value: cart.total),
                      const SizedBox(height: 8),
                      _TotalRow(
                        label: 'Discounted total',
                        value: cart.discountedTotal,
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartProductTile extends StatelessWidget {
  const _CartProductTile({required this.product});

  final CartProduct product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // Lab Activity 3 Enhancement 1: reuse the existing product details screen.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: product.id),
          ),
        ),
        leading: SizedBox(
          width: 56,
          height: 56,
          child: ProductImage(url: product.thumbnail),
        ),
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${product.quantity} × \$${product.price.toStringAsFixed(2)}',
        ),
        trailing: Text('\$${product.total.toStringAsFixed(2)}'),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized ? Theme.of(context).textTheme.titleMedium : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
