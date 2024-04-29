import 'package:floor/floor.dart';
import 'package:photoapp/data/entity/tag_entity.dart';

@dao
abstract class TagDao {
  @Query('SELECT * FROM tag')
  Future<List<TagEntity>> findAllTags();

  @Query('SELECT * FROM tag WHERE mediaId = :mediaId')
  Future<List<TagEntity>> findAllTagsByMediaId(String mediaId);

   @Query('INSERT INTO tag (name, color, mediaId) VALUES (:name, :color, :mediaId)')
  Future<void> createHashTagToMedia(String mediaId, String name, String color);

  @Query('DELETE FROM tag WHERE mediaId = :mediaId ')
  Future<void> deleteAllTagToMedia(String mediaId);

  @delete
  Future<void> deleteTag(TagEntity tag);
}
