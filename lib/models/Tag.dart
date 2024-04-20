class Tag {
 final int id;
 final String name;
 final int imageId; // Foreign key referencing Image

 Tag({required this.id, required this.name, required this.imageId});

 Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageId': imageId,
    };
 }

 static Tag fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      name: map['name'],
      imageId: map['imageId'],
    );
 }
}