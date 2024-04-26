import 'package:floor/floor.dart';

@Entity(tableName: 'album')
class AlbumEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  final String thumbnailPath;
  final String path;
  final int numberOfItems;
  final String albumType;

  AlbumEntity({
    this.id = 0, // Set the default value
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
