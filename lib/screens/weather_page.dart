import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
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
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../database/database_helper.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService(OPENWEATHERMAP_API_KEY);
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _searchFocusNode = FocusNode();

  Weather? _weather;
  String _query = '';
  List<City> cities = [];
  List<City> _filteredCities = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  String _currentUnits = 'metric';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load settings first to get temperature unit
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _currentUnits =
        settingsProvider.temperatureUnit == 'celsius' ? 'metric' : 'imperial';

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
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final units =
          settingsProvider.temperatureUnit == 'celsius' ? 'metric' : 'imperial';

      final weather = await _weatherService.getWeather(units: units);
      setState(() {
        _weather = weather;
        _currentUnits = units;
      });
      await _checkIfFavorite();
    } catch (e) {
      debugPrint('Error fetching weather: $e');

      // Handle different types of errors
      if (mounted) {
        if (e is LocationPermissionException) {
          _showLocationPermissionDialog(e.toString());
        } else if (e is LocationServiceException) {
          _showLocationServiceDialog(e.toString());
        } else if (e is LocationTimeoutException) {
          _showLocationTimeoutDialog(e.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to get current location weather: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _fetchWeather,
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _fetchWeatherByCity(int cityId) async {
    // Dismiss keyboard
    _searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final units =
          settingsProvider.temperatureUnit == 'celsius' ? 'metric' : 'imperial';

      final weather =
          await _weatherService.getWeatherByCityID(cityId, units: units);
      setState(() {
        _weather = weather;
        _query = '';
        _searchController.clear();
        _currentUnits = units;
      });

      // Add to search history
      await DatabaseHelper.instance.addSearchHistory(
        weather.cityName,
        weather.country,
        cityId,
      );

      await _checkIfFavorite();
    } catch (e) {
      debugPrint('Error fetching weather by city: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load weather data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    if (_weather != null) {
      final cityId = cities
          .where((city) =>
              city.name.toLowerCase() == _weather!.cityName.toLowerCase() &&
              city.country.toLowerCase() == _weather!.country.toLowerCase())
          .firstOrNull
          ?.id;

      if (cityId != null) {
        final isFav = await DatabaseHelper.instance.isFavoriteCity(cityId);
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_weather == null) return;

    final city = cities
        .where((city) =>
            city.name.toLowerCase() == _weather!.cityName.toLowerCase() &&
            city.country.toLowerCase() == _weather!.country.toLowerCase())
        .firstOrNull;

    if (city != null) {
      if (_isFavorite) {
        await DatabaseHelper.instance.removeFavoriteCity(city.id);
      } else {
        await DatabaseHelper.instance.addFavoriteCity(city);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _query = query;
      _filteredCities = cities
          .where(
              (city) => city.name.toLowerCase().contains(query.toLowerCase()))
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
    _searchFocusNode.unfocus();
  }

  // Method to refresh weather data when temperature unit changes
  Future<void> _refreshWeatherData() async {
    if (_weather != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        final units = settingsProvider.temperatureUnit == 'celsius'
            ? 'metric'
            : 'imperial';

        // Check if we need to refresh the data
        if (_currentUnits != units) {
          // Find the city ID for current weather
          final cityId = cities
              .where((city) =>
                  city.name.toLowerCase() == _weather!.cityName.toLowerCase() &&
                  city.country.toLowerCase() == _weather!.country.toLowerCase())
              .firstOrNull
              ?.id;

          if (cityId != null) {
            // Refresh with city ID
            final weather =
                await _weatherService.getWeatherByCityID(cityId, units: units);
            setState(() {
              _weather = weather;
              _currentUnits = units;
            });
          } else {
            // Refresh with current location
            final weather = await _weatherService.getWeather(units: units);
            setState(() {
              _weather = weather;
              _currentUnits = units;
            });
          }
        }
      } catch (e) {
        debugPrint('Error refreshing weather data: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showLocationPermissionDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Location Permission'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text(
                'Weather Pro needs location access to provide current weather information for your area.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchWeather(); // Try again, which will request permission
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Permission'),
            ),
            if (message.contains('permanently'))
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Open Settings'),
              ),
          ],
        );
      },
    );
  }

  void _showLocationServiceDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.location_disabled,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Location Services'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text(
                'Please enable location services in your device settings to get current weather information.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchWeather(); // Try again after user potentially enables location
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationTimeoutDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.amber,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Location Timeout'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text(
                'Tips to improve location accuracy:\n• Make sure you\'re not indoors\n• Check if location services are enabled\n• Try moving to an area with better GPS signal',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchWeather(); // Try again
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Location Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Could not open app settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open app settings. Please manually enable location permission in your device settings.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Handle current location button press with permission request
  Future<void> _handleCurrentLocationPress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _fetchWeather();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final gradientColors =
            isDark ? AppTheme.getDarkGradient() : AppTheme.getLightGradient();

        // Check if temperature unit changed and refresh data
        final newUnits = settingsProvider.temperatureUnit == 'celsius'
            ? 'metric'
            : 'imperial';
        if (_currentUnits != newUnits && _weather != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshWeatherData();
          });
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(),
          body: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside
              _searchFocusNode.unfocus();
              FocusScope.of(context).unfocus();
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    _buildSearchBar(),
                    Expanded(
                      child: _query.isNotEmpty
                          ? _buildSearchResults()
                          : _buildWeatherContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: _handleCurrentLocationPress,
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
        focusNode: _searchFocusNode,
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
        color: Theme.of(context).cardColor,
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
    _searchFocusNode.dispose();
    super.dispose();
  }
}
