import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static const String _keyThemeMode = 'themeMode';
  static const String _keyIsSetUpDefaultAlbum = 'isSetUpDefaultAlbum';

  static Future<bool> loadIsSetUpDefaultAlbum() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsSetUpDefaultAlbum) ?? false;
  }

  static Future<void> saveIsSetUpDefaultAlbum(bool isSetUp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsSetUpDefaultAlbum, isSetUp);
  }

  static Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeMode) ?? false;
  }

  static Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeMode, isDark);
  }
}
