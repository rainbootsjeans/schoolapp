import 'package:flutter/material.dart';

class LightColors {
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color white2 = Color.fromARGB(255, 241, 240, 240); // background
  static const Color black = Color.fromARGB(255, 39, 39, 39);
}

class DarkColors {
  static const Color white = Color.fromARGB(255, 54, 53, 53);
  static const Color white2 = Color.fromARGB(255, 31, 30, 30); // background
  static const Color black = Color.fromARGB(255, 255, 255, 255);
}

class CommonColors {
  static const Color green = Color(0xFF529350);
}

final ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: CommonColors.green,
  onPrimary: LightColors.white2,
  secondary: Colors.amber,
  onSecondary: LightColors.black,
  error: Colors.red,
  onError: LightColors.white,
  surface: LightColors.white,
  onSurface: LightColors.black,
);

ThemeData lightTheme = ThemeData(
  fontFamily: 'GmarketSans',
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: LightColors.white2,

  appBarTheme: const AppBarTheme(
    backgroundColor: LightColors.white2,
    titleTextStyle: TextStyle(
      color: LightColors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),

  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: LightColors.black,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
  ),

  iconTheme: const IconThemeData(color: CommonColors.green),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: LightColors.white,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: LightColors.white,
  ),
);

final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: CommonColors.green,
  onPrimary: DarkColors.white2,
  secondary: Colors.amber,
  onSecondary: DarkColors.black,
  error: Colors.red,
  onError: DarkColors.white,
  surface: DarkColors.white,
  onSurface: DarkColors.black,
);

ThemeData darkTheme = ThemeData(
  fontFamily: 'GmarketSans',
  colorScheme: darkColorScheme,
  scaffoldBackgroundColor: DarkColors.white2,

  appBarTheme: const AppBarTheme(
    backgroundColor: DarkColors.white2,
    titleTextStyle: TextStyle(
      color: DarkColors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: DarkColors.black,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
  ),

  iconTheme: const IconThemeData(color: CommonColors.green),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: DarkColors.white,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: DarkColors.white,
  ),
);
