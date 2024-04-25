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
    required this.tags,
  });
}
