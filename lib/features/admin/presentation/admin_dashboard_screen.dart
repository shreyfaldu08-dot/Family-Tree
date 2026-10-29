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
    final isAdmin = ref.watch(isCurrentAdminProvider);
    final personsAsync = ref.watch(familyPersonsProvider);
    final users = ref.watch(userManagementProvider);
    final requests = ref.watch(correctionRequestsProvider);

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

    final persons = personsAsync.valueOrNull ?? [];
    final branchRequests = ref.watch(branchJoinRequestsProvider);
    final pendingRequests = requests.where((r) => r.status == 'pending').length;
    final pendingBridges = branchRequests.where((r) => r.isPending).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Workspace', style: HeritageTypography.displaySmall),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Metrics Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: HeritageGradients.heroCard,
              borderRadius: HeritageCurves.cardLarge,
              boxShadow: HeritageShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Living Heritage Archive', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                        Text('The Kensington Lineage (VANS-8842)', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: HeritageCurves.pill,
                      ),
                      child: const Text('👑 Admin', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatPill('People', '${persons.length}', Icons.people_outline_rounded),
                    const SizedBox(width: 6),
                    _buildStatPill('Users', '${users.length}', Icons.badge_outlined),
                    const SizedBox(width: 6),
                    _buildStatPill('Bridges', '$pendingBridges', Icons.alt_route_rounded),
                    const SizedBox(width: 6),
                    _buildStatPill('Notes', '$pendingRequests', Icons.mark_email_unread_outlined),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('People & Lineage', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          _adminActionTile(
            context,
            icon: Icons.person_add_outlined,
            title: 'Add New Person (7-Step Form)',
            subtitle: 'Multi-step form: basic, birth, family links, life details, death, media & review',
            onTap: () => context.push('/admin/person/new'),
          ),

          _adminActionTile(
            context,
            icon: Icons.hub_outlined,
            title: 'Relationship Manager',
            subtitle: 'Connect parent, spouse, child, and sibling with cycle prevention',
            onTap: () => context.push('/admin/relations'),
          ),

          _adminActionTile(
            context,
            icon: Icons.alt_route_rounded,
            badge: pendingBridges > 0 ? '$pendingBridges' : null,
            title: 'Lineage Bridges & Branch Approvals',
            subtitle: 'Review brother/descendant join requests and connect branches to tree',
            onTap: () => context.push('/admin/requests'),
          ),

          _adminActionTile(
            context,
            icon: Icons.perm_media_outlined,
            title: 'Manage Media & Scans',
            subtitle: 'Upload and organise photos, certificates, and historical documents',
            onTap: () => context.push('/admin/media'),
          ),

          const SizedBox(height: 20),

          Text('Members & Requests', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          _adminActionTile(
            context,
            icon: Icons.rate_review_outlined,
            badge: pendingRequests > 0 ? '$pendingRequests' : null,
            title: 'Correction Requests',
            subtitle: 'Review suggestions submitted by family members',
            onTap: () => context.push('/admin/requests'),
          ),

          _adminActionTile(
            context,
            icon: Icons.manage_accounts_outlined,
            title: 'Manage Users',
            subtitle: 'List, search, block/unblock, delete users, and add admin accounts',
            onTap: () => context.push('/admin/users'),
          ),

          const SizedBox(height: 20),

          Text('System, Audit & Settings', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          _adminActionTile(
            context,
            icon: Icons.history_toggle_off_rounded,
            title: 'Activity & Audit Log (with Undo)',
            subtitle: 'Chronological timeline of who modified what, with one-tap undo',
            onTap: () => context.push('/admin/logs'),
          ),

          _adminActionTile(
            context,
            icon: Icons.tune_rounded,
            title: 'Admin Settings & Privacy',
            subtitle: 'Privacy rules, living persons protection, downloads, languages, backups',
            onTap: () => context.push('/admin/settings'),
          ),

          _adminActionTile(
            context,
            icon: Icons.download_rounded,
            title: 'Lineage Export & PDF Chart',
            subtitle: 'Download complete JSON database backup or generate PDF pedigree book',
            onTap: () => context.push('/admin/export'),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: HeritageCurves.card,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value, style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: HeritageTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _adminActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: HeritageCurves.card,
        boxShadow: HeritageShadows.card,
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.lightSage,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(title, style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: HeritageTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded, color: AppColors.paleSage),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
