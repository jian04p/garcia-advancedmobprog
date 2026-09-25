import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: 'assets/.env');
  runApp(const GarciaAdvMobProg());
}

class GarciaAdvMobProg extends StatelessWidget {
  const GarciaAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        builder: (context, child) {
          final themeProvider = context.watch<ThemeProvider>();
          return MaterialApp(
            title: 'E-Commerce App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/signin':
                  return MaterialPageRoute<void>(
                    builder: (_) => const SignInScreen(),
                  );
                case '/home':
                  final user = settings.arguments as User?;
                  if (user == null) {
                    return MaterialPageRoute<void>(
                      builder: (_) => const SignInScreen(),
                    );
                  }
                  return MaterialPageRoute<void>(
                    builder: (_) => HomeScreen(user: user),
                  );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
