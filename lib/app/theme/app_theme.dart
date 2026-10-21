import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Living Heritage Material 3 Theme Configuration
/// Clean, curvy, soft iOS-inspired aesthetic with light shade gradients,
/// floating cards with zero border strokes, and pill/capsule segmented controls.
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
      tertiary: HeritageColors.textSecondary,
      onTertiary: Colors.white,
      surface: HeritageColors.surfaceCard,
      onSurface: HeritageColors.charcoal,
      error: HeritageColors.statusError,
      onError: Colors.white,
      outline: Colors.transparent,
      outlineVariant: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: HeritageColors.surfaceCard,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: HeritageColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
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
          borderRadius: HeritageCurves.card,
          side: BorderSide.none, // Zero stroke
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
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: HeritageCurves.pill, // Stadium capsule
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
          side: const BorderSide(color: Color(0xFFDDE6F1), width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: HeritageCurves.pill, // Stadium capsule
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: HeritageColors.charcoal,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: HeritageCurves.pill,
          ),
          textStyle: HeritageTypography.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HeritageColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        labelStyle: HeritageTypography.bodyMedium.copyWith(color: HeritageColors.charcoalMuted),
        hintStyle: HeritageTypography.bodyMedium.copyWith(color: HeritageColors.charcoalMuted),
        border: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: BorderSide.none, // Clean floating input with no stroke
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: const BorderSide(color: Color(0xFFDDD0F8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: const BorderSide(color: HeritageColors.statusError, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: const BorderSide(color: HeritageColors.statusError, width: 1.5),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HeritageColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.sheet,
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: HeritageColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.cardLarge,
          side: BorderSide.none, // No stroke
        ),
        titleTextStyle: HeritageTypography.displaySmall,
        contentTextStyle: HeritageTypography.bodyMedium,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: HeritageColors.surfaceSecondary,
        selectedColor: HeritageColors.softBlueAccent,
        disabledColor: HeritageColors.stoneDark,
        labelStyle: HeritageTypography.labelMedium.copyWith(color: HeritageColors.charcoal),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.pill, // Stadium capsule
          side: BorderSide.none, // No stroke
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFEDF2F7),
        thickness: 1,
        space: 24,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: HeritageColors.surfaceCard,
        elevation: 0,
        shadowColor: HeritageColors.subtleShadow,
        indicatorColor: const Color(0xFFEFE4FC),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.pill,
        ),
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
        indicatorColor: Colors.transparent,
        labelColor: HeritageColors.charcoal,
        unselectedLabelColor: HeritageColors.charcoalMuted,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
