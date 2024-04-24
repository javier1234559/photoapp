import 'dart:io';

import 'package:floor/floor.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/database/db_helper.dart';

@Entity(tableName: 'media')
class Media {
  @primaryKey
  late String id;
  late String name;
  final String assetEntityId;
  late String path;
  late int dateAddedTimestamp;
  late int? dateModifiedTimestamp;
  late String type;
  bool isFavorite = false;

  // video properties
  String? duration;

// Constructor that floor can use
  Media(
      this.id,
      this.assetEntityId,
      this.name,
      this.path,
      this.dateAddedTimestamp,
      this.dateModifiedTimestamp,
      this.type,
      this.duration,
      this.isFavorite);

  // Private constructor
  Media._internal(this.assetEntityId);

  // Factory constructor to create Media instances
  factory Media.fromAssetEntityId(String assetEntityId) {
    final media = Media._internal(assetEntityId);
    media._setProperties();
    return media;
  }

  // Private method to set properties
  Future<void> _setProperties() async {
    final AssetEntity? asset = await AssetEntity.fromId(assetEntityId);
    if (asset != null) {
      id = asset.id; // set the id the same as the assetEntityId
      name = asset.title!;
      final File? file = await asset.file;
      final String fullPath = file!.path;
      path = fullPath;
      type = asset.type.toString();
      dateAddedTimestamp = asset.createDateTime.millisecondsSinceEpoch;
      dateModifiedTimestamp = asset.modifiedDateTime.millisecondsSinceEpoch;
      
      if (asset.type == AssetType.video) {
        duration = asset.videoDuration.toString().substring(2, 7);
      }
    } else {
      throw Exception('AssetEntity not found for the given ID');
    }
  }

  // Method to get AssetEntity from assetEntityId
  Future<AssetEntity> getAssetEntity() async {
    final AssetEntity? assetEntity = await AssetEntity.fromId(assetEntityId);
    if (assetEntity == null) {
      throw Exception('AssetEntity not found for the given ID: $assetEntityId');
    }
    return assetEntity;
  }
}
