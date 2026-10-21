import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Living Heritage Material 3 Theme Configuration
/// Clean, minimal, soft iOS-inspired aesthetic with off-white background (#F3F5F8),
/// white cards (#FFFFFF), subtle borders (#E3E7ED), near-black typography (#08090C),
/// muted grey secondary text (#667085), and soft pale blue accents (#D9E8FF).
abstract final class HeritageTheme {
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: HeritageColors.forestGreen, // #08090C (near-black for primary buttons and strong elements)
      onPrimary: Colors.white,
      primaryContainer: HeritageColors.softBlueAccent, // #D9E8FF (soft blue accent)
      onPrimaryContainer: HeritageColors.charcoal,
      secondary: HeritageColors.blueHighlight, // #A9CBFF
      onSecondary: HeritageColors.charcoal,
      secondaryContainer: HeritageColors.surfaceSecondary, // #E9EDF2
      onSecondaryContainer: HeritageColors.charcoal,
      tertiary: HeritageColors.textSecondary, // #667085
      onTertiary: Colors.white,
      surface: HeritageColors.background, // #F3F5F8
      onSurface: HeritageColors.charcoal, // #08090C
      error: HeritageColors.statusError,
      onError: Colors.white,
      outline: HeritageColors.borderSubtle, // #E3E7ED
      outlineVariant: HeritageColors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: HeritageColors.background,
      canvasColor: HeritageColors.surfaceCard,

      appBarTheme: AppBarTheme(
        backgroundColor: HeritageColors.background,
        foregroundColor: HeritageColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: HeritageColors.subtleShadow,
        centerTitle: true,
        titleTextStyle: HeritageTypography.displaySmall,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: HeritageColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: HeritageColors.borderSubtle, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HeritageColors.charcoal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: HeritageColors.surfaceSecondary,
          disabledForegroundColor: HeritageColors.charcoalMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HeritageColors.charcoal,
          disabledForegroundColor: HeritageColors.charcoalMuted,
          side: const BorderSide(color: HeritageColors.borderSubtle, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: HeritageColors.charcoal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: HeritageTypography.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HeritageColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        labelStyle: HeritageTypography.bodyMedium.copyWith(color: HeritageColors.charcoalMuted),
        hintStyle: HeritageTypography.bodyMedium.copyWith(color: HeritageColors.charcoalMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HeritageColors.borderSubtle, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HeritageColors.borderSubtle, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HeritageColors.blueHighlight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HeritageColors.statusError, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HeritageColors.statusError, width: 1.5),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HeritageColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: HeritageColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HeritageColors.borderSubtle, width: 1.0),
        ),
        titleTextStyle: HeritageTypography.displaySmall,
        contentTextStyle: HeritageTypography.bodyMedium,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: HeritageColors.surfaceSecondary,
        selectedColor: HeritageColors.softBlueAccent,
        disabledColor: HeritageColors.stoneDark,
        labelStyle: HeritageTypography.labelMedium.copyWith(color: HeritageColors.charcoal),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: HeritageColors.borderSubtle, width: 1.0),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: HeritageColors.borderSubtle,
        thickness: 1,
        space: 24,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: HeritageColors.surfaceCard,
        elevation: 0,
        shadowColor: HeritageColors.subtleShadow,
        indicatorColor: HeritageColors.softBlueAccent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: HeritageColors.charcoal, size: 22);
          }
          return const IconThemeData(color: HeritageColors.charcoalMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HeritageTypography.labelSmall.copyWith(
              color: HeritageColors.charcoal,
              fontWeight: FontWeight.w600,
            );
          }
          return HeritageTypography.labelSmall.copyWith(
            color: HeritageColors.charcoalMuted,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      tabBarTheme: TabBarThemeData(
        indicatorColor: HeritageColors.charcoal,
        labelColor: HeritageColors.charcoal,
        unselectedLabelColor: HeritageColors.charcoalMuted,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
