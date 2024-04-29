class Tag {
  int? id;
  String name;
  String color;

  Tag({
    this.id,
    required this.name,
    required this.color,
  });

  @override
  toString() {
    return 'Tag{id: $id, name: $name, color: $color}';
  }

  toJSon() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}
