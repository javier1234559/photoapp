import 'package:flutter/material.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/utils/logger.dart';

class GalleryAlbumViewModel extends ChangeNotifier {
  late final MediaRepository mediaRepository;
  late Album album;

  Album get currentAlbum => album;

  set currentAlbum(Album album) {
    this.album = album;
    notifyListeners();
  }

  GalleryAlbumViewModel() {
    LoggingUtil.logInfor('Initializing GalleryAlbumViewModel ...');
  }
}
