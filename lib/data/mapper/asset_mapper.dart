import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/utils/format.dart';

class AssetMapper {
  static Future<Media> transformAssetEntityToMedia(AssetEntity asset) async {
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
    // LoggingUtil.logDebug(converted.toString());
    return converted;
  }

  static Future<AssetEntity?> transformMediaToAssetEntity(Media media) async {
    AssetEntity? assetEntity = await AssetEntity.fromId(media.id);
    return assetEntity;
  }
}
