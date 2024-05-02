import 'tag.dart';

class Media {
  String id;
  String name;
  String path;
  int dateAddedTimestamp;
  int? dateModifiedTimestamp;
  String type;
  String? duration;
  bool isFavorite;
  bool isDelete;
  List<Tag> tags;

  Media({
    required this.id,
    required this.name,
    required this.path,
    required this.dateAddedTimestamp,
    this.dateModifiedTimestamp,
    required this.type,
    this.duration,
    this.isFavorite = false,
    this.isDelete = false,
    required this.tags,
  });

  @override
  toString(){
    return 'Media{id: $id, name: $name, path: $path, dateAddedTimestamp: $dateAddedTimestamp, dateModifiedTimestamp: $dateModifiedTimestamp, type: $type, duration: $duration, isFavorite: $isFavorite, isDelete: $isDelete, tags: $tags}';
  }


}
