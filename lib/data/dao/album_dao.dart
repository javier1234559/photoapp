import 'package:floor/floor.dart';
import 'package:photoapp/data/entity/album_entity.dart';
import 'package:photoapp/data/entity/media_entity.dart';

@dao
abstract class AlbumDao {
  @Query('''
  SELECT media.* FROM media
  INNER JOIN media_album ON media.id = media_album.mediaId
  INNER JOIN album ON media_album.albumId = album.id
  WHERE album.title = :albumName
''')
  Future<List<MediaEntity>> findAllMediaByAlbumName(String albumName);

  @Query(
      'SELECT COUNT(*) FROM album WHERE title = :albumTitle AND id IN (SELECT albumId FROM media_album)')
  Future<int?> checkAlbumEmpty(String albumTitle);

  @Query('''
  SELECT COUNT(*) FROM media_album 
  WHERE mediaId = :mediaId 
  AND albumId = (SELECT id FROM album WHERE title = :albumTitle)
''')
  Future<int?> checkExistMedia(String albumTitle, String mediaId);

  @Query('''
  INSERT INTO media_album (mediaId, albumId)
  VALUES (:mediaId, (SELECT id FROM album WHERE title = :title))
''')
  Future<void> addMediaToExistAlbum(String title, String mediaId);

  @Query('SELECT * FROM album')
  Future<List<AlbumEntity>> findAllAlbumEntity();

  @Query('SELECT * FROM album LIMIT :limit OFFSET :offset')
  Future<List<AlbumEntity>> getAllAlbum(int offset, int limit);

  @Query('SELECT * FROM album WHERE title = :title LIMIT 1')
  Future<AlbumEntity?> findAlbumByTitle(String title);

  @update
  Future<void> updateAlbum(AlbumEntity album);

  @insert
  Future<void> insertAlbum(AlbumEntity album);

  @delete
  Future<void> deleteAlbum(AlbumEntity album);
}
