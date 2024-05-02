import 'package:flutter/material.dart';
import 'package:photoapp/data/dao/album_dao.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/db_helper.dart';
import 'package:photoapp/domain/album_repository.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/permission.dart';
import 'package:photoapp/utils/share_preferences.dart';

class AlbumViewModel extends ChangeNotifier {
  late final AlbumRepository albumRepository;
  Map<String, Album> albumMap = {};
  late Album _favoriteAlbum;
  late Album _recycleBinAlbum;

  Album get favoriteAlbum => _favoriteAlbum;

  set favoriteAlbum(Album value) {
    _favoriteAlbum = value;
    notifyListeners();
  }

  Album get recycleBinAlbum => _recycleBinAlbum;

  set recycleBinAlbum(Album value) {
    _recycleBinAlbum = value;
    notifyListeners();
  }

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

    checkAndLoadDefault();
  }

  void checkAndLoadDefault() async {
    bool isAlreadyLoad = await SharedPreferencesUtil.loadIsSetUpDefaultAlbum();
    if (!isAlreadyLoad) {
      albumMap = await albumRepository.persistAlbumDefault();
      await SharedPreferencesUtil.saveIsSetUpDefaultAlbum(true);
    }

    await loadAlbums();
    notifyListeners();
  }

  Future<List<Album>> loadAlbums({offset = 0, limit = 20}) async {
    await PermissionHandler.requestPermissions();
    albums = await albumRepository.getAlbumPaginated(offset, limit);
    LoggingUtil.logInfor('Album loaded: ${albums.length} items');
    return albums;
  }

  Future<void> refreshAlbum() async {
    await albumRepository.persistAlbumDefault();
    await loadAlbums();
    notifyListeners();
  }

  Future<void> addToAlbum(String title, List<Media> listItemMoveToAlbum) async {
    for (Media media in listItemMoveToAlbum) {
      await albumRepository.addMediaToAlbum(title, media);
    }
    await loadAlbums();
  }

  Future<void> loadFavoriteAlbum() async {
    Album? album = await albumRepository.getAlbumByName("Favorite");
    album ??= await albumRepository.createFavoriteAlbum();
    favoriteAlbum = album;
  }

  Future<void> loadRecycleBinAlbum() async {
    Album? album = await albumRepository.getAlbumByName("Recycle Bin");
    album ??= await albumRepository.createRecycleBinAlbum();
    recycleBinAlbum = album;
  }
}
