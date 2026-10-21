import 'package:flutter/material.dart';

/// Living Heritage Color Palette
/// Strict palette tailored for long-term historical preservation.
abstract final class HeritageColors {
  /// Forest green: Primary brand action, deep accents, authoritative identity
  static const Color forestGreen = Color(0xFF203D32);
  static const Color forestGreenLight = Color(0xFF2D5344);
  static const Color forestGreenDark = Color(0xFF142720);

  /// Warm ivory: Primary application background, tactile archival surface
  static const Color warmIvory = Color(0xFFF5F0E6);
  static const Color warmIvoryLight = Color(0xFFFAF7F2);
  static const Color warmIvoryDark = Color(0xFFEBE3D3);

  /// Muted brass: Subtle highlights, selected states, lineage branch badges
  static const Color mutedBrass = Color(0xFFB18A54);
  static const Color mutedBrassLight = Color(0xFFC7A26E);
  static const Color mutedBrassDark = Color(0xFF8F6D3C);

  /// Stone: Secondary surfaces, subtle borders, card backgrounds
  static const Color stone = Color(0xFFE7E0D4);
  static const Color stoneLight = Color(0xFFEFE9E0);
  static const Color stoneDark = Color(0xFFD3CABE);

  /// Charcoal: Primary legible text, high-contrast historical copy
  static const Color charcoal = Color(0xFF292C27);
  static const Color charcoalLight = Color(0xFF42473F);
  static const Color charcoalMuted = Color(0xFF6B7268);

  /// Sage: Supporting tags, verified badges, subtle tree branch connectors
  static const Color sage = Color(0xFF6D786B);
  static const Color sageLight = Color(0xFF8B9689);
  static const Color sageDark = Color(0xFF4F584D);

  /// Status colors
  static const Color statusSuccess = Color(0xFF386B52);
  static const Color statusWarning = Color(0xFFB8782B);
  static const Color statusError = Color(0xFF9E3A3A);
  static const Color statusInfo = Color(0xFF4A6B82);

  /// Overlay & shadow colors
  static const Color overlayDim = Color(0x66292C27);
  static const Color subtleShadow = Color(0x14203D32);
}
