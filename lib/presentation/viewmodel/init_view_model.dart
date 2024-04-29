import 'package:flutter/material.dart';

class InitViewModel extends ChangeNotifier {
  int _crossAxisCount = 4;
  double _crossAxisSpacing = 5.0;
  double _mainAxisSpacing = 5.0;

  int get crossAxisCount => _crossAxisCount;
  double get crossAxisSpacing => _crossAxisSpacing;
  double get mainAxisSpacing => _mainAxisSpacing;

  set crossAxisCount(int value) {
    _crossAxisCount = value;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  InitViewModel() {
    // Initialization code here...
  }
}
