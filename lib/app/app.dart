import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router.dart';

class FamilyLegacyApp extends ConsumerWidget {
  const FamilyLegacyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Vansora',
      debugShowCheckedModeBanner: false,
      theme: HeritageTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
