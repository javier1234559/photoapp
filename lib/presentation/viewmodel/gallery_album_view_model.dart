import 'package:flutter/material.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/logger.dart';

class GalleryAlbumViewModel extends ChangeNotifier {
  late final MediaRepository mediaRepository;
  late Album album;

  Album get currentAlbum => album;

  set currentAlbum(Album album) {
    this.album = album;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void refreshAfterRestored(Media media) {
    //filter the restored media
    album.medias.removeWhere((element) => element.id == media.id);
    notifyListeners();
  }

  GalleryAlbumViewModel() {
    LoggingUtil.logInfor('Initializing GalleryAlbumViewModel ...');
  }
}
