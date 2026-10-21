import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Living Heritage Editorial Typography
/// Cormorant Garamond / Editorial Serif for prominent names and historical stories.
/// Inter for interface controls, labels, dates, and body text.
abstract final class HeritageTypography {
  // Editorial Serif for Names, Headlines & Stories
  static TextStyle get displayLarge => GoogleFonts.cormorantGaramond(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: HeritageColors.charcoal,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static TextStyle get displayMedium => GoogleFonts.cormorantGaramond(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static TextStyle get displaySmall => GoogleFonts.cormorantGaramond(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
    height: 1.25,
  );

  static TextStyle get storyHeadline => GoogleFonts.cormorantGaramond(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: HeritageColors.charcoal,
    height: 1.3,
  );

  static TextStyle get storyBody => GoogleFonts.cormorantGaramond(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: HeritageColors.charcoal,
    height: 1.6,
  );

  // Interface Sans-Serif (Inter)
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
    letterSpacing: -0.2,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
  );

  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: HeritageColors.charcoal,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: HeritageColors.charcoal,
    height: 1.45,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
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

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle get lifeDates => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: HeritageColors.charcoalMuted,
    letterSpacing: 0.3,
  );
}
