import 'package:flutter_dotenv/flutter_dotenv.dart';

final String host = dotenv.env['HOST'] ?? 'https://dummyjson.com';

// Lab Activity 3: the cart screen deliberately renders one DummyJSON user.
const int cartUserId = 5;
