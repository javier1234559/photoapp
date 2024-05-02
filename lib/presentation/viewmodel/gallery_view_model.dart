import 'package:flutter/material.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/db_helper.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/permission.dart';

class GalleryViewModel extends ChangeNotifier {
  late final MediaRepository mediaAssetRepository;
  late final MediaLocalRepository mediaLocalRepository;
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
    mediaAssetRepository = AssetMediaRepository();
    _initialDatabase();
    loadRecentMedia();
    notifyListeners();
  }

  _initialDatabase() async {
    final appDatabase = await DBHelper.getInstance();
    MediaDao mediaDao = appDatabase.mediaDao;
    TagDao tagDao = appDatabase.tagDao;
    mediaLocalRepository =
        MediaLocalRepository(mediaDao: mediaDao, tagDao: tagDao);
  }

  Future<List<Media>> loadRecentMedia({offset = 0, limit = 200}) async {
    await PermissionHandler.requestPermissions();
    List<Media> assetMedias =
        await mediaAssetRepository.getAllMedia(offset, limit);
    LoggingUtil.logInfor('Media loaded: ${medias.length} items');
    medias = await filterMediaInRecycleBin(assetMedias);
    return medias;
  }

  Future<List<Media>> filterMediaInRecycleBin(List<Media> assetMedias) async {
    List<Media> medias = await mediaLocalRepository.getAllMedia(0, 200);
    medias = medias.where((element) => element.isDelete == false).toList();

    if (medias.isEmpty) { //if there is no media in databasse
      return assetMedias;
    }

    return assetMedias
        .where((element) => medias.any((media) => media.id == element.id))
        .toList();
  }

  Future<void> refreshMedia() async {
    await loadRecentMedia();
  }
}
