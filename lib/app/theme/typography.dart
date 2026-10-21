import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Living Heritage Curvy Mobile Typography
/// Headings, Display, and Titles: Poppins (Clean, geometric, perfectly rounded letterforms)
/// Body, Labels, Dates, and Controls: Inter (High legibility, optical micro-tracking)
abstract final class HeritageTypography {
  // Display & Headlines (Poppins)
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: HeritageColors.charcoal,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: HeritageColors.charcoal,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get storyHeadline => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static TextStyle get storyBody => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: HeritageColors.charcoal,
    height: 1.55,
  );

  // Interface Titles (Poppins)
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
    letterSpacing: -0.3,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
    letterSpacing: -0.2,
  );

  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
    letterSpacing: -0.1,
  );

  // Body & Copy (Inter)
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: HeritageColors.charcoal,
    height: 1.45,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: HeritageColors.charcoal,
    height: 1.4,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: HeritageColors.charcoalMuted,
    height: 1.35,
  );

  // Labels & Capsule Controls (Poppins & Inter)
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static TextStyle get lifeDates => GoogleFonts.inter(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: HeritageColors.charcoalMuted,
    letterSpacing: 0.1,
  );
}
