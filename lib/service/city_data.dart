import 'package:flutter/services.dart' show rootBundle;

class CityData {
  Future<String> loadCityData() async {
    final jsonString = await rootBundle.loadString('assets/city.list.json');

    return jsonString;
  }
}
