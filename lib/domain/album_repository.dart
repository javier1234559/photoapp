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
import 'package:photoapp/utils/logger.dart';

abstract class AlbumRepository {
  Future<Album?> getAlbumByName(String name);

  Future<void> createAlbum(Album album);

  Future<List<Album>> getAlbumPaginated(int offset, int limit);

  Future<bool> updateAlbum(Album album);

  Future<void> addMediaToAlbum(String title, Media media);

  Future<void> deleteAlbum(Album album);

  Future<void> persistAlbumDefault();
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

  @override
  Future<void> addMediaToAlbum(String title, Media media) async {
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
      // insert connection
      await albumDao.addMediaToExistAlbum(title, media.id);
      
    } catch (e) {
      LoggingUtil.logError('Error creating album: $e');
    }
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

  @override
  Future<List<AlbumEntity>> persistAlbumDefault() async {
    final List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final List<AssetPathEntity> defaultAlbums = albums.where((album) {
      LoggingUtil.logDebug(album.name);
      return album.name == 'Download' ||
          album.name == 'Camera' ||
          album.name == 'Screenshots' ||
          album.name == 'Recent';
    }).toList();

    List<AlbumEntity> albumEntities = [];
    for (var album in defaultAlbums) {
      // add all media to database
      final List<AssetEntity> assets =
          await album.getAssetListRange(start: 0, end: 100);
      for (var asset in assets) {
        Media media = await AssetMapper.transformAssetEntityToMedia(asset);
        MediaMapper.initialize(tagDao);
        //check exist media
        MediaEntity? mediaEntity = await mediaDao.findMediaById(media.id);
        if (mediaEntity != null) {
          continue;
        }

        LoggingUtil.logDebug('Save new media : ${media.id}');
        await mediaDao.insertMedia(MediaMapper.transformToEntity(media));
      }

      AlbumEntity albumEntity = AlbumEntity(
        title: album.name,
        thumbnailPath:
            await assets.last.file.then((value) => value?.path ?? ''),
        path: "/${album.name}",
        numberOfItems: assets.length,
        albumType: 'default',
      );
      LoggingUtil.logDebug(albumEntity.toString());

      Album newAlbum = await AlbumMapper.transformToModel(albumEntity);
      await createAlbum(newAlbum);
      List<AlbumEntity> list = await albumDao.getAllAlbum(0, 20);
      LoggingUtil.logDebug(list[0].toString());

      // add meida to album
      for (var asset in assets) {
        Media media = await AssetMapper.transformAssetEntityToMedia(asset);
        await addMediaToAlbum(album.name, media);
      }

      albumEntities.add(albumEntity);
    }
    return albumEntities;
  }
}
