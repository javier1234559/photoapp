import 'package:flutter/material.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/permission.dart';

class GalleryViewModel extends ChangeNotifier {
  late final MediaRepository mediaRepository;

  List<Media> medias = [];
  List<Media> get mediaList => medias;

  GalleryViewModel() {
    LoggingUtil.logInfor('Initializing GalleryViewModel...');
    mediaRepository = AssetMediaRepository();
  }

  Future<List<Media>> loadRecentMedia({offset = 0, limit = 100}) async {
    await PermissionHandler.requestPermissions();
    medias = await mediaRepository.getAllMedia(offset, limit);
    LoggingUtil.logInfor('Media loaded: ${medias.length} items');
    return medias;
  }

  Future<void> refreshMedia() async {
    await loadRecentMedia();
    notifyListeners();
  }
}
