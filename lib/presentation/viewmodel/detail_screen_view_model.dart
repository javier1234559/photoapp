import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/db_helper.dart';
import 'package:photoapp/domain/album_repository.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/domain/model/tag.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:video_player/video_player.dart';

class DetailScreenViewModel extends ChangeNotifier {
  Media _currentMedia;
  VideoPlayerController? _controller;
  late final MediaLocalRepository mediaRepository;
  late final AlbumRepository albumRepository;

  bool get isFavorite => currentMedia.isFavorite;

  Media get currentMedia => _currentMedia;

  set currentMedia(Media media) {
    if (_currentMedia != media) {
      _currentMedia = media;
      if (currentMedia.type == 'video') {
        initVideoPlayer(media);
        LoggingUtil.logDebug("Setter set video at : ${currentMedia.path}");
      }
      notifyListeners();
    }
  }

  VideoPlayerController? get controller => _controller;

  DetailScreenViewModel(this._currentMedia) {
    LoggingUtil.logDebug("DetailScreenViewModel created: $currentMedia.path");
    _initialDatabase();

    if (currentMedia.type == 'video') {
      initVideoPlayer(currentMedia);
      LoggingUtil.logDebug("Video player initialized: ${currentMedia.path}");
    }
  }

  Future<void> initVideoPlayer(Media media) async {
    try {
      LoggingUtil.logError("Initializing video player: ${currentMedia.path}");
      await _controller?.dispose();
      _controller = VideoPlayerController.file(File(currentMedia.path));
      await _controller?.initialize();
      notifyListeners();
    } catch (error) {
      LoggingUtil.logError(
          'Error occurred while initializing video player: $error');
    }
  }

  void playVideo() {
    _controller?.play();
    notifyListeners();
  }

  void pauseVideo() {
    _controller?.pause();
    notifyListeners();
  }

  _initialDatabase() async {
    final appDatabase = await DBHelper.getInstance();
    MediaDao mediaDao = appDatabase.mediaDao;
    TagDao tagDao = appDatabase.tagDao;
    mediaRepository = MediaLocalRepository(mediaDao: mediaDao, tagDao: tagDao);
    albumRepository = AlbumLocalRepository(
        albumDao: appDatabase.albumDao, mediaDao: mediaDao, tagDao: tagDao);
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

    // add to favorite list
    if (currentMedia.isFavorite) {
      albumRepository.addMediaToAlbum('Favorite', currentMedia);
      LoggingUtil.logDebug("Add to favorite list: ${currentMedia.path}");
    } else {
      albumRepository.removeMediaFromAlbum('Favorite', currentMedia);
      LoggingUtil.logDebug("Remove from favorite list: ${currentMedia.path}");
    }

    notifyListeners();
  }

  Future<void> creatNewHashTag(Tag tag) async {
    currentMedia.tags.add(tag);
    await mediaRepository.updateMedia(currentMedia);
    notifyListeners();
  }

  @override
  void dispose() {
    LoggingUtil.logError(
        "DetailScreenViewModel disposed: ${currentMedia.path}");
    _controller?.dispose();
    super.dispose();
  }
}
