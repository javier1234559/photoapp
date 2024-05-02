import 'package:flutter/material.dart';
import 'package:photoapp/utils/share_preferences.dart';

class InitViewModel extends ChangeNotifier {
  int _crossAxisCount = 4;
  final double _crossAxisSpacing = 5.0;
  final double _mainAxisSpacing = 5.0;

  int get crossAxisCount => _crossAxisCount;
  double get crossAxisSpacing => _crossAxisSpacing;
  double get mainAxisSpacing => _mainAxisSpacing;

  set crossAxisCount(int value) {
    _crossAxisCount = value;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _saveThemeMode(isDark);
  }

  InitViewModel() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    bool isDark = await SharedPreferencesUtil.loadThemeMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveThemeMode(bool isDark) async {
    await SharedPreferencesUtil.saveThemeMode(isDark);
  }
}
