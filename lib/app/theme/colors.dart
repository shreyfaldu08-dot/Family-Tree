import 'package:flutter/material.dart';

/// Soft iOS-inspired Color Palette
/// Strict adherence to the reference:
/// - Background: #F3F5F8
/// - Primary surfaces and cards: #FFFFFF
/// - Secondary surfaces: #E9EDF2
/// - Primary text and strong elements: #08090C
/// - Secondary text: #667085
/// - Soft blue accent: #D9E8FF
/// - Blue highlight: #A9CBFF
/// - Subtle borders and dividers: #E3E7ED
/// - Success states: #BFE8D0
abstract final class HeritageColors {
  /// Reference Color Tokens
  static const Color background = Color(0xFFF3F5F8);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFE9EDF2);
  static const Color textPrimary = Color(0xFF08090C);
  static const Color textSecondary = Color(0xFF667085);
  static const Color softBlueAccent = Color(0xFFD9E8FF);
  static const Color blueHighlight = Color(0xFFA9CBFF);
  static const Color borderSubtle = Color(0xFFE3E7ED);
  static const Color statusSuccessBackground = Color(0xFFBFE8D0);

  /// Primary brand action & strong elements (near-black)
  static const Color forestGreen = Color(0xFF08090C);
  static const Color forestGreenLight = Color(0xFF1E222B);
  static const Color forestGreenDark = Color(0xFF000000);

  /// Scaffold background & surface mappings
  static const Color warmIvory = Color(0xFFF3F5F8); // Primary soft off-white canvas
  static const Color warmIvoryLight = Color(0xFFFFFFFF); // Primary surfaces and cards
  static const Color warmIvoryDark = Color(0xFFE9EDF2); // Secondary surfaces

  /// Accents, highlights, and active states
  static const Color mutedBrass = Color(0xFFA9CBFF); // Blue highlight
  static const Color mutedBrassLight = Color(0xFFD9E8FF); // Soft blue accent
  static const Color mutedBrassDark = Color(0xFF3B82F6); // High-contrast blue accent

  /// Secondary surfaces, borders, and dividers
  static const Color stone = Color(0xFFE3E7ED); // Subtle borders and dividers
  static const Color stoneLight = Color(0xFFE9EDF2); // Secondary surfaces
  static const Color stoneDark = Color(0xFFD5DCE5); // Slightly stronger border / inactive

  /// Primary legible copy & descriptions
  static const Color charcoal = Color(0xFF08090C); // Headings & primary copy
  static const Color charcoalLight = Color(0xFF344054); // Intermediate copy
  static const Color charcoalMuted = Color(0xFF667085); // Secondary copy

  /// Supporting tags, connectors & badges
  static const Color sage = Color(0xFF667085); // Secondary icon & label color
  static const Color sageLight = Color(0xFFD9E8FF); // Soft blue badge surface
  static const Color sageDark = Color(0xFF344054);

  /// Status colors
  static const Color statusSuccess = Color(0xFF1B6B40); // Readable dark green on mint
  static const Color statusSuccessLight = Color(0xFFBFE8D0); // Success state background
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFD92D20);
  static const Color statusInfo = Color(0xFF2563EB);

  /// Minimal soft iOS-inspired overlays and shadows
  static const Color overlayDim = Color(0x3308090C);
  static const Color subtleShadow = Color(0x0A08090C); // Restrained 4% shadow
}
