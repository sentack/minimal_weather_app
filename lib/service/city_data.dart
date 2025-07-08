import 'package:flutter/services.dart' show rootBundle;

class CityData {
  Future<String> loadCityData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/city.list.json');
      return jsonString;
    } catch (e) {
      throw Exception('Failed to load city data: $e');
    }
  }
}
