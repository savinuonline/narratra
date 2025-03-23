import 'package:flutter/material.dart';

class MyTheme{
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xff171725),
    primaryColor: Colors.white,
    colorScheme: const ColorScheme.dark(),
    iconTheme: const IconThemeData(color: Colors.white,opacity: 0.8),

  );

   static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xff171725),
    colorScheme: const ColorScheme.light(),
    iconTheme: const IconThemeData(color: Color(0xff171725),opacity: 0.8),
    
  );
}

extension ThemeExtensions on ThemeData {
  Color get chevronColor => brightness == Brightness.dark ? Colors.white : const Color(0xff171725);
}