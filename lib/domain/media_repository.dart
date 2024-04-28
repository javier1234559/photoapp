import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/entity/media_entity.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
import 'package:photoapp/data/mapper/media_mapper.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/logger.dart';

abstract class MediaRepository {
  Future<List<Media>> getAllMedia(int offset, int limit);
}

class MediaLocalRepository extends MediaRepository {
  final MediaDao mediaDao;
  final TagDao tagDao;

  MediaLocalRepository({required this.mediaDao, required this.tagDao}) {
    MediaMapper.initialize(tagDao);
  }

  Future<Media?> getMediaById(String id) async {
    MediaEntity? mediaEntity = await mediaDao.findMediaById(id);
    if (mediaEntity == null) {
      return null;
    }
    Media media = await MediaMapper.transformToModel(mediaEntity);
    return media;
  }

  Future<void> updateMedia(Media media) async {
    try {
      //check exist media
      MediaEntity? mediaEntity = await mediaDao.findMediaById(media.id);
      if (mediaEntity == null) {
        throw Exception('Media is not exists');
      }
      mediaEntity = MediaMapper.transformToEntity(media);
      await mediaDao.updateMedia(mediaEntity);
      LoggingUtil.logInfor('Update media with id: ${media.id}');
    } catch (e) {
      throw Exception('Failed to update media: $e');
    }
  }

  Future<void> createMedia(Media media) async {
    try {
      MediaEntity? mediaEntity = await mediaDao.findMediaById(media.id);
      if (mediaEntity != null) {
        throw Exception('Media already exists');
      }
      mediaEntity = MediaMapper.transformToEntity(media);
      await mediaDao.insertMedia(mediaEntity);
    } catch (e) {
      throw Exception('Failed to create media: $e');
    }
  }

  Future<void> deleteMedia(Media media) async {
    MediaEntity? mediaEntity = await mediaDao.findMediaById(media.id);
    if (mediaEntity == null) {
      throw Exception('Media is not exists');
    }
    mediaEntity = MediaMapper.transformToEntity(media);
    return mediaDao.deleteMedia(mediaEntity);
  }

  @override
  Future<List<Media>> getAllMedia(int offset, int limit) async {
    final List<MediaEntity> mediaEntities = await mediaDao.findAllMedia();
    final List<Media> medias = await Future.wait(mediaEntities
        .map((mediaEntity) => MediaMapper.transformToModel(mediaEntity)));
    return medias;
  }
}

class AssetMediaRepository extends MediaRepository {
  @override
  Future<List<Media>> getAllMedia(int offset, int limit) async {
    final List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity album = albums.firstWhere((element) => element.isAll);
    final List<AssetEntity> assets =
        await album.getAssetListRange(start: 0, end: limit);

    // Filter the assets to include only images and videos
    for (var asset in assets) {
      LoggingUtil.logDebug('Asset: ${asset.type} - ${asset.title}');
    }
    final List<AssetEntity> mediaAssets = assets.where((asset) {
      return  asset.type == AssetType.video;
    }).toList();

    final List<Media> mediaList = await Future.wait(mediaAssets
        .map((asset) => AssetMapper.transformAssetEntityToMedia(asset)));
    return mediaList;
  }
}
