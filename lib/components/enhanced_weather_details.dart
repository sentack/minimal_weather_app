import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class EnhancedWeatherDetails extends StatelessWidget {
  final Weather? weather;

  const EnhancedWeatherDetails({super.key, this.weather});

  String _getWindDirection(double degrees) {
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
    
    return 'N';
  }

  String _formatTemperature(double temp, String unit) {
    if (unit == 'fahrenheit') {
      return '${temp.round()}°F';
    }
    return '${temp.round()}°C';
  }

  String _formatWindSpeed(double speed, String unit) {
    if (unit == 'fahrenheit') {
      final mph = speed * 2.237;
      return '${mph.toStringAsFixed(1)} mph';
    }
    return '${speed.toStringAsFixed(1)} m/s';
  }

  String _formatVisibility(int visibility, String unit) {
    if (unit == 'fahrenheit') {
      final miles = visibility * 0.000621371;
      return '${miles.toStringAsFixed(1)} mi';
    }
    return '${(visibility / 1000).toStringAsFixed(1)} km';
  }

  String _formatPressure(int pressure, String unit) {
    if (unit == 'fahrenheit') {
      final inHg = pressure * 0.02953;
      return '${inHg.toStringAsFixed(2)} inHg';
    }
    return '$pressure hPa';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settingsProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Column(
          children: [
            // Main Weather Details Card
            _buildMainDetailsCard(context, settingsProvider, isDark),
            const SizedBox(height: 16),
            
            // Sun & Moon Card
            _buildSunMoonCard(context, isDark),
            const SizedBox(height: 16),
            
            // Air Quality & Visibility Card
            _buildAirQualityCard(context, settingsProvider, isDark),
            const SizedBox(height: 16),
            
            // Precipitation & Clouds Card
            _buildPrecipitationCard(context, isDark),
          ],
        );
      },
    );
  }

  Widget _buildMainDetailsCard(BuildContext context, SettingsProvider settingsProvider, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppTheme.darkTextSecondary.withOpacity(0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // First Row: Feels Like & Humidity
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.thermostat,
                  title: 'Feels Like',
                  value: weather != null 
                      ? _formatTemperature(weather!.feelsLike, settingsProvider.temperatureUnit)
                      : '--',
                  subtitle: 'Human perception',
                  color: AppTheme.warning,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.water_drop,
                  title: 'Humidity',
                  value: weather != null ? '${weather!.humidity}%' : '--',
                  subtitle: weather?.humidityDescription ?? '--',
                  color: AppTheme.lightBlue,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Second Row: Wind & Pressure
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.air,
                  title: 'Wind',
                  value: weather != null 
                      ? _formatWindSpeed(weather!.windSpeed, settingsProvider.temperatureUnit)
                      : '--',
                  subtitle: weather != null ? _getWindDirection(weather!.windDegree) : '--',
                  color: AppTheme.accentBlue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.speed,
                  title: 'Pressure',
                  value: weather != null 
                      ? _formatPressure(weather!.pressure, settingsProvider.temperatureUnit)
                      : '--',
                  subtitle: weather?.pressureDescription ?? '--',
                  color: AppTheme.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSunMoonCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppTheme.darkTextSecondary.withOpacity(0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sun & Moon',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.wb_sunny,
                  title: 'Sunrise',
                  value: weather != null ? _formatTime(weather!.sunrise) : '--',
                  subtitle: 'Morning',
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.nights_stay,
                  title: 'Sunset',
                  value: weather != null ? _formatTime(weather!.sunset) : '--',
                  subtitle: 'Evening',
                  color: Colors.deepPurple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualityCard(BuildContext context, SettingsProvider settingsProvider, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppTheme.darkTextSecondary.withOpacity(0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Air Quality & Visibility',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.visibility,
                  title: 'Visibility',
                  value: weather != null 
                      ? _formatVisibility(weather!.visibility, settingsProvider.temperatureUnit)
                      : '--',
                  subtitle: weather?.visibilityDescription ?? '--',
                  color: AppTheme.lightBlue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.wb_sunny_outlined,
                  title: 'UV Index',
                  value: weather?.uvIndexDescription ?? '--',
                  subtitle: 'Sun exposure',
                  color: weather?.uvIndexColor ?? Colors.grey,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrecipitationCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppTheme.darkTextSecondary.withOpacity(0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Precipitation & Clouds',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: Icons.cloud,
                  title: 'Cloudiness',
                  value: weather != null ? '${weather!.cloudiness}%' : '--',
                  subtitle: weather?.cloudinessDescription ?? '--',
                  color: Colors.blueGrey,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  context: context,
                  icon: weather?.rainLastHour != null ? Icons.grain : 
                        weather?.snowLastHour != null ? Icons.ac_unit : Icons.water_drop_outlined,
                  title: weather?.rainLastHour != null ? 'Rain (1h)' : 
                        weather?.snowLastHour != null ? 'Snow (1h)' : 'Precipitation',
                  value: weather?.rainLastHour != null ? '${weather!.rainLastHour!.toStringAsFixed(1)} mm' :
                         weather?.snowLastHour != null ? '${weather!.snowLastHour!.toStringAsFixed(1)} mm' : 'None',
                  subtitle: weather?.rainLastHour != null ? 'Rainfall' :
                           weather?.snowLastHour != null ? 'Snowfall' : 'No precipitation',
                  color: weather?.rainLastHour != null ? Colors.blue :
                         weather?.snowLastHour != null ? Colors.lightBlue : Colors.grey,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          // Wind Gust if available
          if (weather?.windGust != null) ...[
            const SizedBox(height: 16),
            _buildDetailItem(
              context: context,
              icon: Icons.tornado,
              title: 'Wind Gust',
              value: '${weather!.windGust!.toStringAsFixed(1)} m/s',
              subtitle: 'Maximum gust speed',
              color: AppTheme.warning,
              isDark: isDark,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? color.withOpacity(0.15) 
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? color.withOpacity(0.3) 
              : color.withOpacity(0.2),
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
                    color: isDark 
                        ? AppTheme.darkTextSecondary 
                        : AppTheme.textSecondary,
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
              color: isDark 
                  ? AppTheme.darkTextPrimary 
                  : AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark 
                  ? AppTheme.darkTextSecondary.withOpacity(0.8)
                  : AppTheme.textSecondary.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
