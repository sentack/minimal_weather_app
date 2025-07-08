import 'package:flutter/material.dart';

class Weather {
  final String cityName;
  final double temprature;
  final double feelsLike;
  final String mainCondition;
  final String description;
  final String iconCode;
  final double windSpeed;
  final double windDegree;
  final double? windGust;
  final String country;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int? seaLevelPressure;
  final int? groundLevelPressure;
  final int humidity;
  final int visibility;
  final int cloudiness;
  final double? rainLastHour;
  final double? snowLastHour;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime dataTime;
  final int timezoneOffset;
  final double latitude;
  final double longitude;

  Weather({
    required this.cityName,
    required this.temprature,
    required this.feelsLike,
    required this.mainCondition,
    required this.description,
    required this.iconCode,
    required this.windSpeed,
    required this.windDegree,
    this.windGust,
    required this.country,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    this.seaLevelPressure,
    this.groundLevelPressure,
    required this.humidity,
    required this.visibility,
    required this.cloudiness,
    this.rainLastHour,
    this.snowLastHour,
    required this.sunrise,
    required this.sunset,
    required this.dataTime,
    required this.timezoneOffset,
    required this.latitude,
    required this.longitude,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temprature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      windSpeed: json['wind']['speed'].toDouble(),
      windDegree: json['wind']['deg'].toDouble(),
      windGust: json['wind']['gust']?.toDouble(),
      country: json['sys']['country'],
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      pressure: json['main']['pressure'],
      seaLevelPressure: json['main']['sea_level'],
      groundLevelPressure: json['main']['grnd_level'],
      humidity: json['main']['humidity'],
      visibility: json['visibility'] ?? 10000,
      cloudiness: json['clouds']['all'],
      rainLastHour: json['rain']?['1h']?.toDouble(),
      snowLastHour: json['snow']?['1h']?.toDouble(),
      sunrise:
          DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      dataTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      timezoneOffset: json['timezone'],
      latitude: json['coord']['lat'].toDouble(),
      longitude: json['coord']['lon'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temprature': temprature,
      'feelsLike': feelsLike,
      'mainCondition': mainCondition,
      'description': description,
      'iconCode': iconCode,
      'windSpeed': windSpeed,
      'windDegree': windDegree,
      'windGust': windGust,
      'country': country,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'pressure': pressure,
      'seaLevelPressure': seaLevelPressure,
      'groundLevelPressure': groundLevelPressure,
      'humidity': humidity,
      'visibility': visibility,
      'cloudiness': cloudiness,
      'rainLastHour': rainLastHour,
      'snowLastHour': snowLastHour,
      'sunrise': sunrise.millisecondsSinceEpoch,
      'sunset': sunset.millisecondsSinceEpoch,
      'dataTime': dataTime.millisecondsSinceEpoch,
      'timezoneOffset': timezoneOffset,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Helper methods
  String get visibilityDescription {
    if (visibility >= 10000) return 'Excellent';
    if (visibility >= 5000) return 'Good';
    if (visibility >= 2000) return 'Moderate';
    if (visibility >= 1000) return 'Poor';
    return 'Very Poor';
  }

  String get humidityDescription {
    if (humidity <= 30) return 'Dry';
    if (humidity <= 60) return 'Comfortable';
    if (humidity <= 80) return 'Humid';
    return 'Very Humid';
  }

  String get pressureDescription {
    if (pressure >= 1020) return 'High';
    if (pressure >= 1000) return 'Normal';
    return 'Low';
  }

  String get cloudinessDescription {
    if (cloudiness <= 10) return 'Clear';
    if (cloudiness <= 25) return 'Few Clouds';
    if (cloudiness <= 50) return 'Partly Cloudy';
    if (cloudiness <= 75) return 'Mostly Cloudy';
    return 'Overcast';
  }

  String get uvIndexDescription {
    // Simulate UV index based on time and cloudiness
    final hour = dataTime.hour;
    if (hour < 6 || hour > 18) return 'Low';

    final baseUV = hour >= 10 && hour <= 14 ? 8 : 5;
    final adjustedUV = (baseUV * (1 - cloudiness / 100)).round();

    if (adjustedUV <= 2) return 'Low';
    if (adjustedUV <= 5) return 'Moderate';
    if (adjustedUV <= 7) return 'High';
    if (adjustedUV <= 10) return 'Very High';
    return 'Extreme';
  }

  Color get uvIndexColor {
    switch (uvIndexDescription) {
      case 'Low':
        return Colors.green;
      case 'Moderate':
        return Colors.yellow;
      case 'High':
        return Colors.orange;
      case 'Very High':
        return Colors.red;
      case 'Extreme':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
