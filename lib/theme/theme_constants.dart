import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkMode, BuildContext context) {
    return ThemeData(
        appBarTheme: AppBarTheme(
          color: isDarkMode ? Colors.black : Color.fromARGB(255, 5, 65, 168),
          iconTheme: IconThemeData(
              color: isDarkMode ? Colors.blueAccent : Colors.black),
        ),
        scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
        primaryColor: Colors.black,
        colorScheme: ThemeData().colorScheme.copyWith(
              secondary: isDarkMode
                  ? const Color(0xFF1a1f3c)
                  : const Color(0xFFE8FDFD),
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
        cardColor:
            isDarkMode ? const Color(0xFF1a1f3c) : const Color(0xFFE8FDFD),
        canvasColor: isDarkMode ? Colors.black : Colors.grey[50],
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              colorScheme: isDarkMode
                  ? const ColorScheme.dark()
                  : const ColorScheme.light(),
            ));
  }
}
