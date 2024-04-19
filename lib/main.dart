import 'package:flutter/material.dart';
import 'pages/weather_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 25,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: WeatherPage(),
    );
  }
}
