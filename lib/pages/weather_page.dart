import 'dart:convert';
import 'package:flutter/material.dart';
import '../service/weather_service.dart';
import '../models/weather_model.dart';
import '../constants.dart';
import 'package:lottie/lottie.dart';
import '../models/city_model.dart';
import '../service/city_data.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService(OPENWEATHERMAP_API_KEY);

  Weather? _weather;

  String _query = '';

  List<City> cities = [];
  List<City> _filteredCities = [];

  void loadData() async {
    // Create an instance of CityData
    CityData cityData = CityData();

    // Load the list of cities
    final jsonString = await cityData.loadCityData();

    final jsonData = jsonDecode(jsonString) as List<dynamic>;

    // ignore: avoid_function_literals_in_foreach_calls
    jsonData.forEach((item) {
      final city = City.fromJson(item);
      cities.add(city);
    });

    // ignore: avoid_print
    print("All cities loaded");
  }

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  _fetchWeatherByCity(int cityId) async {
    try {
      final weather = await _weatherService.getWeatherByCityID(cityId);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void search(String query) {
    setState(
      () {
        _query = query;

        _filteredCities = cities
            .where(
              (city) => city.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      },
    );
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
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: const TextStyle(color: Colors.black),
          onChanged: (value) {
            search(value);
          },
          decoration: const InputDecoration(
            labelText: 'Search City',
            fillColor: Colors.black,
            suffixIcon: Icon(
              Icons.search,
              color: Colors.purple,
            ),
          ),
        ),
      ),
      body: _query.isNotEmpty
          ? _filteredCities.isEmpty
              ? const Center(
                  child: Text(
                    'No Results Found',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredCities.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: const Border.fromBorderSide(
                          BorderSide(
                            color: Colors.purple,
                            width: 1.0,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: ListTile(
                        title: Text(
                            '${_filteredCities[index].name}, ${_filteredCities[index].country}'),
                        onTap: () => {
                          _fetchWeatherByCity(_filteredCities[index].id),
                          _query = '',
                        },
                      ),
                    );
                  },
                )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spacer
                    const SizedBox(height: 25),

                    // City Name
                    Text(
                      _weather?.cityName ?? "loading",
                    ),

                    // Spacer
                    const SizedBox(height: 10),

                    // Animation
                    Lottie.asset(
                      _getWeatherAnimation(_weather?.mainCondition ?? ''),
                    ),

                    // Spacer
                    const SizedBox(height: 10),

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
            ),
    );
  }
}
