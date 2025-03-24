class City {
  final int id;
  final String name;
  final String country;

  City({
    required this.id,
    required this.name,
    required this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: (json['id'] is double)
          ? (json['id'] as double)
              .toInt() // Some City IDs have floating points and we cant pass the value as id to the weather api so we convert it to integer
          : int.parse(json['id']
              .toString()), // same here to avoid any confusions with the ID type
      name: json['name'],
      country: json['country'],
    );
  }
}
