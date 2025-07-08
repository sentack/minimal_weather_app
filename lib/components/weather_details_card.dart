import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

class WeatherDetailsCard extends StatelessWidget {
  final Weather? weather;

  const WeatherDetailsCard({super.key, this.weather});

  String _getWindDirection(double degrees) {
    // Normalize degrees to 0-360 range
    degrees = degrees % 360;
    if (degrees < 0) degrees += 360;

    if (degrees >= 348.75 || degrees < 11.25) return 'N';
    if (degrees >= 11.25 && degrees < 33.75) return 'NNE';
    if (degrees >= 33.75 && degrees < 56.25) return 'NE';
    if (degrees >= 56.25 && degrees < 78.75) return 'ENE';
    if (degrees >= 78.75 && degrees < 101.25) return 'E';
    if (degrees >= 101.25 && degrees < 123.75) return 'ESE';
    if (degrees >= 123.75 && degrees < 146.25) return 'SE';
    if (degrees >= 146.25 && degrees < 168.75) return 'SSE';
    if (degrees >= 168.75 && degrees < 191.25) return 'S';
    if (degrees >= 191.25 && degrees < 213.75) return 'SSW';
    if (degrees >= 213.75 && degrees < 236.25) return 'SW';
    if (degrees >= 236.25 && degrees < 258.75) return 'WSW';
    if (degrees >= 258.75 && degrees < 281.25) return 'W';
    if (degrees >= 281.25 && degrees < 303.75) return 'WNW';
    if (degrees >= 303.75 && degrees < 326.25) return 'NW';
    if (degrees >= 326.25 && degrees < 348.75) return 'NNW';

    return 'N'; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Details',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.air,
                  title: 'Wind Speed',
                  value: weather != null ? '${weather!.windSpeed} m/s' : '--',
                  color: AppTheme.lightBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.navigation,
                  title: 'Wind Direction',
                  value: weather != null
                      ? _getWindDirection(weather!.windDegree)
                      : '--',
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.thermostat,
                  title: 'Feels Like',
                  value: weather != null
                      ? '${weather!.temprature.round()}°C'
                      : '--°C',
                  color: AppTheme.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.wb_sunny,
                  title: 'Condition',
                  value: weather?.mainCondition ?? '--',
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
