import 'package:floor/floor.dart';
import 'package:photoapp/database/models/album.dart';

@dao
abstract class AlbumDao {
  @Query('SELECT * FROM album')
  Future<List<Album>> findAllAlbum();

  @Query('SELECT * FROM album WHERE title = :title')
  Future<List<Album>> findAlbumByTitle(String title);

  @Query('SELECT * FROM album WHERE id = :id')
  Future<List<Album>> findAlbumById(int id);

  @insert
  Future<void> insertAlbum(Album album);

  @delete
  Future<void> deleteAlbum(Album album);
}
