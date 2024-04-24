import 'package:floor/floor.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/database/models/media.dart';

@Entity(tableName: 'album')
class Album {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  String assetEntityThumbnailId;
  final String path;
  // int numberOfItems;

  Album(this.id, this.title, this.assetEntityThumbnailId, this.path);

  void addMediaToAlbum(Media media) {
    assetEntityThumbnailId = media.assetEntityId;
  }

  // Method to get AssetEntity from assetEntityId
  Future<AssetEntity> getThumbnailAssetEntity() async {
    final AssetEntity? assetEntity =
        await AssetEntity.fromId(assetEntityThumbnailId);
    if (assetEntity == null) {
      throw Exception(
          'AssetEntity not found for the given ID: $assetEntityThumbnailId');
    }
    return assetEntity;
  }
}
