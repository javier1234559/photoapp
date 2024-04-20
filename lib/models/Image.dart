class Image {
 final int id;
 final String path;
 final bool isFavorite;
 final int albumId; // Foreign key referencing Album

 Image({required this.id, required this.path, this.isFavorite = false, required this.albumId});

 Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'isFavorite': isFavorite ? 1 : 0,
      'albumId': albumId,
    };
 }

 static Image fromMap(Map<String, dynamic> map) {
    return Image(
      id: map['id'],
      path: map['path'],
      isFavorite: map['isFavorite'] == 1,
      albumId: map['albumId'],
    );
 }
}