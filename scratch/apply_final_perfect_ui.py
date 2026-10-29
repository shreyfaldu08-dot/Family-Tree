import re

file_path = 'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove temporary bulletin state variables from _DashboardScreenState
content = re.sub(
    r'  bool _babyLiked = false;\s*int _babyLikes = 18;\s*bool _lucasCheered = false;\s*int _lucasCheers = 15;\s*',
    '',
    content
)

# 2. Update _buildBentoPersonCard to use 22px squircle radius, translucent frosted top trailing icon, and FittedBox single-line name (never wraps, never truncates)
old_bento_person_card = """  Widget _buildBentoPersonCard({
    required BuildContext context,
    required String rolePill,
    required String name,
    required String subtitle,
    required String imageAsset,
    required VoidCallback onTap,
    Widget? topTrailingWidget,
    double height = 155,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.14),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
          color: AppColors.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3D6A),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 36),
                  ),
                ),
              ),
            ),

            // Smooth dark gradient overlay for deep contrast & readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                    const Color(0xFF0B192C).withOpacity(0.92),
                  ],
                ),
              ),
            ),

            // Inset hairline border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.9),
              ),
            ),

            // 1. Role Pill Badge (Top Left)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.6),
                    ),
                    child: Text(
                      rolePill,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Top Trailing Action or Circular Arrow Button (Top Right)
            Positioned(
              top: 8,
              right: 8,
              child: topTrailingWidget ??
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),
            ),

            // 3. Text Content (Full Bottom Width - Natural 2-Line Flow)
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

new_bento_person_card = """  Widget _buildBentoPersonCard({
    required BuildContext context,
    required String rolePill,
    required String name,
    required String subtitle,
    required String imageAsset,
    required VoidCallback onTap,
    Widget? topTrailingWidget,
    double height = 155,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          color: AppColors.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3D6A),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 36),
                  ),
                ),
              ),
            ),

            // Smooth dark gradient overlay for deep contrast & readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                    const Color(0xFF0B192C).withOpacity(0.92),
                  ],
                ),
              ),
            ),

            // Inset hairline border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.8),
              ),
            ),

            // 1. Role Pill Badge (Top Left)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.6),
                    ),
                    child: Text(
                      rolePill,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Top Trailing Action: Frosted Translucent Minimal Glass Icon
            Positioned(
              top: 8,
              right: 8,
              child: topTrailingWidget ??
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.24),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.35), width: 0.7),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
            ),

            // 3. Text Content: Single Line Fitted (Never cut, never pushed below)
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

if old_bento_person_card in content:
    content = content.replace(old_bento_person_card, new_bento_person_card)
    print("Replaced _buildBentoPersonCard successfully")
else:
    print("WARNING: old_bento_person_card not found directly!")

# 3. Update call in _buildFamilyConnectionSection to include BOTH requested cards
old_connection_calls = """        // Subsection 2: Annual Kensington Family Gathering Banner
        _buildAnnualGatheringCard(context),

        const SizedBox(height: 14),

        // Subsection 3: Family Bulletin & Life Updates (Living Moments & Milestones)
        _buildFamilyBulletinSection(context),"""

new_connection_calls = """        // Subsection 2: Annual Kensington Family Gathering Banner
        _buildAnnualGatheringCard(context),

        const SizedBox(height: 14),

        // Subsection 3: Grandfather's Brother & Extended Cousins Branch (Card 1)
        _buildGrandfatherBrothersAndCousinsCard(context),

        const SizedBox(height: 14),

        // Subsection 4: Ancestral Origins & 246-Year Migration Journey (Card 2)
        _buildAncestralOriginsAndMigrationCard(context),"""

if old_connection_calls in content:
    content = content.replace(old_connection_calls, new_connection_calls)
    print("Updated _buildFamilyConnectionSection calls successfully")
else:
    print("WARNING: old_connection_calls not found!")

# 4. Replace _buildFamilyBulletinSection with the two new cards implementation
old_bulletin_marker = "  // ---------------------------------------------------------------------------\n  // Option 1: Family Bulletin & Life Updates (Realistic Living Feed & Milestones)\n  // ---------------------------------------------------------------------------\n  Widget _buildFamilyBulletinSection(BuildContext context) {"
end_marker = "  // ---------------------------------------------------------------------------\n  // 6. Big CTA Button: Explore All Documented Ancestors (Luxury Dusk Blue Banner)\n  // ---------------------------------------------------------------------------"

start_idx = content.find(old_bulletin_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    two_cards_code = """  // ---------------------------------------------------------------------------
  // Card 1: Grandfather's Brother & Extended Cousins Branch
  // (Great-Uncle William's Lineage, Richard & Living 2nd Cousins Oliver/Clara)
  // ---------------------------------------------------------------------------
  Widget _buildGrandfatherBrothersAndCousinsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Grandfather's Brother & Cousins Branch",
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Great-Uncle William's lineage & living cousins in Gen 9",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: HeritageCurves.pill,
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Text(
                  '6 RELATIVES',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Relative Row 1: Great-Uncle William Kensington (Grandfather's brother)
          _buildCollateralRelativeTile(
            context: context,
            rolePill: 'GREAT-UNCLE',
            name: 'William Kensington',
            subtitle: "Julian's younger brother • 1932 — 2018",
            relationDetail: 'Founder of Edinburgh Architectural Foundry branch',
            imageAsset: 'assets/images/vintage_elder_father.jpg',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Viewing Great-Uncle William Kensington's branch"),
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Relative Row 2: Richard Kensington (William's son, 1st Cousin once removed)
          _buildCollateralRelativeTile(
            context: context,
            rolePill: '1ST COUSIN 1R',
            name: 'Richard Kensington',
            subtitle: "William's son • b. 1964 • Edinburgh Branch",
            relationDetail: 'Senior Conservation Architect • Preserving family archives',
            imageAsset: 'assets/images/modern_father.jpg',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Viewing Cousin Richard Kensington's profile"),
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Relative Row 3: Oliver & Clara Kensington (Richard's children, 2nd Cousins - Gen 9)
          _buildCollateralRelativeTile(
            context: context,
            rolePill: '2ND COUSINS • GEN 9',
            name: 'Oliver & Clara Kensington',
            subtitle: "Richard's children • b. 2004 & 2006 (Living)",
            relationDetail: 'Oliver (Digital Design) & Clara (Heritage Documentarian)',
            imageAsset: 'assets/images/modern_young_man.jpg',
            secondaryImageAsset: 'assets/images/child_portrait.jpg',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Viewing Cousin Oliver & Clara Kensington"),
                backgroundColor: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Action footer
          InkWell(
            onTap: () => context.push('/tree'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore Collateral Cousins Branch in Tree',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper tile for extended / collateral family members
  Widget _buildCollateralRelativeTile({
    required BuildContext context,
    required String rolePill,
    required String name,
    required String subtitle,
    required String relationDetail,
    required String imageAsset,
    String? secondaryImageAsset,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.7), width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar or dual avatar stack
            if (secondaryImageAsset != null)
              SizedBox(
                width: 48,
                height: 42,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 1,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: HeritageShadows.card,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset(imageAsset, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 1,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: HeritageShadows.card,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset(secondaryImageAsset, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: HeritageShadows.card,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.paleBlue,
                      child: const Icon(Icons.person, size: 22, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.paleBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rolePill,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    relationDetail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.primary.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 2: Ancestral Origins & 246-Year Migration Journey
  // (From 1780 Inverness/Edinburgh, Scotland -> 1862 Ohio -> Lakeview WA Seat)
  // ---------------------------------------------------------------------------
  Widget _buildAncestralOriginsAndMigrationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ancestral Origins & Migration',
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '246-year transatlantic journey across 10 generations',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: HeritageCurves.pill,
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Text(
                  '1780 — PRESENT',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Migration Step 1: Edinburgh & Inverness, Scotland (1780)
          _buildMigrationStopItem(
            year: '1780',
            location: 'Inverness & Edinburgh, Scotland',
            generation: 'GEN 1 • ARCHIBALD KENSINGTON',
            description: 'Stone masonry guild founder on Royal Mile; clan ancestral hearth.',
            isFirst: true,
            isLast: false,
          ),

          // Migration Step 2: Ohio Valley Homestead (1862)
          _buildMigrationStopItem(
            year: '1862',
            location: 'Ohio Valley Homestead, OH',
            generation: 'GEN 4 • ROBERT KENSINGTON',
            description: 'Transatlantic voyage aboard SS Caledonia; settled timber farmland.',
            isFirst: false,
            isLast: false,
          ),

          // Migration Step 3: Lakeview Estate, Washington (1912 - Present)
          _buildMigrationStopItem(
            year: '1912',
            location: 'Lakeview Estate, WA — Present',
            generation: 'GEN 7 TO GEN 10 • CONTEMPORARY',
            description: 'Pacific Northwest homeland; architectural studio & reunion grounds.',
            isFirst: false,
            isLast: true,
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Footer Action
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Interactive Historical Migration Map & Routes'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Interactive Migration Route Map',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.map_outlined, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper migration stop timeline step
  Widget _buildMigrationStopItem({
    required String year,
    required String location,
    required String generation,
    required String description,
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Year badge on left
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                year,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Timeline Node and Line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isLast ? const Color(0xFF10B981) : AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (isLast ? const Color(0xFF10B981) : AppColors.primary).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      generation,
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

"""
    content = content[:start_idx] + two_cards_code + content[end_idx:]
    print("Replaced _buildFamilyBulletinSection with the two new cards!")
else:
    print(f"ERROR: start_idx={start_idx}, end_idx={end_idx}")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Finished writing dashboard_screen.dart")

