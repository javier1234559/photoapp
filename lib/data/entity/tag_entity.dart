import 'package:floor/floor.dart';

@Entity(tableName: 'tag')
class TagEntity {
  @primaryKey
  final int id;
  final String name;
  final String color;
  final int mediaId; // Foreign key referencing

  TagEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.mediaId,
  });
}
