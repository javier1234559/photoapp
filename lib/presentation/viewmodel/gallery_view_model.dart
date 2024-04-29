import 'package:flutter/material.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/permission.dart';

class GalleryViewModel extends ChangeNotifier {
  late final MediaRepository mediaRepository;
  List<Media> _selectedMedias = [];
  List<Media> _medias = [];

  List<Media> get selectedMedias => _selectedMedias;

  set selectedMedias(List<Media> value) {
    _selectedMedias = value;
    notifyListeners();
  }

  List<Media> get medias => _medias;

  set medias(List<Media> value) {
    _medias = value;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  GalleryViewModel() {
    LoggingUtil.logInfor('Initializing GalleryViewModel...');
    mediaRepository = AssetMediaRepository();
    loadRecentMedia();
    notifyListeners();
  }

  Future<List<Media>> loadRecentMedia({offset = 0, limit = 200}) async {
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
