import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Local editable profile state with defaults for Sara Wilson
  String _displayName = 'Sara Wilson';
  String _maidenName = 'Kensington';
  String _bio = 'Family heritage archivist, researcher, and active viewer of the Kensington archives. Dedicated to preserving oral histories, photographic records, and genealogical lineage across all generations.';
  String _birthPlace = 'Seattle, Washington, USA';
  String _residence = 'Seattle, WA';
  String _email = 'sara.wilson@kensingtonlegacy.org';
  String _phone = '+1 (206) 555-0198';

  // Notification Preferences
  bool _notifyTreeUpdates = true;
  bool _notifyEvents = true;
  bool _notifyVault = false;
  bool _notifyBirthdays = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('Invite Relative to Clan', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share this invitation code or link with family members to grant them read-only viewer access to the Kensington–Vansora tree.',
                style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('KENSINGTON-2026-INVITE', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: 'KENSINGTON-2026-INVITE'));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invitation code copied to clipboard!'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.download_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('Export Heritage Data', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select format to download the complete canonical records for the Kensington clan:',
                style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.code_rounded, color: AppColors.primary),
                title: Text('Family Tree Graph (JSON)', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: Text('Full nodes, edges & metadata', style: GoogleFonts.inter(fontSize: 11)),
                trailing: const Icon(Icons.file_download_outlined),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloaded vansora_family_tree.json'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              const Divider(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent),
                title: Text('Canonical Lineage Transcript (PDF)', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: Text('Archival certificate with 10 generations', style: GoogleFonts.inter(fontSize: 11)),
                trailing: const Icon(Icons.file_download_outlined),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generated lineage_transcript_gen10.pdf'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openEditProfileSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: _displayName);
    final maidenCtrl = TextEditingController(text: _maidenName);
    final bioCtrl = TextEditingController(text: _bio);
    final placeCtrl = TextEditingController(text: _birthPlace);
    final residenceCtrl = TextEditingController(text: _residence);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Heritage Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSheetTextField('Full Display Name', nameCtrl, Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _buildSheetTextField('Maiden / Birth Name', maidenCtrl, Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildSheetTextField('Archivist Biography', bioCtrl, Icons.description_outlined, maxLines: 3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSheetTextField('Birth Place', placeCtrl, Icons.place_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSheetTextField('Current Residence', residenceCtrl, Icons.home_outlined)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSheetTextField('Contact Email', emailCtrl, Icons.email_outlined),
                const SizedBox(height: 12),
                _buildSheetTextField('Phone Number', phoneCtrl, Icons.phone_outlined),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _displayName = nameCtrl.text.trim();
                        _maidenName = maidenCtrl.text.trim();
                        _bio = bioCtrl.text.trim();
                        _birthPlace = placeCtrl.text.trim();
                        _residence = residenceCtrl.text.trim();
                        _email = emailCtrl.text.trim();
                        _phone = phoneCtrl.text.trim();
                      });
                      final authRepo = ref.read(authRepositoryProvider);
                      authRepo.updateUserProfile(displayName: _displayName, email: _email);
                      ref.invalidate(currentProfileProvider);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetTextField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final allPersons = personsAsync.valueOrNull ?? [];
    final isAdmin = ref.watch(isCurrentAdminProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final activePersona = ref.watch(currentPersonaProvider);
    final activeFocusId = ref.watch(userBranchPersonIdProvider);

    // Identify user and immediate family members
    final activeUserPerson = allPersons.where(
      (p) => (activeFocusId != null && p.id == activeFocusId) ||
          (profile != null && p.id == profile.id) ||
          p.id == 'p_gen9_sara',
    ).firstOrNull;

    final sara = activeUserPerson ?? allPersons.where((p) => p.id == 'p_gen9_sara').firstOrNull;
    final spouse = allPersons.where((p) => p.id == 'p_gen9_thomas_wilson').firstOrNull;
    final children = allPersons.where((p) => p.id == 'p_gen10_maya' || p.id == 'p_gen10_liam').toList();
    final parents = allPersons.where((p) => p.id == 'p_gen8_david' || p.id == 'p_gen8_sophia').toList();
    final siblings = allPersons.where((p) => p.generationHint == 9 && p.id != (sara?.id ?? '')).toList();
    final grandparents = allPersons.where((p) => p.generationHint == 7).toList();

    final effectiveDisplayName = _displayName.isNotEmpty
        ? _displayName
        : (profile?.displayName ?? activePersona?.displayName ?? sara?.displayName ?? 'Sara Wilson');
    final effectiveRoleTitle = activePersona?.roleTitle ?? (isAdmin ? 'Primary Admin • Archivist' : 'Active Family Member');
    final effectiveGeneration = activePersona?.generation ?? 'Generation 9';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // ===============================================================
            // 1. TOP FULL PHOTOGRAPHY HERO HEADER (Screen 3 Reference)
            // ===============================================================
            SliverToBoxAdapter(
              child: Container(
                height: 380,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Full-bleed photography image of active user
                      Image.asset(
                        activePersona?.avatarAsset ?? sara?.effectivePortraitAsset ?? 'assets/images/user_sara_portrait.jpg',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.35),
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primary,
                          child: Center(
                            child: Text(
                              effectiveDisplayName.isNotEmpty ? effectiveDisplayName[0] : '?',
                              style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      // Multi-stop cinematic dark gradient overlay for text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.65),
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.45),
                              Colors.black.withOpacity(0.92),
                            ],
                            stops: const [0.0, 0.28, 0.62, 1.0],
                          ),
                        ),
                      ),

                      // Header Overlay UI
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top bar: Living Heritage Profile badge + Copy ID + Share + Settings
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.38),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF38BDF8)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Living Heritage Profile',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(const ClipboardData(text: 'VANS-8842'));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Tree ID: VANS-8842 copied to clipboard!'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.38),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: Colors.white.withOpacity(0.22)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                                              const SizedBox(width: 5),
                                              Text(
                                                'VANS-8842',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: _showInviteDialog,
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.38),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withOpacity(0.22)),
                                          ),
                                          child: const Icon(
                                            Icons.share_outlined,
                                            size: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => _tabController.animateTo(3),
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.38),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withOpacity(0.22)),
                                          ),
                                          child: const Icon(
                                            Icons.settings_outlined,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Bottom Section: Verified badge, Name, Generation, Roles
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF22C55E),
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF22C55E).withOpacity(0.45),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              'VERIFIED LIVING MEMBER',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    effectiveDisplayName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.4,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.8),
                                          blurRadius: 14,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$effectiveGeneration • $effectiveRoleTitle',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      color: const Color(0xFFE2E8F0),
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.8),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Role & Branch Glass Badges
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      _buildGlassBadge(
                                        isAdmin ? 'Primary Admin' : 'Active Member',
                                        isAdmin ? const Color(0xFF38BDF8) : const Color(0xFF4ADE80),
                                      ),
                                      _buildGlassBadge('Cascadia Branch', Colors.white),
                                      _buildGlassBadge('Verified Canonical', const Color(0xFFFBBF24)),
                                    ],
                                  ),
                                ],
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

            // Quick Action Buttons (Edit Profile • View in Tree)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () => _openEditProfileSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(
                          'Edit Profile',
                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/tree'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border, width: 1.5),
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.account_tree_outlined, size: 16),
                        label: Text(
                          'View in Tree',
                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // 2. BENTO STATS METRICS ROW
            // ===============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Expanded(child: _buildMetricTile('Gen 9', 'Lineage Tier', Icons.timeline_rounded, const Color(0xFFE0F2FE), const Color(0xFF0284C7))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricTile('${allPersons.length}', 'Family Clan', Icons.groups_rounded, const Color(0xFFDCFCE7), const Color(0xFF16A34A))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricTile('10', 'Generations', Icons.schema_rounded, const Color(0xFFFEF3C7), const Color(0xFFD97706))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricTile('4', 'Vault Items', Icons.inventory_2_outlined, const Color(0xFFF3E8FF), const Color(0xFF9333EA))),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // 3. PERSISTENT NAVIGATION TABS
            // ===============================================================
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Family'),
                    Tab(text: 'Archives'),
                    Tab(text: 'Security'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Overview & Vital Biography
            _buildOverviewTab(),

            // Tab 2: Immediate Family Circle
            _buildFamilyCircleTab(spouse, children, parents, siblings, grandparents, isAdmin),

            // Tab 3: Archival Contributions & Timeline
            _buildArchivesTab(),

            // Tab 4: Account & Security
            _buildSecurityTab(isAdmin),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Overview & Biography
  // ---------------------------------------------------------------------------
  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Profile Completeness Progress Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF2563EB), size: 20),
                      const SizedBox(width: 8),
                      Text('Profile Completeness', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF1E3A8A))),
                    ],
                  ),
                  Text('95% Verified', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  value: 0.95,
                  minHeight: 6,
                  backgroundColor: Color(0xFFDBEAFE),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Direct lineage traced through Generation 1 Sir Archibald Vansora (1842). All vital dates & relationships canonical.',
                style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF3B82F6)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Biography Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Archivist Biography',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  InkWell(
                    onTap: () => _openEditProfileSheet(context),
                    child: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _bio,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.textPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Vital Record Information Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Canonical Vital Record',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              _buildVitalRow(Icons.badge_outlined, 'Full Name', '$_displayName ($_maidenName)'),
              const Divider(height: 20, color: AppColors.border),
              _buildVitalRow(Icons.cake_outlined, 'Birth Date', 'June 18, 1998 (Age 28)'),
              const Divider(height: 20, color: AppColors.border),
              _buildVitalRow(Icons.place_outlined, 'Birth Place', _birthPlace),
              const Divider(height: 20, color: AppColors.border),
              _buildVitalRow(Icons.home_outlined, 'Current Residence', _residence),
              const Divider(height: 20, color: AppColors.border),
              _buildVitalRow(Icons.fingerprint_rounded, 'National / Lineage Code', 'VANS-8842-GEN9'),
              const Divider(height: 20, color: AppColors.border),
              _buildVitalRow(Icons.workspace_premium_outlined, 'Branch Clan', 'Kensington–Vansora (Pacific NW)'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quick Family Tree jump banner
        InkWell(
          onTap: () => context.push('/tree'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: HeritageShadows.card,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View Sara in Living Family Tree',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        'Interactive horizontal branching diagram',
                        style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white70),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Immediate Family Circle
  // ---------------------------------------------------------------------------
  Widget _buildFamilyCircleTab(
    Person? spouse,
    List<Person> children,
    List<Person> parents,
    List<Person> siblings,
    List<Person> grandparents,
    bool isAdmin,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Action to add relative
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton.icon(
              onPressed: () => context.push('/admin/person/new'),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Add Family Relative Record'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        // Spouse Section
        if (spouse != null) ...[
          _buildSectionHeader('Spouse & Partner'),
          const SizedBox(height: 8),
          _buildRelativeCard(spouse, 'Spouse • Married Apr 12, 2021', '#FDE7EC'),
          const SizedBox(height: 18),
        ],

        // Children Section
        if (children.isNotEmpty) ...[
          _buildSectionHeader('Children (Generation 10)'),
          const SizedBox(height: 8),
          ...children.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRelativeCard(c, 'Child • Generation 10', '#F2F6DB'),
          )),
          const SizedBox(height: 18),
        ],

        // Parents Section
        if (parents.isNotEmpty) ...[
          _buildSectionHeader('Parents (Generation 8)'),
          const SizedBox(height: 8),
          ...parents.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRelativeCard(p, 'Parent • Generation 8', '#E6F3FD'),
          )),
          const SizedBox(height: 18),
        ],

        // Siblings Section
        if (siblings.isNotEmpty) ...[
          _buildSectionHeader('Brothers & Sisters (Generation 9)'),
          const SizedBox(height: 8),
          ...siblings.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRelativeCard(s, 'Sibling • Generation 9', '#F5EBE1'),
          )),
          const SizedBox(height: 18),
        ],

        // Grandparents Section
        if (grandparents.isNotEmpty) ...[
          _buildSectionHeader('Grandparents & Elders (Generation 7)'),
          const SizedBox(height: 8),
          ...grandparents.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRelativeCard(g, 'Grandparent • Generation 7', '#FDEEDB'),
          )),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Archival Contributions & Personal Milestones
  // ---------------------------------------------------------------------------
  Widget _buildArchivesTab() {
    final media = [
      {'title': '1842 Founding Charter', 'type': 'Canonical Document', 'date': 'Oct 1842', 'img': 'assets/images/vintage_vault_documents.jpg'},
      {'title': 'Sara Portrait (Original Archival)', 'type': 'Photographic Portrait', 'date': '2024', 'img': 'assets/images/user_sara_portrait.jpg'},
      {'title': 'Sir Archibald Kensington', 'type': 'Founding Patriarch', 'date': '1842', 'img': 'assets/images/archibald_portrait.jpg'},
      {'title': 'Matriarchs & Pillars Collection', 'type': 'Historical Album', 'date': '1890', 'img': 'assets/images/matriarch_portrait.jpg'},
    ];

    final milestones = [
      {'year': '1998', 'title': 'Born in Seattle, WA', 'desc': 'Born to David & Sophia Kensington in Pacific NW.'},
      {'year': '2016', 'title': 'High School Graduation', 'desc': 'Honored for genealogical research thesis.'},
      {'year': '2020', 'title': 'Degree in Historical Preservation', 'desc': 'University of Washington Archival Fellowship.'},
      {'year': '2021', 'title': 'Marriage to Thomas Wilson', 'desc': 'Married April 12 in Portland, Oregon.'},
      {'year': '2024', 'title': 'Birth of Maya Kensington', 'desc': 'Welcomed first child (Generation 10).'},
      {'year': '2026', 'title': 'Birth of Liam Wilson', 'desc': 'Welcomed second child to the living lineage.'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Personal Life Milestones
        Text(
          'Personal Life Milestones',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            children: milestones.asMap().entries.map((entry) {
              final idx = entry.key;
              final m = entry.value;
              final isLast = idx == milestones.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 48,
                          color: AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(m['year']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7))),
                              const SizedBox(width: 8),
                              Expanded(child: Text(m['title']!, style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(m['desc']!, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 22),

        // Contributed Archival Records Grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Archival Records & Vault',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            TextButton.icon(
              onPressed: () => context.push('/archive'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: const Text('Open Vault'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: media.length,
          itemBuilder: (context, index) {
            final item = media[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.8),
                boxShadow: HeritageShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        item['img']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item["type"]} • ${item["date"]}',
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Account & Security
  // ---------------------------------------------------------------------------
  Widget _buildSecurityTab(bool isAdmin) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Account Details Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Credentials & Contact',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              _buildVitalRow(Icons.email_outlined, 'Primary Email', _email),
              const Divider(height: 20, color: AppColors.border),
              _buildVitalRow(Icons.phone_outlined, 'Verified Phone', _phone),
              const Divider(height: 20, color: AppColors.border),
              _buildVitalRow(Icons.security_rounded, 'Two-Factor Authentication', 'Enabled (TOTP Authenticator)'),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Notification Preferences
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clan Notification Alerts',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage which lineage updates and alerts are sent to your verified email and push device.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text('Family Tree Edits & Branch Additions', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                value: _notifyTreeUpdates,
                onChanged: (val) => setState(() => _notifyTreeUpdates = val),
              ),
              const Divider(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text('Family ReUnion & Milestone Reminders', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                value: _notifyEvents,
                onChanged: (val) => setState(() => _notifyEvents = val),
              ),
              const Divider(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text('Birthday & Anniversary Notifications', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                value: _notifyBirthdays,
                onChanged: (val) => setState(() => _notifyBirthdays = val),
              ),
              const Divider(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text('Archival Vault Document Uploads', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                value: _notifyVault,
                onChanged: (val) => setState(() => _notifyVault = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Data Export & Sharing Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Management & Lineage Export',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showExportDialog,
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Export Data'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showInviteDialog,
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Invite Member'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Role Simulator
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: HeritageShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Multi-User Persona Switcher',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Seamlessly switch between family member accounts to evaluate role-based views and permissions.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              ...() {
                final currentProf = ref.watch(currentProfileProvider).valueOrNull;
                final activePers = ref.watch(currentPersonaProvider);
                return ref.watch(authRepositoryProvider).personas.map((persona) {
                  final isCurrent = (currentProf?.id == persona.id) || (activePers?.id == persona.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () async {
                        final authRepo = ref.read(authRepositoryProvider);
                        await authRepo.switchPersona(persona.id);
                        ref.read(currentUserRoleProvider.notifier).setRole(persona.role);
                        ref.read(userBranchPersonIdProvider.notifier).setPersonId(persona.id);
                        if (mounted) {
                          setState(() {
                            _displayName = persona.displayName;
                            _email = persona.email;
                          });
                        }
                        ref.invalidate(currentProfileProvider);
                        ref.invalidate(currentMembershipProvider);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched to ${persona.displayName} (${persona.roleTitle})'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.lightSage : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent ? AppColors.primary : AppColors.border,
                          width: isCurrent ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.paleSage,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: persona.avatarAsset != null
                                  ? Image.asset(persona.avatarAsset!, fit: BoxFit.cover)
                                  : Center(
                                      child: Text(
                                        persona.displayName.isNotEmpty ? persona.displayName[0] : '?',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  persona.displayName,
                                  style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                Text(
                                  '${persona.roleTitle} • ${persona.generation}',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            )
                          else
                            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList();
            }(),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Sign Out Button
        ElevatedButton.icon(
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            ref.invalidate(currentProfileProvider);
            ref.invalidate(currentMembershipProvider);
            if (!mounted) return;
            context.go('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: Text('Sign Out & Lock Vault Session', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Widgets
  // ---------------------------------------------------------------------------
  Widget _buildGlassBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMetricTile(String value, String label, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    );
  }

  Widget _buildRelativeCard(Person person, String relationNote, String pastelHex) {
    final hexColor = Color(int.parse(pastelHex.replaceFirst('#', '0xFF')));

    return InkWell(
      onTap: () => context.push('/people/${person.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: HeritageShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hexColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.asset(
                  person.effectivePortraitAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      person.initials,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.displayName,
                    style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    relationNote,
                    style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _tabBar,
          const Divider(height: 1, thickness: 1, color: AppColors.border),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
