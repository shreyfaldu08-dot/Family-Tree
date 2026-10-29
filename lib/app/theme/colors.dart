import 'package:flutter/material.dart';
import 'app_colors.dart';

export 'app_colors.dart';

/// Vansora Heritage Theme Bridges & System Constants
/// Maps the official Reference-Inspired tokens into shared constants.
abstract final class HeritageColors {
  // Main app background (Soft, cool, light neutral canvas #F4F5F7)
  static const Color background = AppColors.background;
  static const Color canvasSolid = AppColors.background;
  static const Color warmIvory = AppColors.background;
  static const Color warmIvoryLight = AppColors.surface;
  static const Color warmIvoryDark = AppColors.softBlueGrey;

  // Primary content surfaces & panels
  static const Color surfaceCard = AppColors.surface;
  static const Color surfaceSecondary = AppColors.softBlueGrey;
  static const Color stone = AppColors.border;
  static const Color stoneLight = AppColors.softBlueGrey;
  static const Color stoneDark = AppColors.border;
  static const Color borderSubtle = AppColors.border;

  // Typography tokens
  static const Color textPrimary = AppColors.textPrimary; // #172033
  static const Color textSecondary = AppColors.textSecondary; // #687184
  static const Color charcoal = AppColors.textPrimary;
  static const Color charcoalLight = AppColors.textPrimary;
  static const Color charcoalMuted = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted; // #9299A7

  // Navy Accents
  static const Color forestGreen = AppColors.primary; // #101D38 Primary Navy
  static const Color forestGreenLight = AppColors.secondaryNavy; // #243754
  static const Color forestGreenDark = AppColors.primary;

  // Pale Blue Surfaces & Accents
  static const Color softBlueAccent = AppColors.paleBlue; // #E7EEFC Pale Blue
  static const Color blueHighlight = AppColors.softMint;
  static const Color mutedBrass = AppColors.secondaryNavy;
  static const Color mutedBrassLight = AppColors.paleBlue;
  static const Color mutedBrassDark = AppColors.primary;
  static const Color sage = AppColors.textSecondary;
  static const Color sageLight = AppColors.paleBlue;
  static const Color sageDark = AppColors.primary;

  // Status & Validation
  static const Color statusSuccess = AppColors.statusSuccess;
  static const Color statusSuccessBackground = AppColors.softBlueGrey;
  static const Color statusSuccessLight = AppColors.paleBlue;
  static const Color statusWarning = AppColors.statusWarning;
  static const Color statusError = AppColors.statusError;
  static const Color statusInfo = AppColors.statusInfo;

  // Ambient depth
  static const Color overlayDim = Color(0x33101D38);
  static const Color subtleShadow = Color(0x0A101D38);
}

/// Restrained & Cohesive Gradients for Vansora
abstract final class HeritageGradients {
  /// Signature Deep Navy Gradient
  static const LinearGradient signature = AppColors.signatureGradient;

  /// Signature Featured Card Gradient
  static const LinearGradient heroCard = AppColors.signatureGradient;

  /// Standard content card gradient (pure white to whisper of pale blue)
  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surface,
      Color(0xFFF9FAFD),
    ],
  );

  /// Active pill / filter badge gradient
  static const LinearGradient accentPill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.secondaryNavy,
    ],
  );

  /// Track background for segment pills
  static const LinearGradient pillTrack = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.softBlueGrey,
      Color(0xFFE2E8F0),
    ],
  );

  /// Avatar circle pale blue gradient
  static const LinearGradient avatarPill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.softBlueGrey,
      AppColors.paleBlue,
    ],
  );

  /// Success badge highlight
  static const LinearGradient successBadge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.paleBlue,
      Color(0xFFD0E1FD),
    ],
  );

  /// Canvas background (solid cool light #F4F5F7)
  static const LinearGradient canvasBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      AppColors.background,
    ],
  );
}

/// Reference-Inspired Geometric Curves
/// Follows Section 11 of the Master Redesign Specification:
/// - Compact card radius: 12–16 px (14 px)
/// - Standard card radius: 16–20 px (18 px)
/// - Featured card radius: 20–26 px (24 px)
/// - Pill: 999 px
abstract final class HeritageCurves {
  /// Small controls, pills & compact badges: 14 px
  static final BorderRadius small = BorderRadius.circular(14);

  /// Standard cards & panels: 18 px
  static final BorderRadius card = BorderRadius.circular(18);

  /// Featured panels, hero cards & major dialogs: 24 px
  static final BorderRadius cardLarge = BorderRadius.circular(24);

  /// Full stadium capsule pills: 999 px
  static final BorderRadius pill = BorderRadius.circular(999);

  /// Sheet top radius: 24 px
  static const BorderRadius sheet = BorderRadius.vertical(top: Radius.circular(24));
}

/// Subtle Ambient Shadows for Clean Separation
abstract final class HeritageShadows {
  /// Subtle ambient card shadow for clean floating separation
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0811233B),
      blurRadius: 18,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Active filter or pill shadow
  static const List<BoxShadow> activePill = [
    BoxShadow(
      color: Color(0x1426538D),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  /// Navigation or floating bar shadow
  static const List<BoxShadow> pill = [
    BoxShadow(
      color: Color(0x0C11233B),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
}
