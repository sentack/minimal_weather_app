import 'package:flutter/material.dart';
import '../service/weather_service.dart';
import '../models/weather_model.dart';
import '../constants.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService(OPENWEATHERMAP_API_KEY);

  Weather? _weather;

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  // Weather Animation
  String _getWeatherAnimation(String mainCondition) {
    if (mainCondition == '') return 'assets/loading.json';

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
        return 'assets/loading.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer
            SizedBox(height: 75),
            // Search Box
            Container(
              width: 300,
              height: 50,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: TextField(
                  onChanged: (value) {
                    _weatherService.getWeather(value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),

            // Spacer
            SizedBox(height: 75),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // City Name
                  Text(
                    _weather?.cityName ?? "loading",
                  ),

                  // Spacer
                  SizedBox(height: 10),

                  // Animation
                  Lottie.asset(
                    _getWeatherAnimation(_weather?.mainCondition ?? ''),
                  ),

                  // Spacer
                  SizedBox(height: 10),

                  // Temprature
                  Text(
                    '${_weather?.temprature.round() ?? '0'} °C',
                  ),

                  //Condition
                  Text(
                    _weather?.description.toUpperCase() ?? '',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
