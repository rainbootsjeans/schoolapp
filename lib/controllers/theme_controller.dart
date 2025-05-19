import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late bool isLightTheme;
late ThemeMode themeMode;

Future<void> initTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final String? savedThemeMode = prefs.getString('themeMode');

  if (savedThemeMode == null) {
    themeMode = ThemeMode.system;
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isLightTheme = brightness == Brightness.light;
  } else if (savedThemeMode == "light") {
    themeMode = ThemeMode.light;
    isLightTheme = true;
  } else if (savedThemeMode == "dark") {
    themeMode = ThemeMode.dark;
    isLightTheme = false;
  }
}

void saveTheme() async {
  final prefs = await SharedPreferences.getInstance();
  if (isLightTheme) {
    prefs.setString('themeMode', 'light');
  } else {
    prefs.setString('themeMode', 'dark');
  }
}
