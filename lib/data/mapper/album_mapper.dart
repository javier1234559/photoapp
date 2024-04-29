import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/entity/album_entity.dart';
import 'package:photoapp/data/entity/media_entity.dart';
import 'package:photoapp/data/entity/tag_entity.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/domain/model/tag.dart';
import 'package:photoapp/utils/logger.dart';

class AlbumMapper {
  static late TagDao tagDao;
  static late MediaDao mediaDao;

  static void initialize(TagDao tagDao, MediaDao mediaDao) {
    AlbumMapper.tagDao = tagDao;
    AlbumMapper.mediaDao = mediaDao;
  }

  static AlbumEntity transformToEntity(final Album album) {
    return AlbumEntity(
      id: album.id,
      title: album.title,
      thumbnailPath: album.thumbnailPath,
      path: album.path,
      numberOfItems: album.numberOfItems,
      albumType: album.albumType,
    );
  }

  static Future<Album> transformToModel(AlbumEntity albumEntity) async {
    List<MediaEntity> mediaEntities =
        await mediaDao.findAllMediaByTitleAlbum(albumEntity.title);
    LoggingUtil.logInfor('Album have: ${mediaEntities.length} items');

    if (mediaEntities.isEmpty) {
      return Album(
        id: albumEntity.id!,
        title: albumEntity.title,
        thumbnailPath: albumEntity.thumbnailPath,
        path: albumEntity.path,
        numberOfItems: albumEntity.numberOfItems,
        albumType: albumEntity.albumType,
        medias: [],
      );
    }

    final List<Media> medias = [];
    for (var mediaEntity in mediaEntities) {
      List<TagEntity> tagEntities =
          await tagDao.findAllTagsByMediaId(mediaEntity.id);
      List<Tag> tags = tagEntities
          .map((tagEntity) => Tag(
              id: tagEntity.id, name: tagEntity.name, color: tagEntity.color))
          .toList();
      medias.add(Media(
        id: mediaEntity.id,
        name: mediaEntity.name,
        path: mediaEntity.path,
        dateAddedTimestamp: mediaEntity.dateAddedTimestamp,
        dateModifiedTimestamp: mediaEntity.dateModifiedTimestamp,
        type: mediaEntity.type,
        duration: mediaEntity.duration,
        isFavorite: mediaEntity.isFavorite,
        tags: tags,
      ));
    }
    LoggingUtil.logDebug('AlbumMapper: medias: ${medias.length}');
    return Album(
      id: albumEntity.id!,
      title: albumEntity.title,
      thumbnailPath: albumEntity.thumbnailPath,
      path: albumEntity.path,
      numberOfItems: albumEntity.numberOfItems,
      albumType: albumEntity.albumType,
      medias: medias,
    );
  }
}
