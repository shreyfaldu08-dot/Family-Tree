import 'package:flutter/material.dart';

/// Soft iOS-inspired Color Palette with Light Shade Gradients & Curvy Design
/// - Canvas Background: #F3F5F8 to #EBEEF4
/// - Primary surfaces and cards: #FFFFFF to #F8FAFD (Light gradient, no strokes)
/// - Active Pill & Segment: Light shade blue gradient #E2EDFD to #C7DEFD
/// - Primary text: #08090C
/// - Secondary text: #667085
/// - Stadium & Capsule radii: 999px for pills, 28px for cards
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
  static const Color stone = Color(0xFFE3E7ED);
  static const Color stoneLight = Color(0xFFE9EDF2);
  static const Color stoneDark = Color(0xFFD5DCE5);

  /// Primary legible copy & descriptions
  static const Color charcoal = Color(0xFF08090C);
  static const Color charcoalLight = Color(0xFF344054);
  static const Color charcoalMuted = Color(0xFF667085);

  /// Supporting tags, connectors & badges
  static const Color sage = Color(0xFF667085);
  static const Color sageLight = Color(0xFFD9E8FF);
  static const Color sageDark = Color(0xFF344054);

  /// Status colors
  static const Color statusSuccess = Color(0xFF1B6B40);
  static const Color statusSuccessLight = Color(0xFFBFE8D0);
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFD92D20);
  static const Color statusInfo = Color(0xFF2563EB);

  /// Ambient shadows
  static const Color overlayDim = Color(0x3308090C);
  static const Color subtleShadow = Color(0x0A0E1B2E);
}

/// Premium Light Shade Gradients for Cards, Pills & Buttons
abstract final class HeritageGradients {
  /// Signature Pill Gradient (matches user reference for selected tabs / buttons)
  static const LinearGradient accentPill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE2EDFD),
      Color(0xFFC7DEFD),
    ],
  );

  /// Inactive stadium pill track background
  static const LinearGradient pillTrack = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF4F7FB),
    ],
  );

  /// Delicate light-shade gradient for cards (replaces flat stroke cards)
  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF7FAFD),
    ],
  );

  /// Subtle hero card gradient
  static const LinearGradient heroCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF2F6FE),
      Color(0xFFE5EEFC),
    ],
  );

  /// Scaffold subtle ambient canvas gradient
  static const LinearGradient canvasBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF5F7FA),
      Color(0xFFECF0F6),
    ],
  );

  /// Dark high-contrast button gradient
  static const LinearGradient primaryDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF202632),
      Color(0xFF08090C),
    ],
  );

  /// Mint success badge gradient
  static const LinearGradient successBadge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD8F6E6),
      Color(0xFFBFEBD1),
    ],
  );

  /// Avatar circle light gradient
  static const LinearGradient avatarPill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE9F1FC),
      Color(0xFFD8E6FA),
    ],
  );
}

/// Curvature Tokens: organic, ultra-curvy capsule design
abstract final class HeritageCurves {
  /// Stadium / capsule pill (for tabs, chips, buttons, badges)
  static final BorderRadius pill = BorderRadius.circular(999);

  /// Curvy card radius
  static final BorderRadius card = BorderRadius.circular(28);

  /// Large modal / hero card radius
  static final BorderRadius cardLarge = BorderRadius.circular(34);

  /// Sheet top radius
  static const BorderRadius sheet = BorderRadius.vertical(top: Radius.circular(36));
}

/// Ambient drop shadows without harsh strokes
abstract final class HeritageShadows {
  /// Floating card shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0C0E1B2E),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x050E1B2E),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Floating pill bar shadow
  static const List<BoxShadow> pill = [
    BoxShadow(
      color: Color(0x100E1B2E),
      blurRadius: 18,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Active tab accent shadow
  static const List<BoxShadow> activePill = [
    BoxShadow(
      color: Color(0x222563EB),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];
}
