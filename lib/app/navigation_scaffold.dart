import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/colors.dart';

class NavigationScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A536158),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            height: 58,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: navigationShell.currentIndex,
            indicatorColor: AppColors.paleSage,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: HeritageCurves.pill,
            ),
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.cottage_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.cottage_rounded, color: AppColors.textPrimary),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.park_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.park_rounded, color: AppColors.textPrimary),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.diversity_3_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.diversity_3_rounded, color: AppColors.textPrimary),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.auto_stories_rounded, color: AppColors.textPrimary),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.textPrimary),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
