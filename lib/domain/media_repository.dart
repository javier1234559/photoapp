import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/entity/media_entity.dart';
import 'package:photoapp/data/entity/tag_entity.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/domain/model/tag.dart';
import 'package:photoapp/utils/format.dart';
import 'package:photoapp/utils/logger.dart';

abstract class MediaRepository {
  Future<List<Media>> getAllMedia(int offset, int limit);
}

class MediaLocalRepository extends MediaRepository {
  final MediaDao _mediaDao;
  final TagDao _tagDao;

  MediaLocalRepository({required MediaDao mediaDao, required TagDao tagDao})
      : _mediaDao = mediaDao,
        _tagDao = tagDao;

  Future<Media?> getMediaById(String id) async {
    MediaEntity? mediaEntity = await _mediaDao.findMediaById(id);
    if (mediaEntity == null) {
      return null;
    }
    return _convertToMedia(mediaEntity);
  }

  Future<void> updateMedia(Media media) async {
    try {
      //check exist media
      MediaEntity? mediaEntity = await _mediaDao.findMediaById(media.id);
      if (mediaEntity == null) {
        throw Exception('Media is not exists');
      }
      mediaEntity = await _convertToMediaEntity(media);
      await _mediaDao.updateMedia(mediaEntity);
      LoggingUtil.logInfor('Update media with id: ${media.id}');
    } catch (e) {
      throw Exception('Failed to update media: $e');
    }
  }

  Future<void> createMedia(Media media) async {
    try {
      //check exist media
      MediaEntity? mediaEntity = await _mediaDao.findMediaById(media.id);
      if (mediaEntity != null) {
        throw Exception('Media already exists');
      }
      mediaEntity = await _convertToMediaEntity(media);
      await _mediaDao.insertMedia(mediaEntity);
    } catch (e) {
      throw Exception('Failed to create media: $e');
    }
  }

  Future<void> deleteMedia(Media media) async {
    MediaEntity? mediaEntity = await _mediaDao.findMediaById(media.id);
    if (mediaEntity == null) {
      throw Exception('Media is not exists');
    }
    mediaEntity = await _convertToMediaEntity(media);
    return _mediaDao.deleteMedia(mediaEntity);
  }

  @override
  Future<List<Media>> getAllMedia(int offset, int limit) {
    return _mediaDao.findAllMedia().then((mediaEntities) async {
      final List<Media> mediaList = [];
      for (final mediaEntity in mediaEntities) {
        final media = await _convertToMedia(mediaEntity);
        mediaList.add(media);
      }
      return mediaList;
    });
  }

  Future<Media> _convertToMedia(MediaEntity mediaEntity) async {
    List<TagEntity> tags = await _tagDao.findAllTagsByMediaId(mediaEntity.id);

    return Future.value(Media(
      id: mediaEntity.id,
      name: mediaEntity.name,
      path: mediaEntity.path,
      dateAddedTimestamp: mediaEntity.dateAddedTimestamp,
      dateModifiedTimestamp: mediaEntity.dateModifiedTimestamp,
      type: mediaEntity.type,
      duration: mediaEntity.duration,
      isFavorite: mediaEntity.isFavorite,
      tags: tags
          .map((tag) => Tag(id: tag.id, color: tag.color, name: tag.name))
          .toList(),
    ));
  }

  Future<MediaEntity> _convertToMediaEntity(Media media) {
    return Future.value(MediaEntity(
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
    final List<AssetEntity> mediaAssets = assets.where((asset) {
      return asset.type == AssetType.image || asset.type == AssetType.video;
    }).toList();

    // Convert AssetEntity objects to Media objects
    final List<Media> mediaList = [];
    for (final asset in mediaAssets) {
      final media = await _convertAssetEntityToMedia(asset);
      mediaList.add(media);
    }

    return mediaList;
  }

  Future<Media> _convertAssetEntityToMedia(AssetEntity asset) async {
    Media converted = Media(
      id: asset.id,
      name: asset.title ?? 'No Title',
      path: await asset.file.then((value) => value?.path ?? ''),
      dateAddedTimestamp: asset.createDateTime.millisecondsSinceEpoch,
      dateModifiedTimestamp: asset.modifiedDateTime.millisecondsSinceEpoch,
      type: asset.type.name.toString(),
      duration: asset.type == AssetType.video
          ? Format.formatSeconds(asset.duration.toString())
          : '00.00',
      tags: [],
    );
    LoggingUtil.logDebug(converted.toString());
    return converted;
  }
}
