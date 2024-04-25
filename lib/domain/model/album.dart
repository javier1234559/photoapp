import 'package:photoapp/domain/model/media.dart';

class Album {
  int id;
  String title;
  String thumbnailPath;
  String path;
  int numberOfItems;
  String albumType;
  List<Media> medias;

  Album({
    required this.id,
    required this.title,
    required this.thumbnailPath,
    required this.path,
    required this.numberOfItems,
    required this.albumType,
    required this.medias,
  });
}
