import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

class WeatherCard extends StatelessWidget {
  final Weather? weather;

  const WeatherCard({super.key, this.weather});

  String _getWeatherAnimation(String mainCondition) {
    if (mainCondition.isEmpty) return 'assets/loading.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunderstorm.json';
      case 'clear':
        return 'assets/sunny.json';
      case 'snow':
        return 'assets/snowy.json';
      default:
        return 'assets/sunny.json';
    }
  }

  String _capitalize(String word) {
    if (word.isEmpty) return word;
    return "${word[0].toUpperCase()}${word.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // City Name
          Text(
            weather != null
                ? "${weather!.cityName}, ${weather!.country}"
                : "Loading...",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Weather Animation
          SizedBox(
            height: 150,
            child: Lottie.asset(
              _getWeatherAnimation(weather?.mainCondition ?? ''),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),

          // Temperature
          Text(
            weather != null ? '${weather!.temprature.round()}°C' : '--°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),

          // Weather Description
          Text(
            weather?.description
                    .split(' ')
                    .map((word) => _capitalize(word))
                    .join(' ') ??
                'Loading...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Min/Max Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTempInfo(
                'Min',
                weather?.tempMin.round().toString() ?? '--',
                Icons.arrow_downward,
              ),
              const SizedBox(width: 40),
              _buildTempInfo(
                'Max',
                weather?.tempMax.round().toString() ?? '--',
                Icons.arrow_upward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTempInfo(String label, String temp, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${temp}°C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
