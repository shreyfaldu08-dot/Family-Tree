import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/repository_providers.dart';
import 'theme/colors.dart';

class NavigationScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isCurrentAdminProvider);

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.cottage_outlined, color: AppColors.textSecondary, size: 22),
        selectedIcon: Icon(Icons.cottage_rounded, color: Colors.white, size: 22),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.account_tree_outlined, color: AppColors.textSecondary, size: 22),
        selectedIcon: Icon(Icons.account_tree_rounded, color: Colors.white, size: 22),
        label: 'Tree',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
        selectedIcon: Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
        label: 'Timeline',
      ),
      const NavigationDestination(
        icon: Icon(Icons.photo_library_outlined, color: AppColors.textSecondary, size: 22),
        selectedIcon: Icon(Icons.photo_library_rounded, color: Colors.white, size: 22),
        label: 'Vault',
      ),
      const NavigationDestination(
        icon: Icon(Icons.people_outline_rounded, color: AppColors.textSecondary, size: 22),
        selectedIcon: Icon(Icons.people_rounded, color: Colors.white, size: 22),
        label: 'Directory',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 22),
        selectedIcon: Icon(Icons.person_rounded, color: Colors.white, size: 22),
        label: 'Profile',
      ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined, color: AppColors.textSecondary, size: 22),
          selectedIcon: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
          label: 'Admin',
        ),
    ];

    final clampedIndex = navigationShell.currentIndex.clamp(0, destinations.length - 1);

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
            selectedIndex: clampedIndex,
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
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
