import 'package:floor/floor.dart';
import 'package:photoapp/data/entity/album_entity.dart';
import 'package:photoapp/data/entity/media_entity.dart';

@dao
abstract class MediaDao {
  @Query('SELECT * FROM media')
  Future<List<MediaEntity>> findAllMedia();

  @Query('SELECT * FROM media WHERE id = :id')
  Future<MediaEntity?> findMediaById(String id);

  @Query('''
  SELECT album.* FROM album 
  INNER JOIN media_album ON album.id = media_album.albumId
  WHERE media_album.mediaId = :mediaId
''')
  Future<List<AlbumEntity>> findAlbum(String mediaId);

  @Query('''
  SELECT media.* 
  FROM media 
  INNER JOIN media_album ON media.id = media_album.mediaId
  INNER JOIN album ON album.id = media_album.albumId
  WHERE album.title = :title
''')
  Future<List<MediaEntity>> findAllMediaByTitleAlbum(String title);

  @Query('SELECT EXISTS(SELECT 1 FROM album WHERE title = :name)')
  Future<bool?> checkExistAlbum(String name);

  @insert
  Future<void> insertMedia(MediaEntity media);

  @update
  Future<void> updateMedia(MediaEntity media);

  @delete
  Future<void> deleteMedia(MediaEntity media);
}
