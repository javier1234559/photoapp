import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/entity/media_entity.dart';
import 'package:photoapp/data/entity/tag_entity.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/domain/model/tag.dart';

class MediaMapper {
  static TagDao? tagDao;

  static void initialize(TagDao tagDao) {
    MediaMapper.tagDao = tagDao;
  }

  static Future<Media> transformToModel(final MediaEntity entity) async {
    List<TagEntity>? tags = await tagDao?.findAllTagsByMediaId(entity.id);
    return Media(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      dateAddedTimestamp: entity.dateAddedTimestamp,
      dateModifiedTimestamp: entity.dateModifiedTimestamp,
      type: entity.type,
      duration: entity.duration,
      isFavorite: entity.isFavorite,
      tags: tags
          !.map((tag) => Tag(id: tag.id!, name: tag.name, color: tag.color))
          .toList(),
    );
  }

  static MediaEntity transformToEntity(final Media media) {
    return MediaEntity(
      id: media.id,
      name: media.name,
      path: media.path,
      dateAddedTimestamp: media.dateAddedTimestamp,
      dateModifiedTimestamp: media.dateModifiedTimestamp,
      type: media.type,
      duration: media.duration,
      isFavorite: media.isFavorite,
    );
  }
}
