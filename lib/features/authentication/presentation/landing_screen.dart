import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/membership.dart';
import '../../../data/providers/repository_providers.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentUserRoleProvider);
    final isAdmin = currentRole == MemberRole.primaryAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: HeritageGradients.accentPill,
                borderRadius: HeritageCurves.pill,
                boxShadow: HeritageShadows.activePill,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 16,
                color: HeritageColors.charcoal,
              ),
            ),
            const SizedBox(width: 8),
            Text('Vansora', style: HeritageTypography.displaySmall),
          ],
        ),
        actions: [
          // Quick Role Switcher Pill for testing both Admin and User roles
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                ref.read(currentUserRoleProvider.notifier).toggleRole();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAdmin
                          ? 'Switched to View-Only User role'
                          : 'Switched to Admin role',
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              borderRadius: HeritageCurves.pill,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAdmin ? AppColors.paleSage : AppColors.surface,
                  borderRadius: HeritageCurves.pill,
                  boxShadow: HeritageShadows.card,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_outline_rounded,
                      size: 16,
                      color: isAdmin ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAdmin ? 'Admin' : 'User (View-Only)',
                      style: HeritageTypography.labelSmall.copyWith(
                        color: isAdmin ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Emblem
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: AppColors.lightSage,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_tree_rounded,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.paleSage,
                      borderRadius: HeritageCurves.pill,
                    ),
                    child: Text(
                      'DIGITAL FAMILY TREE SANCTUARY',
                      style: HeritageTypography.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Preserve Your Living Lineage',
                    textAlign: TextAlign.center,
                    style: HeritageTypography.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Replace fragile paper family records with an interactive digital tree. Empower upcoming generations to explore ancestry across 10 generations, view verified photographs, and stay connected.',
                    textAlign: TextAlign.center,
                    style: HeritageTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Core Action Launchpad Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: HeritageCurves.cardLarge,
                      boxShadow: HeritageShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Direct Home / Tree button
                        ElevatedButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.cottage_rounded, size: 20),
                          label: const Text('Enter Digital Family Tree'),
                        ),

                        const SizedBox(height: 12),

                        // User Sign Up
                        OutlinedButton.icon(
                          onPressed: () => context.push('/signup'),
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                          label: const Text('Create User Account (Sign Up)'),
                        ),

                        const SizedBox(height: 12),

                        // User Login
                        TextButton.icon(
                          onPressed: () => context.push('/login'),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: const Text('Family Member Login'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Separate Admin Login entry
                  InkWell(
                    onTap: () => context.push('/admin/login'),
                    borderRadius: HeritageCurves.pill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.lightSage,
                        borderRadius: HeritageCurves.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Admin Portal Login (/admin/login)',
                            style: HeritageTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
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
