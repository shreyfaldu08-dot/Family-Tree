import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Official Vansora Master Theme Configuration
/// Built with cool light canvas (#F4F5F7), pure white cards (#FFFFFF),
/// pale blue panels (#E7EEFC), and deep navy accents (#101D38).
abstract final class HeritageTheme {
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primary, // #101D38 Primary Navy
      onPrimary: Colors.white,
      primaryContainer: AppColors.paleBlue, // #E7EEFC Pale Blue
      onPrimaryContainer: AppColors.textPrimary, // #172033
      secondary: AppColors.secondaryNavy, // #243754
      onSecondary: Colors.white,
      secondaryContainer: AppColors.softBlueGrey, // #EEF2F8
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.paleBlue,
      onTertiary: AppColors.textPrimary,
      surface: AppColors.surface, // #FFFFFF Pure White
      onSurface: AppColors.textPrimary,
      error: AppColors.statusError,
      onError: Colors.white,
      outline: AppColors.border, // #E5E8EE
      outlineVariant: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background, // #F4F5F7
      canvasColor: AppColors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: HeritageTypography.displaySmall.copyWith(
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.card, // 18px
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // #101D38 Deep Navy
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.softBlueGrey,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26), // Capsule button
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border, width: 1.0),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26), // Capsule button
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        labelStyle: HeritageTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: HeritageTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: const BorderSide(color: AppColors.statusError, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: HeritageCurves.pill,
          borderSide: const BorderSide(color: AppColors.statusError, width: 1.5),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.sheet,
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.cardLarge,
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
        titleTextStyle: HeritageTypography.displaySmall.copyWith(color: AppColors.textPrimary),
        contentTextStyle: HeritageTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.softBlueGrey,
        selectedColor: AppColors.paleBlue,
        disabledColor: AppColors.border,
        labelStyle: HeritageTypography.labelMedium.copyWith(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.pill,
          side: BorderSide.none,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 24,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.primary, // Deep Navy pill indicator
        indicatorShape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.pill,
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HeritageTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return HeritageTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white, size: 22);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 22);
        }),
      ),

      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
