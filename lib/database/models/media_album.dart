import 'package:floor/floor.dart';

@Entity(tableName: 'media_album')
class MediaAlbum {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int imageId;
  final int albumId;

  MediaAlbum(this.id, this.imageId, this.albumId);
}
