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
  final Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    _cartFuture = CartService().getByUserId(cartUserId);
  }

  Future<void> _reload() async {
    setState(() {
      _quantities.clear();
      _loadCart();
    });
    await _cartFuture;
  }

  int _quantityFor(CartProduct product) =>
      _quantities[product.id] ?? product.quantity;

  void _changeQuantity(CartProduct product, int change) {
    final nextQuantity = _quantityFor(product) + change;
    if (nextQuantity < 0) return;
    setState(() => _quantities[product.id] = nextQuantity);
  }

  void _confirmOrder(List<CartProduct> products) {
    final itemCount = products.fold<int>(
      0,
      (total, product) => total + _quantityFor(product),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          itemCount == 0
              ? 'Add an item before confirming the order.'
              : 'Order confirmed for $itemCount item(s).',
        ),
      ),
    );
  }

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

        final products = cart.products
            .where((product) => _quantityFor(product) > 0)
            .toList();
        final subtotal = products.fold<double>(
          0,
          (total, product) => total + (product.price * _quantityFor(product)),
        );
        final discountedTotal = products.fold<double>(
          0,
          (total, product) =>
              total + _discountedTotalFor(product, _quantityFor(product)),
        );

        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    children: [
                      Text(
                        'User ${cart.userId} cart',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      if (products.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('This cart is empty.')),
                        )
                      else
                        ...products.map(
                          (product) => _CartProductTile(
                            product: product,
                            quantity: _quantityFor(product),
                            onAdd: () => _changeQuantity(product, 1),
                            onRemove: () => _changeQuantity(product, -1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Lab Activity 3 Enhancement 3: live totals respond to +/- controls.
              _CartSummary(
                subtotal: subtotal,
                discountedTotal: discountedTotal,
                onConfirm: () => _confirmOrder(products),
              ),
            ],
          ),
        );
      },
    );
  }

  double _discountedTotalFor(CartProduct product, int quantity) {
    if (product.quantity == 0) return product.total;
    return product.discountedTotal * quantity / product.quantity;
  }
}

class _CartProductTile extends StatelessWidget {
  const _CartProductTile({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final CartProduct product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final itemTotal = product.price * quantity;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Lab Activity 3 Enhancement 1: reuse the existing product details screen.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: product.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(url: product.thumbnail),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$quantity x \$${product.price.toStringAsFixed(2)} = '
                      '\$${itemTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuantityButton(icon: Icons.add, onPressed: onAdd),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text('$quantity'),
                  ),
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: onRemove,
                    muted: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    this.muted = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton.filled(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: muted
              ? colorScheme.surfaceContainerHighest
              : colorScheme.tertiaryContainer,
          foregroundColor: muted
              ? colorScheme.onSurfaceVariant
              : colorScheme.onTertiaryContainer,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.subtotal,
    required this.discountedTotal,
    required this.onConfirm,
  });

  final double subtotal;
  final double discountedTotal;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TotalRow(label: 'Subtotal', value: subtotal),
              const SizedBox(height: 6),
              _TotalRow(
                label: 'Discounted total',
                value: discountedTotal,
                emphasized: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onConfirm,
                  child: const Text('Confirm Order'),
                ),
              ),
            ],
          ),
        ),
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
