import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/providers/repository_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(currentMembershipProvider).valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Strict Authorization Rule:\nOnly the Primary Admin can access the admin workspace.',
              textAlign: TextAlign.center,
              style: HeritageTypography.titleMedium,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Admin Workspace', style: HeritageTypography.displaySmall),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Admin notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HeritageColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HeritageColors.borderSubtle, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: HeritageColors.subtleShadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: HeritageColors.softBlueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: HeritageColors.blueHighlight, width: 1.0),
                  ),
                  child: const Icon(Icons.shield_outlined, color: HeritageColors.charcoal, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Archon Authorization',
                        style: HeritageTypography.titleSmall.copyWith(
                          color: HeritageColors.charcoal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Canonical writes and membership management are cryptographically secured by PostgreSQL Row Level Security.',
                        style: HeritageTypography.bodySmall.copyWith(
                          color: HeritageColors.charcoalMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('Lineage Management', style: HeritageTypography.displaySmall),
          const SizedBox(height: 12),

          _adminActionTile(
            context,
            icon: Icons.person_add_outlined,
            title: 'Add Family Member Record',
            subtitle: 'Record birth, death, names, biography, and life story',
            onTap: () => context.push('/admin/persons/new'),
          ),

          _adminActionTile(
            context,
            icon: Icons.hub_outlined,
            title: 'Relationship Builder & Graph Edges',
            subtitle: 'Connect parents, children, and spouses with cycle prevention',
            onTap: () => context.push('/admin/relationships'),
          ),

          _adminActionTile(
            context,
            icon: Icons.warning_amber_rounded,
            title: 'Incomplete & Unverified Records',
            subtitle: 'Audit missing birth dates, birthplaces, or parent connections',
            onTap: () => context.push('/admin/incomplete'),
          ),

          const SizedBox(height: 24),

          Text('Access & Membership', style: HeritageTypography.displaySmall),
          const SizedBox(height: 12),

          _adminActionTile(
            context,
            icon: Icons.mark_email_read_outlined,
            title: 'Membership Requests',
            subtitle: 'Review, approve, or reject family member access requests',
            onTap: () => context.push('/admin/requests'),
          ),

          _adminActionTile(
            context,
            icon: Icons.vpn_key_outlined,
            title: 'Generate Single-Use Invitation',
            subtitle: 'Create random, expiring token hashes for family members',
            onTap: () => context.push('/admin/invitations'),
          ),

          _adminActionTile(
            context,
            icon: Icons.group_remove_outlined,
            title: 'Member Access & Revocation',
            subtitle: 'View active family members and revoke access when necessary',
            onTap: () => context.push('/admin/members'),
          ),

          const SizedBox(height: 24),

          Text('Governance & Preservation', style: HeritageTypography.displaySmall),
          const SizedBox(height: 12),

          _adminActionTile(
            context,
            icon: Icons.history_edu_outlined,
            title: 'Archival Audit Logs',
            subtitle: 'View historical trail of records created and permissions modified',
            onTap: () => context.push('/admin/audit'),
          ),

          _adminActionTile(
            context,
            icon: Icons.download_for_offline_outlined,
            title: 'Export Archive & Recovery',
            subtitle: 'Generate a full JSON backup of all family persons, media, and graphs',
            onTap: () => context.push('/admin/export'),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _adminActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HeritageColors.warmIvoryLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeritageColors.stone, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: HeritageColors.subtleShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: HeritageColors.softBlueAccent,
            shape: BoxShape.circle,
            border: Border.all(color: HeritageColors.blueHighlight, width: 1),
          ),
          child: Icon(icon, color: HeritageColors.charcoal, size: 22),
        ),
        title: Text(title, style: HeritageTypography.titleSmall),
        subtitle: Text(subtitle, style: HeritageTypography.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HeritageColors.charcoalMuted),
        onTap: onTap,
      ),
    );
  }
}
