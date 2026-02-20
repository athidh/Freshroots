import 'package:flutter/material.dart';

enum WeatherState { clear, rainy, hot }

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  WeatherState _weatherState = WeatherState.clear;

  ThemeMode get themeMode => _themeMode;
  WeatherState get weatherState => _weatherState;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setWeather(WeatherState state) {
    _weatherState = state;
    notifyListeners();
  }
}
