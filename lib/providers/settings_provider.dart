import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SettingsProvider extends ChangeNotifier {
  String _temperatureUnit = 'celsius';
  bool _notificationsEnabled = true;
  String _weatherDisplayMode = 'simple';

  String get temperatureUnit => _temperatureUnit;
  bool get notificationsEnabled => _notificationsEnabled;
  String get weatherDisplayMode => _weatherDisplayMode;

  // Helper getters for easier usage
  bool get isSimpleMode => _weatherDisplayMode == 'simple';
  bool get isExpertMode => _weatherDisplayMode == 'expert';

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final tempUnit =
          await DatabaseHelper.instance.getSetting('temperature_unit');
      final notifications =
          await DatabaseHelper.instance.getSetting('notifications');
      final displayMode =
          await DatabaseHelper.instance.getSetting('weather_display_mode');

      if (tempUnit != null) {
        _temperatureUnit = tempUnit;
      }
      if (notifications != null) {
        _notificationsEnabled = notifications == 'true';
      }
      if (displayMode != null) {
        _weatherDisplayMode = displayMode;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Use default values if loading fails
      _temperatureUnit = 'celsius';
      _notificationsEnabled = true;
      _weatherDisplayMode = 'simple';
      notifyListeners();
    }
  }

  Future<void> setTemperatureUnit(String unit) async {
    try {
      _temperatureUnit = unit;
      await DatabaseHelper.instance.setSetting('temperature_unit', unit);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting temperature unit: $e');
    }
  }

  Future<void> setNotifications(bool enabled) async {
    try {
      _notificationsEnabled = enabled;
      await DatabaseHelper.instance
          .setSetting('notifications', enabled.toString());
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting notifications: $e');
    }
  }

  Future<void> setWeatherDisplayMode(String mode) async {
    try {
      _weatherDisplayMode = mode;
      await DatabaseHelper.instance.setSetting('weather_display_mode', mode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting weather display mode: $e');
    }
  }
}
