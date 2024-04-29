import 'package:floor/floor.dart';

@Entity(tableName: 'tag')
class TagEntity {
  @primaryKey
  int? id;
  String name;
  String color;
  String mediaId; // Foreign key referencing

  TagEntity({
    this.id,
    required this.name,
    required this.color,
    required this.mediaId,
  });
}
