class Weather {
  final String cityName;
  final double temprature;
  final String mainCondition;
  final String description;
  final double windSpeed;
  final double windDegree;
  final String country;
  final double tempMin;
  final double tempMax;

  Weather({
    required this.cityName,
    required this.temprature,
    required this.mainCondition,
    required this.description,
    required this.windSpeed,
    required this.windDegree,
    required this.country,
    required this.tempMin,
    required this.tempMax,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temprature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      windSpeed: json['wind']['speed'].toDouble(),
      windDegree: json['wind']['deg'].toDouble(),
      country: json['sys']['country'],
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
    );
  }
}
