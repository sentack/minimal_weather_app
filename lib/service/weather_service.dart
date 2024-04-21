import 'dart:convert';
import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // ignore: constant_identifier_names
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';

  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeatherByCityID(int cityId) async {
    final response = await http
        .get(Uri.parse('$BASE_URL?id=$cityId&appid=$apiKey&units=metric'));

    await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Weather> getWeather() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    await Future.delayed(const Duration(seconds: 2));

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    var lat = position.latitude;
    var lon = position.longitude;

    final response = await http.get(
        Uri.parse('$BASE_URL?lon=$lon&lat=$lat&appid=$apiKey&units=metric'));

    await Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
