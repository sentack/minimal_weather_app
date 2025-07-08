import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class WeatherSummaryCard extends StatelessWidget {
  final Weather? weather;

  const WeatherSummaryCard({super.key, this.weather});

  String _formatTemperature(double temp, String unit) {
    if (unit == 'fahrenheit') {
      return '${temp.round()}°F';
    }
    return '${temp.round()}°C';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
              // Location and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather != null
                              ? "${weather!.cityName}, ${weather!.country}"
                              : "Loading...",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather != null
                              ? "Updated: ${_formatTime(weather!.dataTime)}"
                              : "Loading...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (weather != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getWeatherIcon(weather!.mainCondition),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Temperature and Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Temperature
                  Text(
                    weather != null 
                        ? _formatTemperature(weather!.temprature, settingsProvider.temperatureUnit)
                        : '--°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Weather Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          weather?.description
                                  .split(' ')
                                  .map((word) => word[0].toUpperCase() + word.substring(1))
                                  .join(' ') ??
                              'Loading...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weather != null
                              ? "Feels like ${_formatTemperature(weather!.feelsLike, settingsProvider.temperatureUnit)}"
                              : "Loading...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    icon: Icons.arrow_downward,
                    label: 'Min',
                    value: weather != null 
                        ? _formatTemperature(weather!.tempMin, settingsProvider.temperatureUnit)
                        : '--',
                  ),
                  _buildQuickStat(
                    icon: Icons.arrow_upward,
                    label: 'Max',
                    value: weather != null 
                        ? _formatTemperature(weather!.tempMax, settingsProvider.temperatureUnit)
                        : '--',
                  ),
                  _buildQuickStat(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: weather != null ? '${weather!.humidity}%' : '--',
                  ),
                  _buildQuickStat(
                    icon: Icons.air,
                    label: 'Wind',
                    value: weather != null ? '${weather!.windSpeed.toStringAsFixed(1)}m/s' : '--',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
