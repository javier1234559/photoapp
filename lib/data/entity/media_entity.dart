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
  bool isDelete;

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
    this.isDelete = false,
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
      isDelete: json['isDelete'] ?? false,
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
      'isDelete': isDelete,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  static MediaEntity fromJsonString(String jsonString) {
    return MediaEntity.fromJson(json.decode(jsonString));
  }

}
