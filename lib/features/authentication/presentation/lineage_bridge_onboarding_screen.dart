import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/branch_join_request.dart';
import '../../../data/models/membership.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

class LineageBridgeOnboardingScreen extends ConsumerStatefulWidget {
  const LineageBridgeOnboardingScreen({super.key});

  @override
  ConsumerState<LineageBridgeOnboardingScreen> createState() => _LineageBridgeOnboardingScreenState();
}

class _LineageBridgeOnboardingScreenState extends ConsumerState<LineageBridgeOnboardingScreen> {
  int _currentStep = 0;

  // Controllers
  final _treeIdCtrl = TextEditingController(text: 'VANS-8842');
  final _nameCtrl = TextEditingController(text: 'Rohan Kensington');
  final _emailCtrl = TextEditingController(text: 'rohan.k@clan.org');
  final _hometownCtrl = TextEditingController(text: 'Edinburgh');
  final String _gender = 'male';
  final DateTime _birthDate = DateTime(1992, 6, 14);

  // 4 Compulsory Ancestral Inputs
  final _fatherNameCtrl = TextEditingController(text: 'Hamish Kensington');
  final bool _fatherLiving = false;
  final _motherNameCtrl = TextEditingController(text: 'Isla Kensington');
  final _motherMaidenCtrl = TextEditingController(text: 'Sinclair');

  final _grandfatherNameCtrl = TextEditingController(text: 'Archibald Kensington');
  final bool _grandfatherLiving = false;
  final _grandmotherNameCtrl = TextEditingController(text: 'Margaret Kensington');
  final _grandmotherMaidenCtrl = TextEditingController(text: 'MacLeod');

  // Matched Grandfather Selection
  String? _selectedGrandfatherId = 'per_archibald';
  String? _selectedGrandfatherName = 'Archibald Kensington';
  bool _isSubmitted = false;

  @override
  void dispose() {
    _treeIdCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _hometownCtrl.dispose();
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    _motherMaidenCtrl.dispose();
    _grandfatherNameCtrl.dispose();
    _grandmotherNameCtrl.dispose();
    _grandmotherMaidenCtrl.dispose();
    super.dispose();
  }

  void _submitBranchBridge() {
    if (_nameCtrl.text.trim().isEmpty ||
        _fatherNameCtrl.text.trim().isEmpty ||
        _motherNameCtrl.text.trim().isEmpty ||
        _grandfatherNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all 4 compulsory ancestral details.')),
      );
      return;
    }

    final newReq = BranchJoinRequest(
      id: 'req_branch_${DateTime.now().millisecondsSinceEpoch}',
      treeId: _treeIdCtrl.text.trim().toUpperCase(),
      applicantName: _nameCtrl.text.trim(),
      applicantEmail: _emailCtrl.text.trim(),
      applicantGender: _gender,
      applicantHometown: _hometownCtrl.text.trim(),
      applicantBirthDate: _birthDate,
      fatherName: _fatherNameCtrl.text.trim(),
      fatherLiving: _fatherLiving,
      motherName: _motherNameCtrl.text.trim(),
      motherMaidenName: _motherMaidenCtrl.text.trim(),
      grandfatherName: _grandfatherNameCtrl.text.trim(),
      grandfatherLiving: _grandfatherLiving,
      grandmotherName: _grandmotherNameCtrl.text.trim(),
      grandmotherMaidenName: _grandmotherMaidenCtrl.text.trim(),
      matchedGrandfatherId: _selectedGrandfatherId,
      matchedGrandfatherName: _selectedGrandfatherName,
      status: 'pending',
      submittedAt: DateTime.now(),
    );

    ref.read(branchJoinRequestsProvider.notifier).submitRequest(newReq);
    ref.read(uniqueFamilyTreeIdProvider.notifier).setTreeId(_treeIdCtrl.text.trim().toUpperCase());
    ref.read(currentUserRoleProvider.notifier).setRole(MemberRole.viewer);

    setState(() {
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final existingPersons = ref.watch(familyPersonsProvider).valueOrNull ?? [];
    
    // Find matching grandfather candidates in the active tree
    final matchedAncestors = existingPersons.where((p) {
      final input = _grandfatherNameCtrl.text.trim().toLowerCase();
      if (input.isEmpty) return false;
      return p.displayName.toLowerCase().contains(input) || 
             input.contains(p.displayName.toLowerCase()) ||
             p.generation == 1 || p.generation == 2;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Lineage Bridge Setup', style: HeritageTypography.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isSubmitted ? _buildSubmissionSuccess() : _buildWizard(matchedAncestors),
      ),
    );
  }

  Widget _buildSubmissionSuccess() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: HeritageCurves.cardLarge,
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.lightSage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Branch Submitted for Verification',
                style: HeritageTypography.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: HeritageCurves.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 6),
                    Text(
                      'STATUS: PENDING MAIN ADMIN VERIFICATION',
                      style: HeritageTypography.labelSmall.copyWith(
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your 4-generation lineage bridge has been safely recorded under Family Tree ID "${_treeIdCtrl.text.trim()}".',
                style: HeritageTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                ),
                child: Column(
                  children: [
                    _buildChainRow('Root Grandfather', _selectedGrandfatherName ?? _grandfatherNameCtrl.text),
                    const Divider(height: 16),
                    _buildChainRow('Father & Mother', '${_fatherNameCtrl.text} & ${_motherNameCtrl.text}'),
                    const Divider(height: 16),
                    _buildChainRow('Your Generational Branch', _nameCtrl.text),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/tree'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Explore Extended Family Tree', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChainRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        Text(value, style: HeritageTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildWizard(List<Person> matchedAncestors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step progress indicator
          Row(
            children: [
              _buildStepIndicator(0, '1. Family ID'),
              const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
              _buildStepIndicator(1, '2. 4 Ancestors'),
              const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
              _buildStepIndicator(2, '3. Link Grandfather'),
            ],
          ),
          const SizedBox(height: 20),

          if (_currentStep == 0) _buildStep1FamilyId(),
          if (_currentStep == 1) _buildStep2Ancestors(),
          if (_currentStep == 2) _buildStep3GrandfatherMatcher(matchedAncestors),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : (isDone ? AppColors.lightSage : AppColors.surface),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${stepIndex + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: HeritageTypography.labelSmall.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1FamilyId() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: HeritageCurves.cardLarge,
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.lightSage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unique Family Tree ID', style: HeritageTypography.displaySmall),
                    Text(
                      'Ask your family Main Admin for your secret Family Tree Code.',
                      style: HeritageTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _treeIdCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Enter Unique Family Tree ID',
              hintText: 'e.g. VANS-8842',
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(Icons.diversity_3_rounded, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          // Verified tree banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightSage.withOpacity(0.5),
              borderRadius: HeritageCurves.card,
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Kensington Lineage (Verified)',
                        style: HeritageTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Main Admin: Archibald Kensington • 19 Verified Ancestors',
                        style: HeritageTypography.bodySmall.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Continue to 4 Compulsory Ancestors', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Ancestors() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: HeritageCurves.cardLarge,
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('4 Compulsory Ancestral Inputs', style: HeritageTypography.displaySmall),
          Text(
            'To connect your generational branch to the tree, please enter details for yourself, your parents, and grandparents.',
            style: HeritageTypography.bodySmall,
          ),
          const SizedBox(height: 20),

          // 1. Self Details
          _buildSectionHeader('1. Your Details (Self)'),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Your Full Name *',
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email / Phone',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _hometownCtrl,
                  decoration: InputDecoration(
                    labelText: 'Hometown / City',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Mother Details
          _buildSectionHeader('2. Mother Details'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _motherNameCtrl,
                  decoration: InputDecoration(
                    labelText: "Mother's Full Name *",
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _motherMaidenCtrl,
                  decoration: InputDecoration(
                    labelText: 'Maiden Name',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3. Father Details
          _buildSectionHeader('3. Father Details'),
          TextField(
            controller: _fatherNameCtrl,
            decoration: InputDecoration(
              labelText: "Father's Full Name *",
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 18),

          // 4. Grandparents Details
          _buildSectionHeader('4. Grandparents Details'),
          TextField(
            controller: _grandfatherNameCtrl,
            decoration: InputDecoration(
              labelText: "Grandfather's Full Name *",
              hintText: 'e.g. Archibald Kensington',
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(Icons.elderly_rounded, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _grandmotherNameCtrl,
                  decoration: InputDecoration(
                    labelText: "Grandmother's Full Name",
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _grandmotherMaidenCtrl,
                  decoration: InputDecoration(
                    labelText: 'Maiden Name',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: HeritageCurves.card, borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text('Find Grandfather Match', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3GrandfatherMatcher(List<Person> matchedAncestors) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: HeritageCurves.cardLarge,
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Grandfather Lineage Connection', style: HeritageTypography.displaySmall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'We checked the master family tree for grandfather "${_grandfatherNameCtrl.text}". If another brother has already connected, select the matched ancestor below to join under the same root.',
            style: HeritageTypography.bodySmall,
          ),
          const SizedBox(height: 20),

          // Found Matches Card
          if (matchedAncestors.isNotEmpty) ...[
            Text(
              'FOUND ANCESTORS IN TREE ID: ${_treeIdCtrl.text.toUpperCase()}',
              style: HeritageTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ...matchedAncestors.take(3).map((ancestor) {
              final isSelected = _selectedGrandfatherId == ancestor.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightSage.withOpacity(0.4) : AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isSelected ? AppColors.primary : AppColors.background,
                      child: Text(
                        ancestor.displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ancestor.displayName,
                                style: HeritageTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: HeritageCurves.pill,
                                ),
                                child: Text(
                                  'Gen ${ancestor.generation}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Connected Sibling Branches: Hamish Kensington & Callum Kensington',
                            style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGrandfatherId = ancestor.id;
                          _selectedGrandfatherName = ancestor.displayName;
                        });
                      },
                      borderRadius: HeritageCurves.pill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: HeritageCurves.pill,
                        ),
                        child: Text(
                          isSelected ? '✓ Connected' : 'Connect Here',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: HeritageCurves.card,
              ),
              child: Text(
                'No exact match found in existing tree. Your entered grandfather "${_grandfatherNameCtrl.text}" will be submitted to Main Admin as a new ancestral root.',
                style: HeritageTypography.bodySmall,
              ),
            ),
          ],

          const SizedBox(height: 20),
          // Branch administration role banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightSage.withOpacity(0.3),
              borderRadius: HeritageCurves.card,
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Once verified by Main Admin, you will become Branch Admin of your descendants tree with full rights to manage your family records.',
                    style: HeritageTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitBranchBridge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text('Submit for Admin Verification', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: HeritageTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
