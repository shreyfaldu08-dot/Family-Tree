import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/membership.dart';
import '../../../data/providers/repository_providers.dart';

class MembershipRequestsScreen extends ConsumerStatefulWidget {
  const MembershipRequestsScreen({super.key});

  @override
  ConsumerState<MembershipRequestsScreen> createState() => _MembershipRequestsScreenState();
}

class _MembershipRequestsScreenState extends ConsumerState<MembershipRequestsScreen> {
  List<MembershipRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final repo = ref.read(familyRepositoryProvider);
    final membership = ref.read(currentMembershipProvider).valueOrNull;
    final list = await repo.getPendingRequests('fam_kensington_01', membership);
    if (mounted) {
      setState(() {
        _requests = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _approve(String reqId) async {
    final repo = ref.read(familyRepositoryProvider);
    final membership = ref.read(currentMembershipProvider).valueOrNull;
    await repo.approveRequest(reqId, membership);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Membership request approved. Access granted to read-only family archive.'),
        backgroundColor: HeritageColors.forestGreen,
      ),
    );
    _loadRequests();
  }

  Future<void> _reject(String reqId) async {
    final repo = ref.read(familyRepositoryProvider);
    final membership = ref.read(currentMembershipProvider).valueOrNull;
    await repo.rejectRequest(reqId, membership);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request rejected.')),
    );
    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Membership Requests', style: HeritageTypography.displaySmall),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HeritageColors.forestGreen))
          : _requests.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mark_email_read_outlined, size: 52, color: HeritageColors.sage),
                        const SizedBox(height: 12),
                        Text('No Pending Requests', style: HeritageTypography.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'When family members redeem an invitation code, their requests will appear here for your explicit authorization.',
                          textAlign: TextAlign.center,
                          style: HeritageTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: _requests.length,
                  itemBuilder: (ctx, i) {
                    final req = _requests[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: HeritageGradients.premiumCard,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: HeritageShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                req.requesterDisplayName ?? 'Heritage Applicant',
                                style: HeritageTypography.titleSmall.copyWith(fontSize: 16),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: HeritageColors.mutedBrass.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('Pending Approval', style: HeritageTypography.labelSmall),
                              ),
                            ],
                          ),
                          if (req.requesterEmail != null) ...[
                            const SizedBox(height: 2),
                            Text(req.requesterEmail!, style: HeritageTypography.bodySmall),
                          ],
                          if (req.note != null) ...[
                            const SizedBox(height: 8),
                            Text('Note: "${req.note!}"', style: HeritageTypography.bodyMedium),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _reject(req.id),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: HeritageColors.statusError,
                                    side: const BorderSide(color: HeritageColors.statusError),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _approve(req.id),
                                  child: const Text('Approve Access'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
