import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Uses Google Fonts package to define the typography system

  static TextStyle get display => GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 28,
      );

  static TextStyle get heading => GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // SemiBold
        fontSize: 20,
      );

  static TextStyle get subHead => GoogleFonts.poppins(
        fontWeight: FontWeight.w500, // Medium
        fontSize: 16,
      );

  static TextStyle get body => GoogleFonts.roboto(
        fontWeight: FontWeight.w400, // Regular
        fontSize: 14,
      );

  static TextStyle get caption => GoogleFonts.roboto(
        fontWeight: FontWeight.w400, // Regular
        fontSize: 12,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // SemiBold
        fontSize: 14,
        letterSpacing: 0.5,
      );
}
