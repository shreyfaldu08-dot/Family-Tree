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
            indicatorColor: AppColors.primary,
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
                icon: Icon(Icons.cottage_outlined, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.cottage_rounded, color: Colors.white, size: 22),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_outlined, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.account_tree_rounded, color: Colors.white, size: 22),
                label: 'Tree',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                selectedIcon: Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                label: 'Timeline',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.people_rounded, color: Colors.white, size: 22),
                label: 'Directory',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 22),
                selectedIcon: Icon(Icons.person_rounded, color: Colors.white, size: 22),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
