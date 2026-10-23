import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/colors.dart';

class NavigationScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: HeritageShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.84),
                borderRadius: BorderRadius.circular(36),
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 66,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_tree_outlined),
                    selectedIcon: Icon(Icons.account_tree_rounded),
                    label: 'Family Tree',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: 'People',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.photo_library_outlined),
                    selectedIcon: Icon(Icons.photo_library_rounded),
                    label: 'Archive',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
