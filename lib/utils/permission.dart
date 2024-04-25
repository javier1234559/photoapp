import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<void> requestPermissions() async {
    final status = await Permission.photos.status;
    if (!status.isGranted) {
      await [
        Permission.photos,
        Permission.storage,
        Permission.camera,
      ].request();
    }
  }
}
