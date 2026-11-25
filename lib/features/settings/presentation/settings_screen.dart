import 'package:flutter/material.dart';
import '../../profile/presentation/user_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserProfileScreen(initialTabIndex: 3);
  }
}
