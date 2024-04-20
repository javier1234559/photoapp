class Album {
 final int id;
 final String name;

 Album({required this.id, required this.name});

 Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
 }

 static Album fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'],
      name: map['name'],
    );
 }
}