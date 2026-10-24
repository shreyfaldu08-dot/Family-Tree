import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Official Vansora Master Light Theme Configuration
/// Built with warm-white (#F8F8F3) canvas, pure-white (#FFFFFF) cards,
/// subtle soft borders (#DCE7DA), and natural green accents (#76A982).
abstract final class HeritageTheme {
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primary, // #76A982 Primary Green
      onPrimary: Colors.white,
      primaryContainer: AppColors.paleSage, // #E0EDE0 Pale Sage
      onPrimaryContainer: AppColors.textPrimary, // #536158 Soft Charcoal
      secondary: AppColors.secondary, // #9BC5A0 Fresh Green
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightSage, // #EDF4EA Light Sage
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.softMint, // #C7E2C9 Soft Mint
      onTertiary: AppColors.textPrimary,
      surface: AppColors.surface, // #FFFFFF Pure White
      onSurface: AppColors.textPrimary,
      error: AppColors.statusError,
      onError: Colors.white,
      outline: AppColors.border, // #DCE7DA Soft Border
      outlineVariant: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background, // #F8F8F3 Warm White
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
          borderRadius: HeritageCurves.card, // 28px Capsule Card
          side: BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // #76A982
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.lightSage,
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
          backgroundColor: AppColors.lightSage, // #EDF4EA Secondary button
          foregroundColor: AppColors.textPrimary, // #536158
          disabledForegroundColor: AppColors.textSecondary,
          side: BorderSide.none, // Zero stroke line
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
          foregroundColor: AppColors.textPrimary, // #536158 Tertiary button
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Capsule
          ),
          textStyle: HeritageTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface, // Pure White
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        labelStyle: HeritageTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: HeritageTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28), // Proper capsule input
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none, // Pure borderless capsule
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.statusError, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.statusError, width: 1.5),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.sheet, // 32px
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.cardLarge, // 34px Capsule
          side: BorderSide.none,
        ),
        titleTextStyle: HeritageTypography.displaySmall.copyWith(color: AppColors.textPrimary),
        contentTextStyle: HeritageTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSage,
        selectedColor: AppColors.paleSage,
        disabledColor: AppColors.border,
        labelStyle: HeritageTypography.labelMedium.copyWith(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.pill,
          side: BorderSide.none,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.lightSage,
        thickness: 1,
        space: 24,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.paleSage,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: HeritageCurves.pill, // Stadium capsule indicator
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return HeritageTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
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
            return const IconThemeData(color: AppColors.textPrimary, size: 23);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 22);
        }),
      ),

      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.primary,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
