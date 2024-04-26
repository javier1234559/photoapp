import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/data/dao/album_dao.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/db_helper.dart';
import 'package:photoapp/data/entity/album_entity.dart';
import 'package:photoapp/domain/album_repository.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/permission.dart';

class AlbumViewModel extends ChangeNotifier {
  late final AlbumRepository albumRepository;
  late final MediaRepository mediaRepository;

  List<Album> albums = [];
  List<Album> get albumsList => albums;

  AlbumViewModel() {
    _initialize();
  }

  void _initialize() async {
    final appDatabase = await DBHelper.getInstance();
    AlbumDao albumDao = appDatabase.albumDao;
    MediaDao mediaDao = appDatabase.mediaDao;
    TagDao tagDao = appDatabase.tagDao;
    albumRepository = AlbumLocalRepository(
        albumDao: albumDao, mediaDao: mediaDao, tagDao: tagDao);
    mediaRepository = MediaLocalRepository(mediaDao: mediaDao, tagDao: tagDao);
    // Load albums
    await loadAlbums();
  }

  Future<void> loadAllDefaultAlbum() async {
    final List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);

    // Filter the albums to only include the "Download" and "Camera" folders

    final List<AssetPathEntity> defaultAlbums = albums.where((album) {
      print(album.name);
      return album.name == 'Download' || album.name == 'Camera';
    }).toList();

    for (var album in defaultAlbums) {
      final List<AssetEntity> media =await album.getAssetListRange(start: 0, end: 100);
      //save media to database 
      for (var mediaItem in media) {
        await mediaRepository.saveMedia(mediaItem);
      }


      AlbumEntity newAlbum = AlbumEntity(
        id: int.parse(album.id),
        title: album.name,
      );
    }
  }

  Future<void> checkExistAlbumAndCreate(String name) async {
    try {
      Album? album = await albumRepository.getAlbumByName(name);
      if (album != null) {
        return;
      }
      await albumRepository(currentalbum);
      LoggingUtil.logInfor('Create album with id: ${currentalbum.id}');
    } catch (e) {
      LoggingUtil.logError("Failed to create album: $e");
    }
  }

  Future<List<Album>> loadAlbums({offset = 0, limit = 20}) async {
    await PermissionHandler.requestPermissions();
    albums = await albumRepository.getAlbumPaginated(offset, limit);
    LoggingUtil.logInfor('Album loaded: ${albums.length} items');
    return albums;
  }

  Future<void> refreshAlbum() async {
    await loadAlbums();
    notifyListeners();
  }
}
