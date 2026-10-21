import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend service
  final supabaseService = SupabaseService();
  await supabaseService.initialize();

  runApp(
    const ProviderScope(
      child: FamilyLegacyApp(),
    ),
  );
}
