import 'package:flutter/material.dart';

/// Official Vansora Light Theme Design Tokens
/// Based on the Vansora Master Light Theme Color Specification
abstract final class AppColors {
  // --- Primary Brand Colors ---
  /// Primary Green (#76A982) - Primary buttons, active navigation & important actions
  static const Color primary = Color(0xFF76A982);

  /// Fresh Green (#9BC5A0) - Secondary actions, supporting icons & decorative emphasis
  static const Color secondary = Color(0xFF9BC5A0);

  /// Soft Mint (#C7E2C9) - Selected tree nodes, selected controls & soft highlights
  static const Color softMint = Color(0xFFC7E2C9);

  /// Pale Sage (#E0EDE0) - Selected tabs, active filters & highlighted surfaces
  static const Color paleSage = Color(0xFFE0EDE0);

  /// Light Sage (#EDF4EA) - Secondary cards, grouped content & subtle panels
  static const Color lightSage = Color(0xFFEDF4EA);

  // --- Background and Neutral Colors ---
  /// Warm White (#F8F8F3) - Main app background (soft & natural, never stark)
  static const Color background = Color(0xFFF8F8F3);

  /// Pure White (#FFFFFF) - Cards, forms, dialogs & bottom sheets
  static const Color surface = Color(0xFFFFFFFF);

  /// Soft Border (#DCE7DA) - Card borders, dividers, input borders & subtle outlines
  static const Color border = Color(0xFFDCE7DA);

  // --- Typography Colors ---
  /// Soft Charcoal (#536158) - Headings, body text, important labels & readable content
  static const Color textPrimary = Color(0xFF536158);

  /// Muted Green Text (#718777) - Secondary labels, captions, dates & metadata
  static const Color textSecondary = Color(0xFF718777);

  // --- Semantic & Status Colors ---
  static const Color statusSuccess = Color(0xFF76A982);
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFDC2626);
  static const Color statusInfo = Color(0xFF536158);

  // --- Family Tree Specific Tokens ---
  static const Color treeCanvasBackground = Color(0xFFF8F8F3);
  static const Color treeNormalLine = Color(0xFFDCE7DA);
  static const Color treeEmphasizedLine = Color(0xFF9BC5A0);
  static const Color treeSelectedPath = Color(0xFF76A982);
  static const Color treeUnverifiedLine = Color(0xFFDCE7DA);

  static const Color treeNodeNormalBackground = Color(0xFFFFFFFF);
  static const Color treeNodeNormalBorder = Color(0xFFDCE7DA);
  static const Color treeNodeSelectedBackground = Color(0xFFC7E2C9);
  static const Color treeNodeSelectedBorder = Color(0xFF76A982);
  static const Color treeNodeAncestorBackground = Color(0xFFEDF4EA);
  static const Color treeNodeAncestorBorder = Color(0xFFDCE7DA);
  static const Color treeCollapsedIndicator = Color(0xFFE0EDE0);

  // --- Signature Green Gradient Tokens ---
  static const Color gradientStart = Color(0xFFDDEEDD);
  static const Color gradientMiddle = Color(0xFFBFE0C3);
  static const Color gradientEnd = Color(0xFF9BC5A0);

  /// Signature Vansora 110° Linear Gradient
  static const LinearGradient signatureGradient = LinearGradient(
    begin: Alignment(-0.8, -0.6),
    end: Alignment(0.8, 0.6),
    colors: [
      gradientStart,
      gradientMiddle,
      gradientEnd,
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
