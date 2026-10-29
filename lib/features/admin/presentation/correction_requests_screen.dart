import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/branch_join_request.dart';
import '../../../data/models/correction_request.dart';
import '../../../data/providers/repository_providers.dart';

class CorrectionRequestsScreen extends ConsumerStatefulWidget {
  const CorrectionRequestsScreen({super.key});

  @override
  ConsumerState<CorrectionRequestsScreen> createState() => _CorrectionRequestsScreenState();
}

class _CorrectionRequestsScreenState extends ConsumerState<CorrectionRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branchRequests = ref.watch(branchJoinRequestsProvider);
    final pendingBranches = branchRequests.where((r) => r.status == 'pending').length;
    final correctionRequests = ref.watch(correctionRequestsProvider);
    final settings = ref.watch(adminSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Verifications & Requests', style: HeritageTypography.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_tree_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text('Lineage Bridges ($pendingBranches)'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('Correction Notes (${correctionRequests.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Lineage Bridge & Branch Join Verifications
          _buildBranchRequestsTab(branchRequests),

          // Tab 2: Suggestion Correction Notes
          _buildCorrectionNotesTab(correctionRequests, settings),
        ],
      ),
    );
  }

  Widget _buildBranchRequestsTab(List<BranchJoinRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_outlined, size: 56, color: AppColors.paleSage),
            const SizedBox(height: 12),
            Text('No Pending Lineage Bridges', style: HeritageTypography.titleMedium),
            Text('All family branch connections have been reviewed.', style: HeritageTypography.bodySmall),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final isPending = req.status == 'pending';
        final isVerified = req.status == 'verified';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: HeritageCurves.cardLarge,
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.lightSage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.family_restroom_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req.applicantName, style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                          Text(req.applicantEmail, style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? const Color(0xFFFEF3C7)
                          : (isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2)),
                      borderRadius: HeritageCurves.pill,
                    ),
                    child: Text(
                      isPending ? 'PENDING VERIFICATION' : (isVerified ? 'VERIFIED & CONNECTED' : 'REJECTED'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isPending
                            ? const Color(0xFFB45309)
                            : (isVerified ? const Color(0xFF047857) : const Color(0xFFB91C1C)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4-Generation Lineage Chain Visualizer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: HeritageCurves.card,
                ),
                child: Column(
                  children: [
                    _buildLineageRow(
                      icon: Icons.elderly_rounded,
                      role: 'Grandfather (Root)',
                      name: req.matchedGrandfatherName ?? req.grandfatherName,
                      badge: req.matchedGrandfatherId != null ? 'Matched in Tree ID ${req.treeId}' : 'New Ancestor',
                    ),
                    const Divider(height: 14),
                    _buildLineageRow(
                      icon: Icons.people_outline,
                      role: 'Father & Mother',
                      name: '${req.fatherName} & ${req.motherName} ${req.motherMaidenName.isNotEmpty ? "(née ${req.motherMaidenName})" : ""}',
                    ),
                    const Divider(height: 14),
                    _buildLineageRow(
                      icon: Icons.person_pin_circle_rounded,
                      role: 'Applicant (Branch Head)',
                      name: '${req.applicantName} (${req.applicantHometown ?? "Hometown not specified"})',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons for Admin
              if (isPending)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ref.read(branchJoinRequestsProvider.notifier).rejectRequest(req.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Declined branch request from ${req.applicantName}')),
                        );
                      },
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      label: const Text('Decline', style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(branchJoinRequestsProvider.notifier).verifyAndConnect(req.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ Verified! ${req.applicantName} connected to tree as Branch Admin.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Verify & Connect Branch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineageRow({
    required IconData icon,
    required String role,
    required String name,
    String? badge,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role, style: HeritageTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
              Text(name, style: HeritageTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.lightSage,
              borderRadius: HeritageCurves.pill,
            ),
            child: Text(
              badge,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildCorrectionNotesTab(List<CorrectionRequest> correctionRequests, dynamic settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: HeritageCurves.card,
            boxShadow: HeritageShadows.card,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggest a Correction Feature',
                      style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      settings.allowCorrectionSuggestions
                          ? 'Users can submit notes suggesting record updates.'
                          : 'User suggestions are currently disabled.',
                      style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.allowCorrectionSuggestions,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  ref.read(adminSettingsProvider.notifier).toggleCorrectionSuggestions();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Submitted Notes (${correctionRequests.length})',
          style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...correctionRequests.map((req) {
          final isPending = req.status == 'pending';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: HeritageCurves.card,
                boxShadow: HeritageShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req.personName, style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                            Text('Suggested by ${req.userName}', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                          borderRadius: HeritageCurves.pill,
                        ),
                        child: Text(
                          req.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isPending ? const Color(0xFFB45309) : const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: HeritageCurves.card,
                    ),
                    child: Text(req.message, style: HeritageTypography.bodyMedium),
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          ref.read(correctionRequestsProvider.notifier).rejectRequest(req.id);
                        },
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        label: const Text('Reject', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
