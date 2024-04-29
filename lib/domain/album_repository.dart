import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/data/dao/album_dao.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/entity/album_entity.dart';
import 'package:photoapp/data/entity/media_entity.dart';
import 'package:photoapp/data/mapper/album_mapper.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
import 'package:photoapp/data/mapper/media_mapper.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/constants.dart';
import 'package:photoapp/utils/logger.dart';

abstract class AlbumRepository {
  Future<Album?> getAlbumByName(String name);

  Future<void> createAlbum(Album album);

  Future<List<Album>> getAlbumPaginated(int offset, int limit);

  Future<bool> updateAlbum(Album album);

  Future<void> addMediaToAlbum(String title, Media media);

  Future<void> removeMediaFromAlbum(String title, Media media);

  Future<void> deleteAlbum(Album album);

  Future<Map<String, Album>> persistAlbumDefault();

  Future<Album> createFavoriteAlbum({String title, String path});

  Future<Album> createRecycleBinAlbum({String title, String path});

  Future<void> moveToRecycleBin(Media media);

  Future<void> restoreMedia(Media media);
}

class AlbumLocalRepository extends AlbumRepository {
  final AlbumDao albumDao;
  final MediaDao mediaDao;
  final TagDao tagDao;

  AlbumLocalRepository(
      {required this.albumDao, required this.mediaDao, required this.tagDao}) {
    AlbumMapper.initialize(tagDao, mediaDao);
  }

  @override
  Future<List<Album>> getAlbumPaginated(int offset, int limit) async {
    final List<AlbumEntity> albumEntities =
        await albumDao.getAllAlbum(offset, limit);
    final List<Album> albums = await Future.wait(albumEntities
        .map((albumEntity) => AlbumMapper.transformToModel(albumEntity)));
    return albums;
  }

  @override
  Future<bool> updateAlbum(Album album) async {
    try {
      final albumEntity = AlbumMapper.transformToEntity(album);
      await albumDao.updateAlbum(albumEntity);
      return true;
    } catch (e) {
      LoggingUtil.logError('Error updating album: $e');
      return false;
    }
  }

  @override //create album if not exist and add media to album
  Future<Album?> addMediaToAlbum(String title, Media media) async {
    try {
      // check existing album
      AlbumEntity? albumEntity = await albumDao.findAlbumByTitle(title);
      if (albumEntity == null) {
        // create new album
        albumEntity = AlbumEntity(
          title: title,
          thumbnailPath: media.path,
          path: media.path,
          numberOfItems: 1,
          albumType: title,
        );
        await albumDao.insertAlbum(albumEntity);
      }

      //check exist media
      MediaEntity? mediaEntity = await mediaDao.findMediaById(media.id);
      if (mediaEntity == null) {
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
      }

      //get all media in album
      List<MediaEntity> mediaEntities =
          await mediaDao.findAllMediaByTitleAlbum(title);

      // check exist media in album if already exist return
      for (var mediaEntity in mediaEntities) {
        if (mediaEntity.id == media.id) {
          return AlbumMapper.transformToModel(albumEntity);
        }
      }

      // insert connection
      await albumDao.addMediaToExistAlbum(title, media.id);

      //update album
      albumEntity.numberOfItems = mediaEntities.length;
      albumEntity.thumbnailPath = mediaEntities.last.path;
      await albumDao.updateAlbum(albumEntity);

      AlbumEntity? insertedAlbum = await albumDao.findAlbumByTitle(title);
      return AlbumMapper.transformToModel(insertedAlbum!);
    } catch (e) {
      LoggingUtil.logError('Error creating album: $e');
    }
    return null;
  }

  @override
  Future<Album?> getAlbumByName(String name) async {
    AlbumEntity? albumEntity = await albumDao.findAlbumByTitle(name);
    if (albumEntity == null) {
      return null;
    }
    final Album album = await AlbumMapper.transformToModel(albumEntity);
    return album;
  }

  @override
  Future<void> createAlbum(Album album) async {
    try {
      //check exist media
      AlbumEntity? albumEntity = await albumDao.findAlbumByTitle(album.title);
      if (albumEntity != null) {
        return;
      }
      albumEntity = AlbumMapper.transformToEntity(album);
      await albumDao.insertAlbum(albumEntity);
    } catch (e) {
      throw Exception('Failed to create album: $e');
    }
  }

  @override
  Future<void> deleteAlbum(Album album) async {
    try {
      AlbumEntity? albumEntity = await albumDao.findAlbumByTitle(album.title);
      if (albumEntity != null) {
        return;
      }
      albumEntity = AlbumMapper.transformToEntity(album);
      await albumDao.deleteAlbum(albumEntity);
    } catch (e) {
      throw Exception('Failed to create album: $e');
    }
  }

  Future<void> addMediaToDatabase(Media media) async {
    MediaMapper.initialize(tagDao);
    MediaEntity? mediaEntity = await mediaDao.findMediaById(media.id);
    if (mediaEntity != null) {
      return;
    }

    LoggingUtil.logDebug('Save new media : ${media.id}');
    await mediaDao.insertMedia(MediaMapper.transformToEntity(media));
  }

  @override
  Future<Map<String, Album>> persistAlbumDefault() async {
    final List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);
    Map<String, Album> albumMaps = {};

    for (var album in albums) {
      const int assetCount = 50;
      final List<AssetEntity> assets =
          await album.getAssetListRange(start: 0, end: assetCount);

      for (var asset in assets) {
        String path = await asset.file.then((value) => value?.path ?? '');
        String albumCategory = _getCategoryFromPath(path);
        LoggingUtil.logDebug(albumCategory);

        Media media = await AssetMapper.transformAssetEntityToMedia(asset);

        await addMediaToDatabase(media);
        Album? album = await addMediaToAlbum(albumCategory, media);
        if (album != null) {
          albumMaps[albumCategory] = album;
        }
      }
    }

    return albumMaps;
  }

  String _getCategoryFromPath(String path) {
    if (path.contains('/DCIM/Camera/')) {
      return 'Camera';
    } else if (path.contains('/Pictures/')) {
      return 'Pictures';
    } else if (path.contains('/Screenshots/')) {
      return 'Screenshots';
    } else if (path.contains('/Download/')) {
      return 'Download';
    } else {
      return 'Other';
    }
  }

  @override
  Future<Album> createFavoriteAlbum(
      {String title = "Favorite", String path = favoriteLogoPath}) async {
    AlbumEntity albumEntity = AlbumEntity(
      title: title,
      thumbnailPath: path,
      path: path,
      numberOfItems: 0,
      albumType: title,
    );
    await albumDao.insertAlbum(albumEntity);
    AlbumEntity? insertedAlbum = await albumDao.findAlbumByTitle(title);
    if (insertedAlbum == null) {
      throw Exception('Failed to create album');
    }
    return AlbumMapper.transformToModel(insertedAlbum);
  }

  @override
  Future<Album> createRecycleBinAlbum(
      {String title = "Recycle Bin", String path = recycleBinLogoPath}) async {
    AlbumEntity albumEntity = AlbumEntity(
      title: title,
      thumbnailPath: path,
      path: path,
      numberOfItems: 0,
      albumType: title,
    );
    await albumDao.insertAlbum(albumEntity);
    AlbumEntity? insertedAlbum = await albumDao.findAlbumByTitle(title);
    if (insertedAlbum == null) {
      throw Exception('Failed to create album');
    }
    return AlbumMapper.transformToModel(albumEntity);
  }

  @override
  Future<void> removeMediaFromAlbum(String title, Media media) async {
    // Get the album
    final albums = await getAlbumByName(title);
    if (albums == null) {
      return;
    }
    await albumDao.deleteMediaFromAlbum(title, media.id);
  }

  @override
  Future<void> moveToRecycleBin(Media media) {
    // TODO: implement moveToRecycleBin
    throw UnimplementedError();
  }

  @override
  Future<void> restoreMedia(Media media) {
    // TODO: implement restoreMedia
    throw UnimplementedError();
  }
}
