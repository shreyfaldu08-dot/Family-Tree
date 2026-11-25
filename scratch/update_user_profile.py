# Python script to update user_profile_screen.dart with Image 1 and Image 2 specifications

hero_replacement = '''            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  height: 395,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Full-bleed photography image background (replacing flat blue card)
                        Image.asset(
                          activePersona?.avatarAsset ?? sara?.effectivePortraitAsset ?? 'assets/images/user_sara_portrait.jpg',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -0.35),
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.primary,
                            child: Center(
                              child: Text(
                                presentationName.isNotEmpty ? presentationName[0] : 'S',
                                style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        // Cinematic gradient overlay ensuring maximum contrast and legibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF163E72).withOpacity(0.88),
                                const Color(0xFF0F1E36).withOpacity(0.72),
                                const Color(0xFF0A1526).withOpacity(0.95),
                              ],
                              stops: const [0.0, 0.48, 1.0],
                            ),
                          ),
                        ),

                        // Header Card Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Bar: Living Heritage Profile + VANS-8842 + Settings
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Living Heritage Profile',
                                    style: GoogleFonts.poppins(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
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
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.copy_rounded, size: 13, color: Colors.white),
                                              const SizedBox(width: 5),
                                              Text(
                                                'VANS-8842',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
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
                                            color: Colors.white.withOpacity(0.18),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withOpacity(0.25)),
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

                              // Center Section: Circular Avatar with Green Checkmark + Name + Title + Badges
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Circular Portrait Avatar with Green Checkmark
                                  Center(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 86,
                                          height: 86,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              activePersona?.avatarAsset ?? sara?.effectivePortraitAsset ?? 'assets/images/user_sara_portrait.jpg',
                                              fit: BoxFit.cover,
                                              alignment: const Alignment(0, -0.3),
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: AppColors.primary,
                                                child: Center(
                                                  child: Text(
                                                    presentationName.isNotEmpty ? presentationName[0] : 'S',
                                                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 1,
                                          right: 1,
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF22C55E),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2.2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.25),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Name
                                  Text(
                                    presentationName,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.8),
                                          blurRadius: 12,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 3),

                                  // Subtitle: Generation & Title
                                  Text(
                                    '$effectiveGeneration • $effectiveRoleTitle',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFFCBD5E1),
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.7),
                                          blurRadius: 8,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Badges Row
                                  Wrap(
                                    alignment: WrapAlignment.center,
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

                              // Bottom Row: Edit Profile (White) and View in Tree (Translucent)
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 46,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _openEditProfileSheet(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(0xFF163E72),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF163E72)),
                                        label: Text(
                                          'Edit Profile',
                                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 46,
                                      child: OutlinedButton.icon(
                                        onPressed: () => context.push('/tree'),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(0.18),
                                          foregroundColor: Colors.white,
                                          side: BorderSide(color: Colors.white.withOpacity(0.35)),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        icon: const Icon(Icons.account_tree_outlined, size: 16, color: Colors.white),
                                        label: Text(
                                          'View in Tree',
                                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
'''

security_tab_replacement = '''  // ---------------------------------------------------------------------------
  // Tab 4: Account & Privacy (Matching Image 1 Specifications)
  // ---------------------------------------------------------------------------
  Widget _buildSecurityTab(bool isAdmin) {
    final activePersona = ref.watch(currentPersonaProvider);
    final currentRole = ref.watch(currentUserRoleProvider);
    final isPrimaryAdmin = currentRole == MemberRole.primaryAdmin;
    final currentProf = ref.watch(currentProfileProvider).valueOrNull;

    final presentationName = (_maidenName.isNotEmpty && !_displayName.contains(_maidenName))
        ? '$_displayName ($_maidenName)'
        : (_displayName.isNotEmpty ? _displayName : (activePersona?.displayName ?? 'Sara Wilson'));
    final effectiveEmail = _email.isNotEmpty ? _email : (activePersona?.email ?? 'sara.wilson@kensingtonlegacy.org');

    String roleDisplayLabel;
    switch (currentRole) {
      case MemberRole.primaryAdmin:
        roleDisplayLabel = 'Role: Primary Admin (Write Authorization)';
        break;
      case MemberRole.branchElder:
        roleDisplayLabel = 'Role: Branch Elder (Advisory Approval)';
        break;
      case MemberRole.contributor:
        roleDisplayLabel = 'Role: Branch Contributor (Branch Write)';
        break;
      case MemberRole.viewer:
        roleDisplayLabel = 'Role: Approved Member (Strict Read-Only)';
        break;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Title: Account & Privacy
        Center(
          child: Text(
            'Account & Privacy',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 1. Account Details Card (Image 1 Style)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                ),
                child: ClipOval(
                  child: activePersona?.avatarAsset != null
                      ? Image.asset(activePersona!.avatarAsset!, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            presentationName.isNotEmpty ? presentationName[0].toUpperCase() : 'S',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0369A1),
                            ),
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
                      presentationName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      effectiveEmail,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isPrimaryAdmin ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        roleDisplayLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPrimaryAdmin ? const Color(0xFF0369A1) : const Color(0xFF475569),
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

        // 2. Authorization Role Testing (Image 1 Style)
        Text(
          'Authorization Role Testing',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experience Simulator',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Switch between Primary Admin and Read-Only Viewer mode to verify that viewers cannot create, edit, or modify canonical records.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () async {
                          final authRepo = ref.read(authRepositoryProvider);
                          await authRepo.switchPersona('p_guest_relative');
                          ref.read(currentUserRoleProvider.notifier).setRole(MemberRole.viewer);
                          ref.read(userBranchPersonIdProvider.notifier).setPersonId('p_guest_relative');
                          if (mounted) {
                            setState(() {
                              _displayName = 'Guest Relative (Explorer)';
                              _maidenName = '';
                              _email = 'guest.relative@clan.heritage';
                            });
                          }
                          ref.invalidate(currentProfileProvider);
                          ref.invalidate(currentMembershipProvider);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Switched to Read-Only Viewer mode!'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: !isPrimaryAdmin ? const Color(0xFF1E4E79) : const Color(0xFFF8FAFC),
                          foregroundColor: !isPrimaryAdmin ? Colors.white : AppColors.textPrimary,
                          side: BorderSide(
                            color: !isPrimaryAdmin ? const Color(0xFF1E4E79) : AppColors.border,
                            width: !isPrimaryAdmin ? 1.8 : 1.0,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Viewer Mode',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () async {
                          final authRepo = ref.read(authRepositoryProvider);
                          await authRepo.switchPersona('p_gen9_sara');
                          ref.read(currentUserRoleProvider.notifier).setRole(MemberRole.primaryAdmin);
                          ref.read(userBranchPersonIdProvider.notifier).setPersonId('p_gen9_sara');
                          if (mounted) {
                            setState(() {
                              _displayName = 'Sara Wilson';
                              _maidenName = 'Kensington';
                              _email = 'sara.wilson@kensingtonlegacy.org';
                            });
                          }
                          ref.invalidate(currentProfileProvider);
                          ref.invalidate(currentMembershipProvider);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Switched to Primary Admin mode!'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPrimaryAdmin ? const Color(0xFF1E4E79) : const Color(0xFFF8FAFC),
                          foregroundColor: isPrimaryAdmin ? Colors.white : AppColors.textPrimary,
                          elevation: 0,
                          side: BorderSide(
                            color: isPrimaryAdmin ? const Color(0xFF1E4E79) : AppColors.border,
                            width: isPrimaryAdmin ? 1.8 : 1.0,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Admin Mode',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. Prominent Red Sign Out Button (Image 1 Style)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              ref.invalidate(currentProfileProvider);
              ref.invalidate(currentMembershipProvider);
              if (!context.mounted) return;
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(
              'Sign Out & Clear Secure Session',
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // 4. Multi-User Persona Switcher (Extended Evaluation Catalog)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Persona Switcher',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Select any family persona to evaluate tree viewing, contributor branching, and admin abilities.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              ...() {
                return ref.watch(authRepositoryProvider).personas.map((persona) {
                  final isCurrent = (currentProf?.id == persona.id) || (activePersona?.id == persona.id);
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
                            _maidenName = (persona.id == 'p_gen9_sara') ? 'Kensington' : '';
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

        const SizedBox(height: 20),

        // 5. Account Credentials & Contact
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
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

        const SizedBox(height: 20),

        // 6. Notification Preferences
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
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

        const SizedBox(height: 20),

        // 7. Data Management & Lineage Export
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
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
      ],
    );
  }
'''

with open('lib/features/profile/presentation/user_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace Hero & Quick Action buttons
# Find starting line: '            SliverToBoxAdapter(\n              child: Container(\n                height: 380,'
start_marker = '            SliverToBoxAdapter(\n              child: Container(\n                height: 380,'
end_marker = '            // ===============================================================\n            // 2. BENTO STATS METRICS ROW'

start_pos = content.find(start_marker)
end_pos = content.find(end_marker)

if start_pos == -1 or end_pos == -1:
    print(f"Error finding markers! start_pos={start_pos}, end_pos={end_pos}")
    exit(1)

content = content[:start_pos] + hero_replacement + '\n' + content[end_pos:]

# 2. Replace Tab(text: 'Security') with Tab(text: 'Account & Privacy')
content = content.replace("Tab(text: 'Security')", "Tab(text: 'Account & Privacy')")

# 3. Replace _buildSecurityTab
sec_start_marker = '  // ---------------------------------------------------------------------------\n  // Tab 4: Account & Security\n  // ---------------------------------------------------------------------------\n  Widget _buildSecurityTab(bool isAdmin) {'
sec_end_marker = '  // ---------------------------------------------------------------------------\n  // Helper Widgets\n  // ---------------------------------------------------------------------------'

sec_start_pos = content.find(sec_start_marker)
sec_end_pos = content.find(sec_end_marker)

if sec_start_pos == -1 or sec_end_pos == -1:
    print(f"Error finding security markers! sec_start_pos={sec_start_pos}, sec_end_pos={sec_end_pos}")
    exit(1)

content = content[:sec_start_pos] + security_tab_replacement + '\n' + content[sec_end_pos:]

with open('lib/features/profile/presentation/user_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Successfully updated user_profile_screen.dart!")
