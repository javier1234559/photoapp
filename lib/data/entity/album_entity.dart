import 'package:floor/floor.dart';

@Entity(tableName: 'album')
class AlbumEntity {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String title;
  String thumbnailPath;
  String path;
  int numberOfItems;
  String albumType;

  AlbumEntity({
    this.id,
    required this.title,
    required this.thumbnailPath,
    required this.path,
    required this.numberOfItems,
    required this.albumType,
  });

  @override
  String toString() {
    return 'AlbumEntity{id: $id, title: $title, thumbnailPath: $thumbnailPath, path: $path, numberOfItems: $numberOfItems, albumType: $albumType}';
  }
}
