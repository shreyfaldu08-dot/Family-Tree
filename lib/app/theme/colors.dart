import 'package:flutter/material.dart';

/// Royal Silk & Cashmere Glow Color Palette with Rich Ambient Light Gradients
/// - Canvas Background: Vibrant, perceptible 3-stop diagonal gradient from #F7ECE3 (warm cashmere peach)
///   through #EFE2F6 (soft royal orchid) to #DEEBFA (serene periwinkle opal)
/// - Surfaces and Cards: Pure #FFFFFF to #FAF7FD (floating with zero strokes & soft ambient shadow)
/// - Active Pill & Segment: Luminous royal iris gradient #E8D7FA to #D4BFF8
/// - Primary text: #140D20 (deep royal obsidian)
/// - Secondary text: #6A5F7A (soft velvet graphite)
/// - Curvature: Continuous stadium 999px for pills, 28px for cards
abstract final class HeritageColors {
  /// Reference Color Tokens
  static const Color background = Colors.transparent;
  static const Color canvasSolid = Color(0xFFF7ECE3);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF0E6F6);
  static const Color textPrimary = Color(0xFF140D20);
  static const Color textSecondary = Color(0xFF6A5F7A);
  static const Color softBlueAccent = Color(0xFFE8D7FA); // Soft lavender/iris accent
  static const Color blueHighlight = Color(0xFFC7B2FA); // Royal iris highlight
  static const Color borderSubtle = Color(0xFFE8DDF0);
  static const Color statusSuccessBackground = Color(0xFFDCFCE7);

  /// Primary brand action & strong elements (near-black with royal plum warmth)
  static const Color forestGreen = Color(0xFF140D20);
  static const Color forestGreenLight = Color(0xFF281E38);
  static const Color forestGreenDark = Color(0xFF0A0510);

  /// Scaffold background & surface mappings
  static const Color warmIvory = Colors.transparent;
  static const Color warmIvoryLight = Color(0xFFFFFFFF); // Primary card surface
  static const Color warmIvoryDark = Color(0xFFEFE6F6); // Secondary surface

  /// Accents, highlights, and active states
  static const Color mutedBrass = Color(0xFFC7B2FA);
  static const Color mutedBrassLight = Color(0xFFE8D7FA);
  static const Color mutedBrassDark = Color(0xFF7C3AED);

  /// Secondary surfaces, borders, and dividers
  static const Color stone = Color(0xFFE8DDF0);
  static const Color stoneLight = Color(0xFFF0E6F6);
  static const Color stoneDark = Color(0xFFD8C7E6);

  /// Primary legible copy & descriptions
  static const Color charcoal = Color(0xFF140D20);
  static const Color charcoalLight = Color(0xFF382F48);
  static const Color charcoalMuted = Color(0xFF6A5F7A);

  /// Supporting tags, connectors & badges
  static const Color sage = Color(0xFF6A5F7A);
  static const Color sageLight = Color(0xFFE8D7FA);
  static const Color sageDark = Color(0xFF382F48);

  /// Status colors
  static const Color statusSuccess = Color(0xFF15803D);
  static const Color statusSuccessLight = Color(0xFFDCFCE7);
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFE11D48);
  static const Color statusInfo = Color(0xFF7C3AED);

  /// Ambient shadows
  static const Color overlayDim = Color(0x33140D20);
  static const Color subtleShadow = Color(0x0C181126);
}

/// Premium Light Shade Gradients for Background, Cards, Pills & Buttons
abstract final class HeritageGradients {
  /// Signature Pill Gradient (stadium segmented control & active filters)
  static const LinearGradient accentPill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8D7FA),
      Color(0xFFD4BFF8),
    ],
  );

  /// Inactive stadium pill track background
  static const LinearGradient pillTrack = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF6EFF9),
    ],
  );

  /// Delicate light-shade gradient for cards (replaces flat stroke cards)
  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAF7FD),
    ],
  );

  /// Subtle hero card gradient
  static const LinearGradient heroCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAF1FD),
      Color(0xFFEDE0F9),
    ],
  );

  /// Rich, perceptible 3-stop diagonal canvas gradient for full screen backgrounds
  static const LinearGradient canvasBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7ECE3), // warm cashmere peach glow
      Color(0xFFEFE2F6), // soft royal orchid whisper
      Color(0xFFDEEBFA), // serene periwinkle opal
    ],
    stops: [0.0, 0.50, 1.0],
  );

  /// Dark high-contrast button gradient
  static const LinearGradient primaryDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF251A36),
      Color(0xFF12091E),
    ],
  );

  /// Mint success badge gradient
  static const LinearGradient successBadge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDCFCE7),
      Color(0xFFBBF7D0),
    ],
  );

  /// Avatar circle light gradient
  static const LinearGradient avatarPill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF1E4FC),
      Color(0xFFDAC6F7),
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
  /// Floating card shadow with warm ambient depth
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0E181126),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x06181126),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Floating pill bar shadow
  static const List<BoxShadow> pill = [
    BoxShadow(
      color: Color(0x12181126),
      blurRadius: 18,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Active tab accent shadow
  static const List<BoxShadow> activePill = [
    BoxShadow(
      color: Color(0x3D7C3AED),
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ];
}
