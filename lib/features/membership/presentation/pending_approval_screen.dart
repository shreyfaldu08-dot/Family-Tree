import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/providers/repository_providers.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: HeritageColors.mutedBrass.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: HeritageColors.mutedBrass, width: 2),
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: HeritageColors.mutedBrassDark,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Membership Pending Approval',
                  textAlign: TextAlign.center,
                  style: HeritageTypography.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your membership request has been submitted to the family archon. In accordance with family privacy rules, private archives and tree connections remain secured until explicitly approved.',
                  textAlign: TextAlign.center,
                  style: HeritageTypography.bodyMedium,
                ),
                const SizedBox(height: 36),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(currentMembershipProvider);
                    context.go('/');
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Check Approval Status'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    ref.invalidate(currentProfileProvider);
                    ref.invalidate(currentMembershipProvider);
                    if (context.mounted) context.go('/login');
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
