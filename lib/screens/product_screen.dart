import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_details_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final Future<List<Product>> _productsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Unable to load products.\n${snapshot.error}'),
            ),
          );
        }

        final products = snapshot.data ?? const <Product>[];
        final filteredProducts = products.where((product) {
          final query = _query.toLowerCase();
          return product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            // Enhancement 1: This search field filters the product list.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Search products or categories',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: .62,
                          ),
                      itemBuilder: (context, index) => ProductCard(
                        product: filteredProducts[index],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Enhancement 2: Tapping a card opens a dedicated product details page.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ProductImage(url: product.thumbnail),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.title,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    text: '\$${product.price.toStringAsFixed(2)}',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 17),
                      const SizedBox(width: 3),
                      Text(product.rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFE9E9E9),
        child: Center(child: Icon(Icons.image_not_supported_outlined)),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFFE9E9E9),
        child: Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}
