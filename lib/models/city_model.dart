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
      id: json['id'],
      name: json['name'],
      country: json['country'],
    );
  }
}
