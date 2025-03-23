# Flutter Weather App

This Flutter application provides weather information based on the user's location. It utilizes the OpenWeatherMap API to retrieve weather data and displays it in a user-friendly interface. The app incorporates the Geolocator package to fetch the current location of the user for accurate weather information.

## Features

- Current Weather: Get real-time weather updates, including temperature, humidity, wind speed, and weather conditions for the user's location.
- Animated Weather Icons: Enjoy seamless animations using the Lottie package, which brings weather icons to life.
- User-friendly Interface: The app offers an intuitive and visually appealing interface for easy navigation and a pleasant user experience.
- Search for any city worldwide to get the weather info.

## Installation

1. Clone the repository or download the source code.
2. Ensure that Flutter is installed on your machine.
3. Run `flutter pub get` in the project directory to fetch the dependencies.
4. Connect your device or emulator.
5. Run `flutter run` to launch the app on your device.

## Configuration

To configure the app with the OpenWeatherMap API:

1. Visit [openweathermap.org](https://openweathermap.org/) and create an account (if you don't have one).
2. Obtain an API key by following their documentation.
3. Open the project in your preferred code editor.
4. Navigate to the lib directory and create `constants.dart` file. and add the following:

```dart
const String OPENWEATHERMAP_API_KEY = 'YOUR_API_KEY_HERE';
const String WEATHERAPI_API_KEY = 'YOUR_API_KEY_HERE';
```

5. Replace the placeholder value for OPENWEATHERMAP_API_KEY with your actual API key.
6. Save the file.

## Dependencies

This app relies on the following packages:

- `http`: For making HTTP requests to the OpenWeatherMap API.
- `geolocator`: For retrieving the user's current location.
- `lottie`: For adding animated weather icons.
- Other Flutter dependencies (automatically fetched with `flutter pub get`).

Make sure to check the `pubspec.yaml` file for the specific versions of these packages used in the project.

## Contributing

Contributions to this Flutter Weather App are welcome! If you find any bugs or have suggestions for new features, please submit an issue or open a pull request on the GitHub repository.

## License

This project is licensed under the MIT License. Feel free to use, modify, and distribute the code for personal or commercial purposes.
