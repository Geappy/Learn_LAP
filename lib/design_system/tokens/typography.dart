import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Roboto'; // change if you use a custom font

  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white   // ✅ light text for dark mode
        : Typography.material2021().black;  // ✅ dark text for light mode

    return base.merge(
      const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    ).apply(fontFamily: fontFamily);
  }
}
