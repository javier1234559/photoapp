import 'package:floor/floor.dart';

@Entity(tableName: 'media_album')
class MediaAlbumEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final int imageId;
  final int albumId;

  MediaAlbumEntity(this.id, this.imageId, this.albumId);
}
