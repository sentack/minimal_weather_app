import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeatherByCityID(int cityId,
      {String units = 'metric'}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl?id=$cityId&appid=$apiKey&units=$units'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Weather> getWeather({String units = 'metric'}) async {
    try {
      // Always check and request permission when accessing current location
      LocationPermission permission = await _handleLocationPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationPermissionException(
            'Location permission is required to get current weather');
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceException(
            'Location services are disabled. Please enable location services in your device settings.');
      }

      // Get current position with multiple attempts and different accuracy levels
      Position position = await _getCurrentPositionWithFallback();

      final response = await http
          .get(Uri.parse(
              '$baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=$units'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      if (e is LocationPermissionException || e is LocationServiceException) {
        rethrow;
      }
      throw Exception('Failed to get current location weather: $e');
    }
  }

  Future<Position> _getCurrentPositionWithFallback() async {
    // Try high accuracy first with shorter timeout
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (e) {
      print('High accuracy location failed, trying medium accuracy: $e');

      // Fallback to medium accuracy with longer timeout
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 12),
        );
      } catch (e) {
        print('Medium accuracy location failed, trying low accuracy: $e');

        // Final fallback to low accuracy with even longer timeout
        try {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 20),
          );
        } catch (e) {
          print('All location attempts failed, trying last known position: $e');

          // Last resort: try to get last known position
          Position? lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            return lastPosition;
          }

          throw LocationTimeoutException(
              'Unable to get current location. Please check if location services are enabled and try again.');
        }
      }
    }
  }

  Future<LocationPermission> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    // If permission is denied, always request it again
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // If permission is still denied after request, throw exception
    if (permission == LocationPermission.denied) {
      throw LocationPermissionException(
          'Location permission denied. Please grant location permission to get current weather.');
    }

    // If permission is permanently denied, provide guidance
    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionException(
          'Location permission permanently denied. Please enable location permission in app settings to get current weather.');
    }

    return permission;
  }
}

// Custom exception classes for better error handling
class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);

  @override
  String toString() => message;
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => message;
}

class LocationTimeoutException implements Exception {
  final String message;
  LocationTimeoutException(this.message);

  @override
  String toString() => message;
}
