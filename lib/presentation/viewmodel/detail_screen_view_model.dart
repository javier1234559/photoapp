import 'package:flutter/material.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/db_helper.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/logger.dart';

class DetailScreenViewModel extends ChangeNotifier {
  Media _currentMedia;
  late final MediaLocalRepository mediaRepository;
  bool get isFavorite => currentMedia.isFavorite;

  Media get currentMedia => _currentMedia;

  set currentMedia(Media media) {
    _currentMedia = media;
    notifyListeners(); // Notify listeners of the change
  }

  DetailScreenViewModel(this._currentMedia) {
    LoggingUtil.logDebug("DetailScreenViewModel created: $currentMedia.path");
    _initialDatabase();
  }

  _initialDatabase() async {
    final appDatabase = await DBHelper.getInstance();
    MediaDao mediaDao = appDatabase.mediaDao;
    TagDao tagDao = appDatabase.tagDao;
    mediaRepository = MediaLocalRepository(mediaDao: mediaDao, tagDao: tagDao);
  }

  void checkExistMediaAndCreate() async {
    try {
      Media? media = await mediaRepository.getMediaById(currentMedia.id);
      if (media != null) {
        return;
      }
      await mediaRepository.createMedia(currentMedia);
      LoggingUtil.logInfor('Create media with id: ${currentMedia.id}');
    } catch (e) {
      LoggingUtil.logError("Failed to create media: $e");
    }
  }

  Future<void> toggleFavorite() async {
    checkExistMediaAndCreate();
    currentMedia.isFavorite = !currentMedia.isFavorite;
    LoggingUtil.logDebug(
        "Favorite status changed to ${currentMedia.isFavorite}");
    await mediaRepository.updateMedia(currentMedia);
    notifyListeners();
  }
}
