import 'package:floor/floor.dart';
import 'package:photo_manager/photo_manager.dart';

@Entity(tableName: 'album')
class Album {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  final String assetEntityThumbnailId;
  final String path;

  Album(this.id, this.title, this.assetEntityThumbnailId, this.path);

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
