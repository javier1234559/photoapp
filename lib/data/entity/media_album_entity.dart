import 'package:floor/floor.dart';

@Entity(tableName: 'media_album')
class MediaAlbumEntity {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final int mediaId;
  final int albumId;

  MediaAlbumEntity(this.id, this.mediaId, this.albumId);
}
