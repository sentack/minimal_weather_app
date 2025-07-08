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
          ? (json['id'] as double).toInt()
          : int.parse(json['id'].toString()),
      name: json['name'],
      country: json['country'],
    );
  }

  factory City.fromDatabaseJson(Map<String, dynamic> json) {
    return City(
      id: json['city_id'],
      name: json['name'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
    };
  }
}
