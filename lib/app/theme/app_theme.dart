import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Living Heritage Material 3 Theme Configuration
abstract final class HeritageTheme {
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: HeritageColors.forestGreen,
      onPrimary: HeritageColors.warmIvoryLight,
      primaryContainer: HeritageColors.stone,
      onPrimaryContainer: HeritageColors.forestGreenDark,
      secondary: HeritageColors.mutedBrass,
      onSecondary: Colors.white,
      secondaryContainer: HeritageColors.stoneLight,
      onSecondaryContainer: HeritageColors.charcoal,
      tertiary: HeritageColors.sage,
      onTertiary: Colors.white,
      surface: HeritageColors.warmIvory,
      onSurface: HeritageColors.charcoal,
      error: HeritageColors.statusError,
      onError: Colors.white,
      outline: HeritageColors.stoneDark,
      outlineVariant: HeritageColors.stone,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: HeritageColors.warmIvory,
      canvasColor: HeritageColors.warmIvoryLight,

      appBarTheme: AppBarTheme(
        backgroundColor: HeritageColors.warmIvory,
        foregroundColor: HeritageColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: HeritageColors.subtleShadow,
        centerTitle: true,
        titleTextStyle: HeritageTypography.displaySmall,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: HeritageColors.warmIvoryLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HeritageColors.stone, width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HeritageColors.forestGreen,
          foregroundColor: HeritageColors.warmIvoryLight,
          disabledBackgroundColor: HeritageColors.stoneDark,
          disabledForegroundColor: HeritageColors.charcoalMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HeritageColors.forestGreen,
          disabledForegroundColor: HeritageColors.charcoalMuted,
          side: const BorderSide(color: HeritageColors.forestGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: HeritageColors.forestGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: HeritageTypography.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HeritageColors.warmIvoryLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        labelStyle: HeritageTypography.bodyMedium.copyWith(color: HeritageColors.charcoalMuted),
        hintStyle: HeritageTypography.bodyMedium.copyWith(color: HeritageColors.charcoalMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HeritageColors.stone, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HeritageColors.stone, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HeritageColors.forestGreen, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HeritageColors.statusError, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HeritageColors.statusError, width: 2.0),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HeritageColors.warmIvoryLight,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: HeritageColors.warmIvoryLight,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: HeritageTypography.displaySmall,
        contentTextStyle: HeritageTypography.bodyMedium,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: HeritageColors.stoneLight,
        selectedColor: HeritageColors.mutedBrass,
        disabledColor: HeritageColors.stoneDark,
        labelStyle: HeritageTypography.labelMedium.copyWith(color: HeritageColors.charcoal),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: HeritageColors.stone, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: HeritageColors.stone,
        thickness: 1,
        space: 24,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: HeritageColors.warmIvoryLight,
        elevation: 3,
        shadowColor: HeritageColors.subtleShadow,
        indicatorColor: HeritageColors.forestGreen,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: HeritageColors.warmIvoryLight, size: 22);
          }
          return const IconThemeData(color: HeritageColors.charcoalMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HeritageTypography.labelSmall.copyWith(
              color: HeritageColors.forestGreen,
              fontWeight: FontWeight.w700,
            );
          }
          return HeritageTypography.labelSmall.copyWith(
            color: HeritageColors.charcoalMuted,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
    );
  }
}
