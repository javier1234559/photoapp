import 'package:floor/floor.dart';

@Entity(tableName: 'tags')
class Tag {
  @primaryKey
  final int id;
  final String name;
  final int mediaId; // Foreign key referencing

  Tag({required this.id, required this.name, required this.mediaId});
}
