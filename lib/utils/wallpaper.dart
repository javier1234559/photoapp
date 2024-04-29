import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:photoapp/utils/logger.dart';

class WallpaperHandler {
  static Future<String> setWallPaperHomeScreen(String path) async {
    try {
      bool check = await WallpaperManager.setWallpaperFromFile(
          path, WallpaperManager.HOME_SCREEN);
      if (check) {
        LoggingUtil.logInfor("Wallpaper set successfully");
        return "Wallpaper set to Home Screen successfully";
      }
    } catch (e) {
      LoggingUtil.logError("Error setting wallpaper: $e");
      return "Error setting wallpaper: $e";
    }
    return "";
  }

  static Future<String> setWallPaperLockScreen(String path) async {
    try {
      bool check = await WallpaperManager.setWallpaperFromFile(
          path, WallpaperManager.HOME_SCREEN);
      if (check) {
        LoggingUtil.logInfor("Wallpaper set Lock Screen successfully");
        return "Wallpaper set successfully";
      }
    } catch (e) {
      LoggingUtil.logError("Error setting wallpaper: $e");
      return "Error setting wallpaper: $e";
    }
    return "";
  }

  static Future<String> setWallPaperBothScreen(String path) async {
    try {
      bool check = await WallpaperManager.setWallpaperFromFile(
          path, WallpaperManager.HOME_SCREEN);
      if (check) {
        LoggingUtil.logInfor(
            "Wallpaper set to Home Screen and Lock Screen successfully");
        return "Wallpaper set successfully";
      }
    } catch (e) {
      LoggingUtil.logError("Error setting wallpaper: $e");
      return "Error setting wallpaper: $e";
    }
    return "";
  }
}
