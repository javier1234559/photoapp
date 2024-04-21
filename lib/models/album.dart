import 'package:floor/floor.dart';

@Entity(tableName: 'album')
class Album {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  final String assetEntityThumbnailId;
  final String path;

  Album(this.id, this.title, this.assetEntityThumbnailId, this.path);
}
