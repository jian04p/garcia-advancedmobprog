import 'package:flutter_test/flutter_test.dart';
import 'package:garcia_advmobprog/models/cart.dart';
import 'package:garcia_advmobprog/models/product.dart';
import 'package:garcia_advmobprog/models/user.dart';
import 'package:garcia_advmobprog/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('Cart parses the DummyJSON cart shape', () {
    final cart = Cart.fromJson({
      'id': 19,
      'userId': 5,
      'total': 2492,
      'discountedTotal': 2140,
      'totalProducts': 1,
      'totalQuantity': 4,
      'products': [
        {
          'id': 144,
          'title': 'Cricket Helmet',
          'price': 44.99,
          'quantity': 4,
          'total': 179.96,
          'discountPercentage': 11.47,
          'discountedTotal': 159.32,
          'thumbnail': 'https://example.com/helmet.png',
        },
      ],
    });

    expect(cart.userId, 5);
    expect(cart.products.single.id, 144);
    expect(cart.products.single.quantity, 4);
    expect(cart.toJson()['userId'], 5);
    expect(cart.toJson()['products'], isA<List<dynamic>>());
  });

  test('User stores the authentication response shape', () {
    final user = User.fromJson({
      'id': 1,
      'username': 'emilys',
      'email': 'emily.johnson@x.dummyjson.com',
      'firstName': 'Emily',
      'lastName': 'Johnson',
      'gender': 'female',
      'image': 'https://example.com/emily.png',
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
    });

    expect(user.fullName, 'Emily Johnson');
    expect(user.id, 1);
    expect(user.toJson()['accessToken'], 'access-token');
  });

  test('UserService restores and clears a saved session', () async {
    SharedPreferences.setMockInitialValues({});
    final service = UserService();
    const user = User(
      id: 1,
      username: 'emilys',
      email: 'emily.johnson@x.dummyjson.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: 'https://example.com/emily.png',
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );

    await service.saveUserData(user);
    expect(await service.isLoggedIn(), isTrue);
    expect((await service.getSavedUser())?.id, 1);

    await service.logout();
    expect(await service.getSavedUser(), isNull);
  });
}
