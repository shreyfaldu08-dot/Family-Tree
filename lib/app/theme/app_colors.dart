import 'package:flutter/material.dart';

/// Official Vansora Minimal & Premium Design Tokens
/// Refined implementation of Dusk Blue (#26538D) and Azure Mist (#F0FFFF / #F7FAFB):
/// - Primary Accent: Dusk Blue (#26538D, RGB: 38, 83, 141)
/// - Canvas: Serene Azure Mist Canvas (#F7FAFB)
/// - Surfaces: Pristine White (#FFFFFF) with ultra-thin hairline borders (#E1EFF2)
/// - Accents & Chips: Soft Azure Mist tint (#EAF5F7)
/// - Typography: Deep Dusk Slate (#11233B) and Refined Slate (#56718E)
abstract final class AppColors {
  // --- Canvas and Surface Colors ---
  /// Azure Mist Canvas (#F7FAFB) - Ultra-serene, clean, modern gallery background
  static const Color background = Color(0xFFF7FAFB);

  /// Primary card surface (#FFFFFF) - Pure white clean cards
  static const Color surface = Color(0xFFFFFFFF);

  /// Soft Azure Mist tint (#EAF5F7) - Subtle chips, metric highlights, gentle active fills
  static const Color paleBlue = Color(0xFFEAF5F7);
  static const Color paleSage = Color(0xFFEAF5F7);
  static const Color softMint = Color(0xFFDFF0F3);

  /// Secondary soft surface (#F1F8FA)
  static const Color softBlueGrey = Color(0xFFF1F8FA);
  static const Color lightSage = Color(0xFFF1F8FA);

  // --- High-Emphasis Dusk Blue Accents ---
  /// Primary Dusk Blue (#26538D) - Refined brand accent, CTA buttons, active tabs
  static const Color primary = Color(0xFF26538D);

  /// Deep Dusk Blue (#1C3F6D) - Selected states, dark nuances
  static const Color secondaryNavy = Color(0xFF1C3F6D);
  static const Color secondary = Color(0xFF1C3F6D);

  // --- Borders and Dividers ---
  /// Hairline subtle border (#E1EFF2) - Crisp, minimal separation
  static const Color border = Color(0xFFE1EFF2);
  static const Color borderSubtle = Color(0xFFEDF6F8);

  // --- Typography Colors ---
  /// Primary text (#11233B) - Deep dusk slate, optimal contrast and elegance
  static const Color textPrimary = Color(0xFF11233B);

  /// Secondary text (#56718E) - Balanced slate for descriptions & metadata
  static const Color textSecondary = Color(0xFF56718E);

  /// Muted labels (#8FA7BF) - Captions, tags, timestamps
  static const Color textMuted = Color(0xFF8FA7BF);

  /// Text on dark (#FFFFFF)
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Secondary text on dark (#D5E5F5)
  static const Color textOnDarkSecondary = Color(0xFFD5E5F5);

  // --- Semantic & Status Colors ---
  static const Color statusSuccess = Color(0xFF1B8A5A);
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFDC2626);
  static const Color statusInfo = Color(0xFF26538D);

  // --- Family Tree Specific Tokens ---
  static const Color treeCanvasBackground = Color(0xFFF7FAFB);
  static const Color treeNormalLine = Color(0xFFD8EBF0);
  static const Color treeEmphasizedLine = Color(0xFF26538D);
  static const Color treeSelectedPath = Color(0xFF26538D);
  static const Color treeUnverifiedLine = Color(0xFFE5F2F5);

  static const Color treeNodeNormalBackground = Color(0xFFFFFFFF);
  static const Color treeNodeNormalBorder = Color(0xFFE1EFF2);
  static const Color treeNodeSelectedBackground = Color(0xFFEAF5F7);
  static const Color treeNodeSelectedBorder = Color(0xFF26538D);
  static const Color treeNodeAncestorBackground = Color(0xFFF1F8FA);
  static const Color treeNodeAncestorBorder = Color(0xFFE1EFF2);
  static const Color treeCollapsedIndicator = Color(0xFFEAF5F7);

  // --- Gradients ---
  static const LinearGradient signatureGradient = LinearGradient(
    begin: Alignment(-0.8, -0.6),
    end: Alignment(0.8, 0.6),
    colors: [
      Color(0xFF26538D), // Dusk Blue
      Color(0xFF1F487B),
      Color(0xFF173861),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient paleBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFEAF5F7),
    ],
  );
}
