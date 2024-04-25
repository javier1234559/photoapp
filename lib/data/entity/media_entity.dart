import 'dart:convert';
import 'package:floor/floor.dart';

@Entity(tableName: 'media')
class MediaEntity {
  @primaryKey
  final String id;
  final String name;
  final String path;
  final int dateAddedTimestamp;
  final int? dateModifiedTimestamp;
  final String type;
  bool isFavorite;

  // video properties
  String? duration;

  MediaEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.dateAddedTimestamp,
    this.dateModifiedTimestamp,
    required this.type,
    this.duration,
    this.isFavorite = false,
  });

  factory MediaEntity.fromJson(Map<String, dynamic> json) {
    return MediaEntity(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      dateAddedTimestamp: json['dateAddedTimestamp'],
      dateModifiedTimestamp: json['dateModifiedTimestamp'],
      type: json['type'],
      duration: json['duration'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'dateAddedTimestamp': dateAddedTimestamp,
      'dateModifiedTimestamp': dateModifiedTimestamp,
      'type': type,
      'duration': duration,
      'isFavorite': isFavorite,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  static MediaEntity fromJsonString(String jsonString) {
    return MediaEntity.fromJson(json.decode(jsonString));
  }
  // // Private constructor
  // Media._internal(this.assetEntityId);

  // // Factory constructor to create Media instances
  // factory Media.fromAssetEntityId(String assetEntityId) {
  //   final media = Media._internal(assetEntityId);
  //   media._setProperties();
  //   return media;
  // }

  // // Private method to set properties
  // Future<void> _setProperties() async {
  //   final AssetEntity? asset = await AssetEntity.fromId(assetEntityId);
  //   if (asset != null) {
  //     id = asset.id; // set the id the same as the assetEntityId
  //     name = asset.title!;
  //     final File? file = await asset.file;
  //     final String fullPath = file!.path;
  //     path = fullPath;
  //     type = asset.type.toString();
  //     dateAddedTimestamp = asset.createDateTime.millisecondsSinceEpoch;
  //     dateModifiedTimestamp = asset.modifiedDateTime.millisecondsSinceEpoch;

  //     if (asset.type == AssetType.video) {
  //       duration = asset.videoDuration.toString().substring(2, 7);
  //     }
  //   } else {
  //     throw Exception('AssetEntity not found for the given ID');
  //   }
  // }

  // // Method to get AssetEntity from assetEntityId
  // Future<AssetEntity> getAssetEntity() async {
  //   final AssetEntity? assetEntity = await AssetEntity.fromId(assetEntityId);
  //   if (assetEntity == null) {
  //     throw Exception('AssetEntity not found for the given ID: $assetEntityId');
  //   }
  //   return assetEntity;
  // }
}
