import 'package:photoapp/data/dao/album_dao.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/entity/album_entity.dart';
import 'package:photoapp/data/entity/media_entity.dart';
import 'package:photoapp/data/entity/tag_entity.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/domain/model/tag.dart';
import 'package:photoapp/utils/logger.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAlbumPaginated(int offset, int limit);

  Future<bool> updateAlbum(Album album);

  Future<void> createAlbum(String title, String albumType, Media media);
}

class AlbumLocalRepository extends AlbumRepository {
  final AlbumDao albumDao;
  final MediaDao mediaDao;
  final TagDao tagDao;

  AlbumLocalRepository(
      {required this.albumDao, required this.mediaDao, required this.tagDao});

  @override
  Future<List<Album>> getAlbumPaginated(int offset, int limit) async {
    final List<AlbumEntity> albumEntities =
        await albumDao.getAllAlbum(offset, limit);
    final List<Album> albums = [];

    for (final albumEntity in albumEntities) {
      final List<MediaEntity> mediaEntities =
          await mediaDao.findAllMediaByTitleAlbum(albumEntity.title);
      final List<Media> medias = await _mapMediaEntitiesToMedias(mediaEntities);
      final Album album = _mapAlbumEntityToAlbum(albumEntity, medias);
      albums.add(album);
    }

    return albums;
  }

  @override
  Future<bool> updateAlbum(Album album) async {
    try {
      final albumEntity = AlbumEntity(
        id: album.id,
        title: album.title,
        thumbnailPath: album.thumbnailPath,
        path: album.path,
        numberOfItems: album.numberOfItems,
        albumType: album.albumType,
      );

      await albumDao.updateAlbum(albumEntity);
      return true;
    } catch (e) {
      LoggingUtil.logError('Error updating album: $e');
      return false;
    }
  }

  @override
  Future<void> createAlbum(String title, String albumType, Media media) async {
    try {
      // check existing album
      AlbumEntity? albumEntity = await albumDao.findAlbumByTitle(title);
      if (albumEntity != null) {
        // create new album
        albumEntity = AlbumEntity(
          title: title,
          thumbnailPath: media.path,
          path: media.path,
          numberOfItems: 1,
          albumType: albumType,
        );
      }

      // insert media to database
      await mediaDao.insertMedia(MediaEntity(
        id: media.id,
        name: media.name,
        path: media.path,
        dateAddedTimestamp: media.dateAddedTimestamp,
        dateModifiedTimestamp: media.dateModifiedTimestamp,
        type: media.type,
        duration: media.duration,
        isFavorite: media.isFavorite,
      ));

      await albumDao.insertAlbum(albumEntity!);
    } catch (e) {
      LoggingUtil.logError('Error creating album: $e');
    }
  }

  //private methods
  Future<List<Media>> _mapMediaEntitiesToMedias(
      List<MediaEntity> mediaEntities) async {
    final List<Media> medias = [];

    for (final mediaEntity in mediaEntities) {
      final List<Tag> tags = await _getTagsForMedia(mediaEntity);
      final media = Media(
        id: mediaEntity.id,
        name: mediaEntity.name,
        path: mediaEntity.path,
        dateAddedTimestamp: mediaEntity.dateAddedTimestamp,
        dateModifiedTimestamp: mediaEntity.dateModifiedTimestamp,
        type: mediaEntity.type,
        duration: mediaEntity.duration,
        isFavorite: mediaEntity.isFavorite,
        tags: tags,
      );
      medias.add(media);
    }

    return medias;
  }

  Future<List<Tag>> _getTagsForMedia(MediaEntity mediaEntity) async {
    final List<Tag> tags = [];
    final List<TagEntity> tagEntities =
        await tagDao.findAllTagsByMediaId(mediaEntity.id);

    for (final tagEntity in tagEntities) {
      final tag = Tag(
        id: tagEntity.id,
        name: tagEntity.name,
        color: tagEntity.color,
      );
      tags.add(tag);
    }

    return tags;
  }

  Album _mapAlbumEntityToAlbum(AlbumEntity albumEntity, List<Media> medias) {
    return Album(
      id: albumEntity.id,
      title: albumEntity.title,
      thumbnailPath: albumEntity.thumbnailPath,
      path: albumEntity.path,
      numberOfItems: albumEntity.numberOfItems,
      albumType: albumEntity.albumType,
      medias: medias,
    );
  }
}
