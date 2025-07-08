class SearchHistory {
  final int? id;
  final String cityName;
  final String country;
  final int cityId;
  final DateTime searchedAt;

  SearchHistory({
    this.id,
    required this.cityName,
    required this.country,
    required this.cityId,
    required this.searchedAt,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'],
      cityName: json['city_name'],
      country: json['country'],
      cityId: json['city_id'],
      searchedAt: DateTime.parse(json['searched_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_name': cityName,
      'country': country,
      'city_id': cityId,
      'searched_at': searchedAt.toIso8601String(),
    };
  }
}
