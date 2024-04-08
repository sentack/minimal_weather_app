import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  Future<String> fetchApiKey() async {
    await dotenv.load();
    String? apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'];

    return apiKey ?? "";
  }
}
