import 'package:flutter_test/flutter_test.dart';
import 'package:garcia_advmobprog/models/product.dart';

void main() {
  test('Product parses a DummyJSON response', () {
    final product = Product.fromJson({
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description': 'A sample product.',
      'category': 'beauty',
      'price': 9.99,
      'rating': 4.69,
      'stock': 5,
      'thumbnail': 'https://example.com/product.png',
      'images': ['https://example.com/product.png'],
    });

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.price, 9.99);
    expect(product.images, hasLength(1));
  });
}
