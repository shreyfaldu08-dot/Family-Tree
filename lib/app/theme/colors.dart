import 'package:flutter/material.dart';
import 'app_colors.dart';

export 'app_colors.dart';

/// Vansora Theme Bridges & System Constants
/// Maps the official Vansora Master Light Theme tokens into shared constants.
abstract final class HeritageColors {
  // Main app background (Warm White #F8F8F3)
  static const Color background = AppColors.background;
  static const Color canvasSolid = AppColors.background;
  static const Color warmIvory = AppColors.background;
  static const Color warmIvoryLight = AppColors.surface;
  static const Color warmIvoryDark = AppColors.lightSage;

  // Primary content surfaces & panels
  static const Color surfaceCard = AppColors.surface;
  static const Color surfaceSecondary = AppColors.lightSage;
  static const Color stone = AppColors.border;
  static const Color stoneLight = AppColors.lightSage;
  static const Color stoneDark = AppColors.border;
  static const Color borderSubtle = AppColors.border;

  // Typography tokens
  static const Color textPrimary = AppColors.textPrimary; // #536158 Soft Charcoal
  static const Color textSecondary = AppColors.textSecondary; // #718777 Muted Green
  static const Color charcoal = AppColors.textPrimary;
  static const Color charcoalLight = AppColors.textPrimary;
  static const Color charcoalMuted = AppColors.textSecondary;

  // Brand Greens
  static const Color forestGreen = AppColors.primary; // #76A982 Primary Green
  static const Color forestGreenLight = AppColors.secondary; // #9BC5A0 Fresh Green
  static const Color forestGreenDark = AppColors.primary;

  // Soft Accents & Highlights
  static const Color softBlueAccent = AppColors.paleSage; // #E0EDE0 Pale Sage
  static const Color blueHighlight = AppColors.softMint; // #C7E2C9 Soft Mint
  static const Color mutedBrass = AppColors.secondary;
  static const Color mutedBrassLight = AppColors.paleSage;
  static const Color mutedBrassDark = AppColors.primary;
  static const Color sage = AppColors.textSecondary;
  static const Color sageLight = AppColors.paleSage;
  static const Color sageDark = AppColors.primary;

  // Status & Validation
  static const Color statusSuccess = AppColors.statusSuccess;
  static const Color statusSuccessBackground = AppColors.lightSage;
  static const Color statusSuccessLight = AppColors.paleSage;
  static const Color statusWarning = AppColors.statusWarning;
  static const Color statusError = AppColors.statusError;
  static const Color statusInfo = AppColors.statusInfo;

  // Ambient depth
  static const Color overlayDim = Color(0x28536158);
  static const Color subtleShadow = Color(0x0A536158);
}

/// Restrained & Cohesive Gradients for Vansora
abstract final class HeritageGradients {
  /// Signature Vansora 110° Linear Gradient
  /// Apply selectively: Featured family cards, milestone highlights, welcome panel
  static const LinearGradient signature = AppColors.signatureGradient;

  /// Signature Featured Card Gradient
  static const LinearGradient heroCard = AppColors.signatureGradient;

  /// Standard content card gradient (subtle pure white to whisper of light sage)
  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surface,
      Color(0xFFFCFDFB),
    ],
  );

  /// Active pill / filter badge gradient
  static const LinearGradient accentPill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.paleSage,
      AppColors.softMint,
    ],
  );

  /// Track background for segment pills
  static const LinearGradient pillTrack = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.lightSage,
      Color(0xFFE4ECE2),
    ],
  );

  /// Avatar circle light green gradient
  static const LinearGradient avatarPill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.lightSage,
      AppColors.paleSage,
    ],
  );

  /// Success badge highlight
  static const LinearGradient successBadge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.paleSage,
      AppColors.softMint,
    ],
  );

  /// Canvas background (solid warm white #F8F8F3)
  static const LinearGradient canvasBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      AppColors.background,
    ],
  );
}

/// Official Vansora Capsule Curves
/// - Proper capsule structure with generous curvature and zero stroke lines
abstract final class HeritageCurves {
  /// Small controls, pills & badges: 20 px
  static final BorderRadius small = BorderRadius.circular(20);

  /// Standard capsule cards & panels: 28 px
  static final BorderRadius card = BorderRadius.circular(28);

  /// Featured panels, dialogs & hero capsule cards: 34 px
  static final BorderRadius cardLarge = BorderRadius.circular(34);

  /// Full stadium capsule pills: 999 px
  static final BorderRadius pill = BorderRadius.circular(999);

  /// Sheet top radius: 32 px
  static const BorderRadius sheet = BorderRadius.vertical(top: Radius.circular(32));
}

/// Soft Ambient Shadows for borderless capsule cards
abstract final class HeritageShadows {
  /// Soft capsule card shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0C536158),
      blurRadius: 14,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Active filter or pill shadow
  static const List<BoxShadow> activePill = [
    BoxShadow(
      color: Color(0x0E76A982),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Navigation or floating bar shadow
  static const List<BoxShadow> pill = [
    BoxShadow(
      color: Color(0x0A536158),
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ];
}
