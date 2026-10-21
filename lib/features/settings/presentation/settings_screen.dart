import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/membership.dart';
import '../../../data/models/profile.dart';
import '../../../data/providers/repository_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final membershipAsync = ref.watch(currentMembershipProvider);
    final membership = membershipAsync.valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Account & Privacy', style: HeritageTypography.displaySmall),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Profile Details Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: HeritageGradients.premiumCard,
              borderRadius: HeritageCurves.cardLarge,
              boxShadow: HeritageShadows.card,
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: HeritageGradients.avatarPill,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      profileAsync.valueOrNull?.displayName?.isNotEmpty == true
                          ? profileAsync.valueOrNull!.displayName![0].toUpperCase()
                          : 'A',
                      style: HeritageTypography.displaySmall.copyWith(
                        color: HeritageColors.charcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileAsync.valueOrNull?.presentationName ?? 'Archon Kensington',
                        style: HeritageTypography.titleSmall.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profileAsync.valueOrNull?.email ?? 'heritage.archon@familylegacy.org',
                        style: HeritageTypography.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: isAdmin
                              ? HeritageGradients.accentPill
                              : null,
                          color: isAdmin
                              ? null
                              : HeritageColors.surfaceSecondary,
                          borderRadius: HeritageCurves.pill,
                          boxShadow: isAdmin
                              ? HeritageShadows.activePill
                              : null,
                        ),
                        child: Text(
                          isAdmin
                              ? 'Role: Primary Admin (Write Authorization)'
                              : 'Role: Approved Member (Strict Read-Only)',
                          style: HeritageTypography.labelSmall.copyWith(
                            color: HeritageColors.charcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Security & Testing Simulation Control
          Text('Authorization Role Testing', style: HeritageTypography.displaySmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: HeritageGradients.premiumCard,
              borderRadius: HeritageCurves.card,
              boxShadow: HeritageShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Experience Simulator', style: HeritageTypography.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Switch between Primary Admin and Read-Only Viewer mode to verify that viewers cannot create, edit, or modify canonical records.',
                  style: HeritageTypography.bodySmall,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final authRepo = ref.read(authRepositoryProvider);
                          final now = DateTime.now();
                          authRepo.setMockSession(
                            profile: UserProfile(
                              id: 'usr_viewer_01',
                              email: 'clara.reader@gmail.com',
                              displayName: 'Clara Reader',
                              createdAt: now,
                              updatedAt: now,
                            ),
                            membership: FamilyMembership(
                              id: 'mem_viewer_01',
                              familyId: 'fam_kensington_01',
                              userId: 'usr_viewer_01',
                              role: MemberRole.viewer,
                              status: MemberStatus.active,
                              joinedAt: now,
                              updatedAt: now,
                            ),
                          );
                          ref.invalidate(currentProfileProvider);
                          ref.invalidate(currentMembershipProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Switched to Read-Only Viewer mode!'),
                              backgroundColor: HeritageColors.forestGreen,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: !isAdmin ? HeritageColors.forestGreen : HeritageColors.stoneDark,
                            width: !isAdmin ? 2 : 1,
                          ),
                        ),
                        child: const Text('Viewer Mode'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final authRepo = ref.read(authRepositoryProvider);
                          final now = DateTime.now();
                          authRepo.setMockSession(
                            profile: UserProfile(
                              id: 'usr_admin_kensington_01',
                              email: 'heritage.archon@familylegacy.org',
                              displayName: 'Archon Kensington',
                              createdAt: now,
                              updatedAt: now,
                            ),
                            membership: FamilyMembership(
                              id: 'mem_admin_01',
                              familyId: 'fam_kensington_01',
                              userId: 'usr_admin_kensington_01',
                              role: MemberRole.primaryAdmin,
                              status: MemberStatus.active,
                              joinedAt: now,
                              updatedAt: now,
                            ),
                          );
                          ref.invalidate(currentProfileProvider);
                          ref.invalidate(currentMembershipProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Switched to Primary Admin mode!'),
                              backgroundColor: HeritageColors.forestGreen,
                            ),
                          );
                        },
                        child: const Text('Admin Mode'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign Out button
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              ref.invalidate(currentProfileProvider);
              ref.invalidate(currentMembershipProvider);
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HeritageColors.statusError,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign Out & Clear Secure Session'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
