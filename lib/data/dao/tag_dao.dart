import 'package:floor/floor.dart';
import 'package:photoapp/data/entity/tag_entity.dart';

@dao
abstract class TagDao {
  @Query('SELECT * FROM tag')
  Future<List<TagEntity>> findAllTags();

  @Query('SELECT * FROM tag WHERE mediaId = :mediaId')
  Future<List<TagEntity>> findAllTagsByMediaId(String mediaId);

  @delete
  Future<void> deleteTag(TagEntity tag);
}
