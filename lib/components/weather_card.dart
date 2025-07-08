import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class WeatherCard extends StatefulWidget {
  final Weather? weather;

  const WeatherCard({super.key, this.weather});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.weather == null) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weather != null && oldWidget.weather == null) {
      _pulseController.stop();
    } else if (widget.weather == null && oldWidget.weather != null) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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

  String _formatTemperature(double temp, String unit) {
    if (unit == 'fahrenheit') {
      return '${temp.round()}°F';
    }
    return '${temp.round()}°C';
  }

  Widget _buildLoadingAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const Icon(
                  Icons.cloud,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
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
                widget.weather != null
                    ? "${widget.weather!.cityName}, ${widget.weather!.country}"
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

              // Weather Animation or Loading
              SizedBox(
                height: 150,
                child: widget.weather == null
                    ? Center(child: _buildLoadingAnimation())
                    : Lottie.asset(
                        _getWeatherAnimation(
                            widget.weather?.mainCondition ?? ''),
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(height: 20),

              // Temperature
              Text(
                widget.weather != null
                    ? _formatTemperature(widget.weather!.temprature,
                        settingsProvider.temperatureUnit)
                    : '--°C',
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
                widget.weather?.description
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
                    widget.weather?.tempMin.round().toString() ?? '--',
                    Icons.arrow_downward,
                    settingsProvider.temperatureUnit,
                  ),
                  const SizedBox(width: 40),
                  _buildTempInfo(
                    'Max',
                    widget.weather?.tempMax.round().toString() ?? '--',
                    Icons.arrow_upward,
                    settingsProvider.temperatureUnit,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTempInfo(String label, String temp, IconData icon, String unit) {
    final tempUnit = unit == 'fahrenheit' ? '°F' : '°C';

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
          '$temp$tempUnit',
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
