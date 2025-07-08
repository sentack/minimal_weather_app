import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class LocationInfoCard extends StatelessWidget {
  final Weather? weather;

  const LocationInfoCard({super.key, this.weather});

  String _formatCoordinate(double coordinate, bool isLatitude) {
    final direction = isLatitude 
        ? (coordinate >= 0 ? 'N' : 'S')
        : (coordinate >= 0 ? 'E' : 'W');
    return '${coordinate.abs().toStringAsFixed(4)}° $direction';
  }

  String _formatTimezone(int offset) {
    final hours = offset ~/ 3600;
    final minutes = (offset % 3600) ~/ 60;
    final sign = hours >= 0 ? '+' : '';
    return 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
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
                'Location Information',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Coordinates Row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context: context,
                      icon: Icons.my_location,
                      title: 'Latitude',
                      value: weather != null 
                          ? _formatCoordinate(weather!.latitude, true)
                          : '--',
                      color: AppTheme.lightBlue,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      context: context,
                      icon: Icons.location_on,
                      title: 'Longitude',
                      value: weather != null 
                          ? _formatCoordinate(weather!.longitude, false)
                          : '--',
                      color: AppTheme.accentBlue,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Timezone
              _buildInfoItem(
                context: context,
                icon: Icons.access_time,
                title: 'Timezone',
                value: weather != null 
                    ? _formatTimezone(weather!.timezoneOffset)
                    : '--',
                color: AppTheme.success,
                isDark: isDark,
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
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
        ],
      ),
    );
  }
}
