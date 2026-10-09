import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  scaffoldBackgroundColor: const Color.fromARGB(255, 31, 31, 31),
  dividerTheme: const DividerThemeData(color: Colors.white24),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 31, 31, 31),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  listTileTheme: const ListTileThemeData(iconColor: Colors.white),
  // colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    labelSmall: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontWeight: FontWeight.w700,
      fontSize: 14,
    ),
  ),
  colorScheme: const ColorScheme.light(primary: Colors.yellow),
);
