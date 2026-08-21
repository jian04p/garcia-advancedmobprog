import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    useMaterial3: true,
  );

  ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  void toggleTheme(bool value) {
    _isDark = value;
    notifyListeners();
  }
}
