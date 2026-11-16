import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display
  static final TextStyle displayLarge = GoogleFonts.cairo(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static final TextStyle displayLargeMobile = GoogleFonts.cairo(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.27,
  );

  // Headlines
  static final TextStyle headlineLarge = GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static final TextStyle headlineLargeMobile = GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33,
  );

  static final TextStyle headlineMedium = GoogleFonts.cairo(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static final TextStyle headlineSmall = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Body
  static final TextStyle bodyLarge = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static final TextStyle bodyMedium = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static final TextStyle bodySmall = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  // Labels
  static final TextStyle labelLarge = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );

  static final TextStyle labelMedium = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static final TextStyle labelSmall = GoogleFonts.cairo(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  // Technical Labels
  static final TextStyle technicalLabel = GoogleFonts.tajawal(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
