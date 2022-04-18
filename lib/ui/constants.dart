import 'package:flutter/material.dart';

class UIConstatnts {
  static const backgroundColor = Colors.white;
  static const foregroundColor = Colors.black;
  static const accentColor = Color(0xFF418EF2);
  static const accentStrong = Color(0xFF0A4DA6);
  static const stringColor = Color(0xFF497CBF);
  static const pastorColor = Color(0xFF011140);
  static const wifeColor = Color(0xFFF2C7AE);
  static const sonColor = Color(0xFFF2EA79);

  static Color lighten(Color color, [double amount=0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
