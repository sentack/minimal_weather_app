import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SettingsProvider extends ChangeNotifier {
  String _temperatureUnit = 'celsius';
  bool _notificationsEnabled = true;

  String get temperatureUnit => _temperatureUnit;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final tempUnit = await DatabaseHelper.instance.getSetting('temperature_unit');
    final notifications = await DatabaseHelper.instance.getSetting('notifications');

    if (tempUnit != null) {
      _temperatureUnit = tempUnit;
    }
    if (notifications != null) {
      _notificationsEnabled = notifications == 'true';
    }
    notifyListeners();
  }

  Future<void> setTemperatureUnit(String unit) async {
    _temperatureUnit = unit;
    await DatabaseHelper.instance.setSetting('temperature_unit', unit);
    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await DatabaseHelper.instance.setSetting('notifications', enabled.toString());
    notifyListeners();
  }
}
