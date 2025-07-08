import 'dart:convert';
import 'package:flutter/material.dart';
import '../service/weather_service.dart';
import '../models/weather_model.dart';
import '../constants.dart';
import '../models/city_model.dart';
import '../service/city_data.dart';
import '../components/weather_card.dart';
import '../components/search_bar_widget.dart';
import '../components/city_list_item.dart';
import '../components/app_drawer.dart';
import '../components/weather_details_card.dart';
import '../theme/app_theme.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService(OPENWEATHERMAP_API_KEY);
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Weather? _weather;
  String _query = '';
  List<City> cities = [];
  List<City> _filteredCities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      _fetchWeather(),
      _loadCityData(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCityData() async {
    try {
      CityData cityData = CityData();
      final jsonString = await cityData.loadCityData();
      final jsonData = jsonDecode(jsonString) as List<dynamic>;

      for (var item in jsonData) {
        final city = City.fromJson(item);
        cities.add(city);
      }
    } catch (e) {
      debugPrint('Error loading city data: $e');
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather();
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    }
  }

  Future<void> _fetchWeatherByCity(int cityId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final weather = await _weatherService.getWeatherByCityID(cityId);
      setState(() {
        _weather = weather;
        _query = '';
        _searchController.clear();
      });
    } catch (e) {
      debugPrint('Error fetching weather by city: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _query = query;
      _filteredCities = cities
          .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
          .take(10)
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _query = '';
      _searchController.clear();
      _filteredCities.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.lightBlue,
              AppTheme.accentBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              Expanded(
                child: _query.isNotEmpty ? _buildSearchResults() : _buildWeatherContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          ),
          const Expanded(
            child: Text(
              'Weather Pro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          IconButton(
            onPressed: _fetchWeather,
            icon: const Icon(Icons.my_location, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SearchBarWidget(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onClear: _clearSearch,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredCities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No cities found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredCities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return CityListItem(
            city: _filteredCities[index],
            onTap: () => _fetchWeatherByCity(_filteredCities[index].id),
          );
        },
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading weather data...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          WeatherCard(weather: _weather),
          const SizedBox(height: 20),
          WeatherDetailsCard(weather: _weather),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
