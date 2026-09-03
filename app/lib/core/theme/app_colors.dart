import 'package:flutter/material.dart';

/// Palette de couleurs de "L'Excellent Prof" : vert foncé (savoir, sérieux,
/// couleurs du Mali) et doré (excellence, réussite), en cohérence avec un
/// logo type "toque de diplômé" (graduation cap).
class AppColors {
  AppColors._();

  static const Color primaryDarkGreen = Color(0xFF0B3D2E);
  static const Color primaryGreen = Color(0xFF14532D);
  static const Color lightGreen = Color(0xFF1E7A4C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB8860B);
  static const Color paleGold = Color(0xFFF4E7C1);

  static const Color background = Color(0xFFF7F8F6);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5C6660);

  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color info = Color(0xFF0288D1);

  // Couleurs utilisées pour représenter les statuts (chips, badges...).
  static const Color statutEnAttente = warning;
  static const Color statutActif = success;
  static const Color statutSuspendu = Color(0xFF8D6E00);
  static const Color statutDesactive = error;
  static const Color statutValidee = success;
  static const Color statutRefusee = error;
  static const Color statutSoumise = info;
  static const Color statutEntretien = warning;
}
