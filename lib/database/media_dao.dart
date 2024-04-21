import 'package:floor/floor.dart';
import 'package:photoapp/models/album.dart';
import 'package:photoapp/models/media.dart';

@dao
abstract class MediaDao {
  @Query('SELECT * FROM media')
  Future<List<Media>> findAllMedia();

  @Query('SELECT * FROM media WHERE albumId = :albumId')
  Future<List<Media>> findAllMediabyAlbumId(String albumId);

  @insert
  Future<void> insertMedia(Media media);

  @delete
  Future<void> deleteMedia(Media media);
}
