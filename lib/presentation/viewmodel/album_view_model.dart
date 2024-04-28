import 'package:flutter/material.dart';
import 'package:photoapp/data/dao/album_dao.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/db_helper.dart';
import 'package:photoapp/domain/album_repository.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/permission.dart';

class AlbumViewModel extends ChangeNotifier {
  late final AlbumRepository albumRepository;
  Map<String, Album> albumMap = {};
  List<Album> _albums = [];

  List<Album> get albums => _albums;

  set albums(List<Album> value) {
    _albums = value;
    notifyListeners();
  }

  AlbumViewModel() {
    LoggingUtil.logInfor('Initializing AlbumViewModel...');
    _initialize();
  }

  void _initialize() async {
    final appDatabase = await DBHelper.getInstance();
    AlbumDao albumDao = appDatabase.albumDao;
    MediaDao mediaDao = appDatabase.mediaDao;
    TagDao tagDao = appDatabase.tagDao;
    albumRepository = AlbumLocalRepository(
        albumDao: albumDao, mediaDao: mediaDao, tagDao: tagDao);
    // Load default albums
    albumMap = await albumRepository.persistAlbumDefault();
    albumMap.entries.forEach((element) {
      LoggingUtil.logInfor('Album: ${element.value}');
    });
    await loadAlbums();
  }

  Future<List<Album>> loadAlbums({offset = 0, limit = 20}) async {
    await PermissionHandler.requestPermissions();
    albums = await albumRepository.getAlbumPaginated(offset, limit);
    LoggingUtil.logInfor('Album loaded: ${albums.length} items');
    return albums;
  }

  Future<void> refreshAlbum() async {
    albumMap = await albumRepository.persistAlbumDefault();
    await loadAlbums();
    notifyListeners();
  }
}
