file_path = 'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update _buildFamilyConnectionSection
old_connection = """        // Subsection 1: Upcoming Celebrations & Milestones Strip
        _buildUpcomingCelebrationsRibbon(context),

        const SizedBox(height: 14),

        // Subsection 2: Annual Kensington Family Gathering Banner
        _buildAnnualGatheringCard(context),

        const SizedBox(height: 14),

        // Subsection 3: Grandfather's Brother & Extended Cousins Branch (Card 1)
        _buildGrandfatherBrothersAndCousinsCard(context),"""

new_connection = """        // Subsection 1: Annual Kensington Family Gathering Banner
        _buildAnnualGatheringCard(context),

        const SizedBox(height: 14),

        // Subsection 2: Grandfather's Brother & Extended Cousins Branch
        _buildGrandfatherBrothersAndCousinsCard(context),

        const SizedBox(height: 14),

        // Subsection 3: Upcoming Birthdays & Anniversaries Calendar Card
        _buildBirthdaysAndAnniversariesCalendarCard(context),"""

if old_connection in content:
    content = content.replace(old_connection, new_connection)
    print("Updated _buildFamilyConnectionSection calls successfully!")
else:
    print("WARNING: old_connection not found!")

# 2. Replace _buildUpcomingCelebrationsRibbon and _buildMilestoneCard with the new calendar card
start_marker = "  // ---------------------------------------------------------------------------\n  // Upcoming Celebrations Ribbon\n  // ---------------------------------------------------------------------------\n  Widget _buildUpcomingCelebrationsRibbon(BuildContext context) {"
end_marker = "  // ---------------------------------------------------------------------------\n  // Annual Gathering Banner (Cinematic Full Cover Bento Style)"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    new_calendar_methods = """  // ---------------------------------------------------------------------------
  // Birthdays & Anniversaries Calendar Card (Upcoming Milestones & Remembrance)
  // ---------------------------------------------------------------------------
  Widget _buildBirthdaysAndAnniversariesCalendarCard(BuildContext context) {
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
                      'Birthdays & Anniversaries',
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Upcoming celebrations, milestones & remembrance days',
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '3 UPCOMING',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Milestone 1: Cousin Oliver's 22nd Birthday
          _buildCalendarMilestoneTile(
            context: context,
            month: 'NOV',
            day: '14',
            title: "Oliver's 22nd Birthday",
            subtitle: 'Cousin Brother • Generation 9',
            badgeText: 'IN 16 DAYS',
            badgeColor: const Color(0xFF7C3AED),
            badgeBgColor: const Color(0xFFF5F3FF),
            imageAsset: 'assets/images/modern_young_man.jpg',
            actionLabel: 'Send Wish',
            actionIcon: Icons.cake_outlined,
            onAction: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Birthday greeting scheduled for Oliver on Nov 14! 🎂"),
                backgroundColor: AppColors.primary,
              ),
            ),
            onCardTap: () => context.push('/people/p_gen9_oliver'),
          ),

          const SizedBox(height: 10),

          // Milestone 2: Parents David & Sophia's 34th Anniversary
          _buildCalendarMilestoneTile(
            context: context,
            month: 'DEC',
            day: '04',
            title: "David & Sophia's Anniversary",
            subtitle: 'Parents • Married Dec 4, 1992 (Lakeview)',
            badgeText: '34 YEARS',
            badgeColor: const Color(0xFFD97706),
            badgeBgColor: const Color(0xFFFFFBEB),
            imageAsset: 'assets/images/modern_father.jpg',
            secondaryImageAsset: 'assets/images/vintage_lady_portrait.jpg',
            actionLabel: 'Celebrate',
            actionIcon: Icons.favorite_border_rounded,
            onAction: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Anniversary celebration note saved for David & Sophia! 🥂"),
                backgroundColor: AppColors.primary,
              ),
            ),
            onCardTap: () => context.push('/people/p_gen8_david'),
          ),

          const SizedBox(height: 10),

          // Milestone 3: Grandfather Julian Kensington Memorial Day
          _buildCalendarMilestoneTile(
            context: context,
            month: 'JAN',
            day: '08',
            title: "Julian Kensington Memorial",
            subtitle: 'Grandfather • 1930 — 2012 (Gen 7)',
            badgeText: 'REMEMBRANCE',
            badgeColor: const Color(0xFF475569),
            badgeBgColor: const Color(0xFFF1F5F9),
            imageAsset: 'assets/images/vintage_elder_father.jpg',
            actionLabel: 'View Vault',
            actionIcon: Icons.history_edu_rounded,
            onAction: () => context.push('/archive'),
            onCardTap: () => context.push('/people/p_gen7_julian'),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Action footer
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viewing All Family Dates & Milestones for 2026'),
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
                    'View Full 2026 Family Milestone Calendar',
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

  // ---------------------------------------------------------------------------
  // Calendar Milestone Tile Helper
  // ---------------------------------------------------------------------------
  Widget _buildCalendarMilestoneTile({
    required BuildContext context,
    required String month,
    required String day,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBgColor,
    required String imageAsset,
    String? secondaryImageAsset,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onAction,
    required VoidCallback onCardTap,
  }) {
    return InkWell(
      onTap: onCardTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(0.8), width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Calendar Date Box
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeColor.withOpacity(0.25), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    month,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    day,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Avatar or Dual Avatar
            if (secondaryImageAsset != null)
              SizedBox(
                width: 42,
                height: 38,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset(imageAsset, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.paleBlue,
                      child: Icon(Icons.person, size: 18, color: badgeColor),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 10),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.inter(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
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
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action Pill Button
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(actionIcon, size: 11, color: AppColors.primary),
                    const SizedBox(width: 3.5),
                    Text(
                      actionLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

"""
    content = content[:start_idx] + new_calendar_methods + content[end_idx:]
    print("Replaced old celebrations ribbon with Birthdays & Anniversaries calendar card!")
else:
    print(f"WARNING: start_idx={start_idx}, end_idx={end_idx}")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated dashboard_screen.dart successfully!")

