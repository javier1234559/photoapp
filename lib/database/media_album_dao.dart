import 'package:floor/floor.dart';
import 'package:photoapp/models/media.dart';
import 'package:photoapp/models/album.dart';
import 'package:photoapp/models/media_album.dart';

@dao
abstract class MediaAlbumDao {
  @Query(
      'SELECT * FROM media_album WHERE albumId = (SELECT id FROM album WHERE title = :albumTitle) AND imageId = :mediaId')
  Future<MediaAlbum?> findExistMediaFromAlbum(String albumTitle, int mediaId);

  @delete
  Future<void> deleteMediaFromAlbum(MediaAlbum mediaAlbum);

  @insert
  Future<void> insertMediaToAlbum(MediaAlbum mediaAlbum);
}
