import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Pocket {
  static const bg = Color(0xFF071428);
  static const surface = Color(0xFF0C1C3A);
  static const card = Color(0xFF10244A);
  static const royal = Color(0xFF1A3DDB);
  static const sky = Color(0xFF5B9BFF);
  static const mid = Color(0xFF2B5FE8);
  static const text = Color(0xFFF4F7FF);
  static const muted = Color(0xFF8AA0C8);
  static const stroke = Color(0xFF1C3A6E);
}

ThemeData pocketTheme() {
  final base = ThemeData.dark();
  final text = GoogleFonts.manropeTextTheme(base.textTheme).apply(
    bodyColor: Pocket.text,
    displayColor: Pocket.text,
  );
  return base.copyWith(
    scaffoldBackgroundColor: Pocket.bg,
    colorScheme: const ColorScheme.dark(
      primary: Pocket.sky,
      secondary: Pocket.royal,
      surface: Pocket.surface,
    ),
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: Pocket.bg,
      elevation: 0,
      foregroundColor: Pocket.text,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Pocket.text,
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Pocket.sky,
      thumbColor: Pocket.sky,
      inactiveTrackColor: Pocket.stroke,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Pocket.royal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Pocket.surface,
      indicatorColor: Pocket.royal,
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: Pocket.sky)),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: Pocket.text, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    ),
  );
}
