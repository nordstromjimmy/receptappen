import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────
  static const Color background = Color(0xFFFBF8F3); // warm off-white
  static const Color surface = Color(0xFFEDE8E0); // muted beige
  static const Color cardBackground = Colors.white;

  // ── Brand ────────────────────────────────────────────────
  static const Color primary = Color(0xFFC4581A); // rust orange
  static const Color primaryLight = Color(0xFFE8AA6A); // warm apricot

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2C1A0E); // dark espresso
  static const Color textSecondary = Color(0xFF8B6A50); // muted brown
  static const Color textMuted = Color(0xFFB89A82); // soft hint

  // ── Borders ──────────────────────────────────────────────
  static const Color border = Color(0xFFE8E0D5);

  // ── Category image placeholder colors ────────────────────
  static const Color imgBaking = Color(0xFFD4956B); // chocolate
  static const Color imgEveryday = Color(0xFFE8C97A); // pasta yellow
  static const Color imgVegetarian = Color(0xFF9FC97A); // fresh green
  static const Color imgSoup = Color(0xFFB5C98A); // soft green
  static const Color imgDessert = Color(0xFFE8A0A0); // blush pink
  static const Color imgBreakfast = Color(0xFFE8AA6A); // warm orange

  // ── Dark mode equivalents ─────────────────────────────────
  static const Color backgroundDark = Color(0xFF1A1410);
  static const Color surfaceDark = Color(0xFF2A221A);
  static const Color cardDark = Color(0xFF231C16);
  static const Color borderDark = Color(0xFF3A2E24);
}
