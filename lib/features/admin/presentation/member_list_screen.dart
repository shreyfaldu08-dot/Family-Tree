import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/membership.dart';
import '../../../data/providers/repository_providers.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  List<FamilyMembership> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final repo = ref.read(familyRepositoryProvider);
    final membership = ref.read(currentMembershipProvider).valueOrNull;
    final list = await repo.getMembers('fam_kensington_01', membership);
    if (mounted) {
      setState(() {
        _members = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _revoke(String membershipId) async {
    final repo = ref.read(familyRepositoryProvider);
    final membership = ref.read(currentMembershipProvider).valueOrNull;
    await repo.revokeMembership(membershipId, membership);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Member access revoked. Immediate block on private records.'),
        backgroundColor: HeritageColors.statusWarning,
      ),
    );
    _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Family Members', style: HeritageTypography.displaySmall),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HeritageColors.forestGreen))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _members.length,
              itemBuilder: (ctx, i) {
                final m = _members[i];
                final isAdmin = m.role == MemberRole.primaryAdmin;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: HeritageGradients.premiumCard,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: HeritageShadows.card,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isAdmin ? HeritageGradients.accentPill : HeritageGradients.avatarPill,
                        ),
                        child: Icon(
                          isAdmin ? Icons.shield : Icons.person_outline,
                          color: HeritageColors.charcoal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.userDisplayName ?? m.userEmail ?? 'Family Member',
                              style: HeritageTypography.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAdmin ? 'Primary Archon (Sole Admin)' : 'Approved Member (Read-Only)',
                              style: HeritageTypography.bodySmall.copyWith(
                                color: isAdmin ? HeritageColors.charcoal : HeritageColors.charcoalMuted,
                                fontWeight: isAdmin ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                            if (!m.status.isActive) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Status: REVOKED',
                                style: HeritageTypography.labelSmall.copyWith(color: HeritageColors.statusError),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isAdmin && m.status.isActive)
                        TextButton(
                          onPressed: () => _revoke(m.id),
                          style: TextButton.styleFrom(foregroundColor: HeritageColors.statusError),
                          child: const Text('Revoke'),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
