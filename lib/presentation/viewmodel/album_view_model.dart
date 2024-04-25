import 'package:flutter/material.dart';
import 'package:photoapp/data/dao/album_dao.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/db_helper.dart';
import 'package:photoapp/domain/album_repository.dart';
import 'package:photoapp/domain/model/album.dart';

class AlbumViewModel extends ChangeNotifier {
  late final AlbumRepository albumRepository;

  List<Album> _albums = [];
  List<Album> get albums => _albums;

  AlbumViewModel() {
    _initialize();
  }

  void _initialize() async {
    final appDatabase = await DBHelper.getInstance();
    AlbumDao albumDao = appDatabase.albumDao;
    MediaDao mediaDao = appDatabase.mediaDao;
    TagDao tagDao = appDatabase.tagDao;
    albumRepository = AlbumLocalRepository(albumDao: albumDao, mediaDao: mediaDao, tagDao: tagDao);
    // Load albums
    await loadAlbums();
  }

  Future<void> loadAlbums() async {
    // Fetch albums from repository
    _albums = await albumRepository.getAlbumPaginated(1, 100);
    notifyListeners();
  }

  // // Add album to the list
  // Future<void> addAlbum(Album album) async {
  //   // Add album to the repository
  //   await albumRepository.addAlbum(album);

  //   // Update the local list of albums
  //   _albums.add(album);
  //   notifyListeners();
  // }

  // // Remove album from the list
  // Future<void> removeAlbum(Album album) async {
  //   // Remove album from the repository
  //   await albumRepository.removeAlbum(album.id);

  //   // Update the local list of albums
  //   _albums.remove(album);
  //   notifyListeners();
  // }
}
