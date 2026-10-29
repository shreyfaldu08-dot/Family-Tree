file_path = 'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = "  // ---------------------------------------------------------------------------\n  // Birthdays & Anniversaries Calendar Card (Luxury Blue & Beige Gradient Styling)\n  // ---------------------------------------------------------------------------\n  Widget _buildBirthdaysAndAnniversariesCalendarCard(BuildContext context) {"
end_marker = "  // ---------------------------------------------------------------------------\n  // Annual Gathering Banner (Cinematic Full Cover Bento Style)"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print(f"Error: start_idx={start_idx}, end_idx={end_idx}")
    exit(1)

new_square_grid_calendar = """  // ---------------------------------------------------------------------------
  // Birthdays & Anniversaries Calendar Card (Consistent 2x2 Square Grid & Blue/Beige Palette)
  // ---------------------------------------------------------------------------
  Widget _buildBirthdaysAndAnniversariesCalendarCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF16325B), // Deep Dusk Blue
            Color(0xFF0D1E36), // Rich Midnight Navy
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFC7B198).withOpacity(0.35), // Warm Beige Hairline
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1E36).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Cream & Beige Typography on Dusk Blue Gradient)
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
                        color: const Color(0xFFD6C8B4), // Warm Sand / Beige
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C8B4).withOpacity(0.18),
                  borderRadius: HeritageCurves.pill,
                  border: Border.all(
                    color: const Color(0xFFD6C8B4).withOpacity(0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: Color(0xFFEFE8DC),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4 MILESTONES',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEFE8DC),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x2 Square Grid of Milestones (Consistent with Cousins Branch layout)
          Row(
            children: [
              // Top-Left: Oliver's 22nd Birthday
              Expanded(
                child: _buildSquareMilestoneCard(
                  context: context,
                  month: 'NOV',
                  day: '14',
                  title: "Oliver's 22nd",
                  subtitle: 'Cousin Brother • Gen 9',
                  badgeText: 'IN 16 DAYS',
                  badgeColor: const Color(0xFF7C3AED),
                  badgeBgColor: const Color(0xFFF5F3FF),
                  imageAsset: 'assets/images/modern_young_man.jpg',
                  actionLabel: 'Wish 🎂',
                  actionIcon: Icons.cake_outlined,
                  onAction: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Birthday greeting scheduled for Oliver on Nov 14! 🎂"),
                      backgroundColor: Color(0xFF16325B),
                    ),
                  ),
                  onCardTap: () => context.push('/people/p_gen9_oliver'),
                ),
              ),
              const SizedBox(width: 10),
              // Top-Right: Parents David & Sophia's 34th Anniversary
              Expanded(
                child: _buildSquareMilestoneCard(
                  context: context,
                  month: 'DEC',
                  day: '04',
                  title: "Parents' 34th",
                  subtitle: 'David & Sophia • Gen 8',
                  badgeText: '34 YEARS',
                  badgeColor: const Color(0xFFB45309),
                  badgeBgColor: const Color(0xFFFEF3C7),
                  imageAsset: 'assets/images/modern_father.jpg',
                  secondaryImageAsset: 'assets/images/vintage_lady_portrait.jpg',
                  actionLabel: 'Cheer 🥂',
                  actionIcon: Icons.favorite_border_rounded,
                  onAction: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Anniversary celebration note saved for David & Sophia! 🥂"),
                      backgroundColor: Color(0xFF16325B),
                    ),
                  ),
                  onCardTap: () => context.push('/people/p_gen8_david'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Bottom-Left: Grandfather Julian Kensington Memorial Day
              Expanded(
                child: _buildSquareMilestoneCard(
                  context: context,
                  month: 'JAN',
                  day: '08',
                  title: "Julian's Memorial",
                  subtitle: 'Grandfather • 1930–2012',
                  badgeText: 'MEMORIAL',
                  badgeColor: const Color(0xFF475569),
                  badgeBgColor: const Color(0xFFF1F5F9),
                  imageAsset: 'assets/images/vintage_elder_father.jpg',
                  actionLabel: 'Vault 📜',
                  actionIcon: Icons.history_edu_rounded,
                  onAction: () => context.push('/archive'),
                  onCardTap: () => context.push('/people/p_gen7_julian'),
                ),
              ),
              const SizedBox(width: 10),
              // Bottom-Right: Baby Noah 1st Month Milestone (Generation 10)
              Expanded(
                child: _buildSquareMilestoneCard(
                  context: context,
                  month: 'FEB',
                  day: '14',
                  title: "Baby Noah",
                  subtitle: 'Elena • Generation 10',
                  badgeText: 'NEWBORN',
                  badgeColor: const Color(0xFF059669),
                  badgeBgColor: const Color(0xFFECFDF5),
                  imageAsset: 'assets/images/child_portrait.jpg',
                  actionLabel: 'Love ❤️',
                  actionIcon: Icons.favorite_rounded,
                  onAction: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You sent love to Baby Noah and Elena! ❤️"),
                      backgroundColor: Color(0xFF16325B),
                    ),
                  ),
                  onCardTap: () => context.push('/people/p_gen9_elena'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: const Color(0xFFC7B198).withOpacity(0.22)),
          const SizedBox(height: 10),

          // Action footer in Warm Champagne
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viewing All Family Dates & Milestones for 2026'),
                  backgroundColor: Color(0xFF16325B),
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
                      color: const Color(0xFFE5D9C8), // Champagne Beige
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: Color(0xFFE5D9C8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Square Milestone Card Helper (Consistent Square Design in Linen & Navy)
  // ---------------------------------------------------------------------------
  Widget _buildSquareMilestoneCard({
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2), // Warm Linen / Beige Tile
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2D6C3), // Soft Sand Hairline Border
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Date Box & Portrait Avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Calendar Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3863), // Deep Navy
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFC7B198).withOpacity(0.4),
                      width: 0.7,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        month,
                        style: GoogleFonts.inter(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFDFCEB5), // Champagne Gold
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 3.5),
                      Text(
                        day,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Avatar or Stacked Avatars
                if (secondaryImageAsset != null)
                  SizedBox(
                    width: 44,
                    height: 30,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2D6C3), width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Image.asset(imageAsset, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2D6C3), width: 1.5),
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2D6C3), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFEFE8DC),
                          child: const Icon(Icons.person, size: 16, color: Color(0xFF16325B)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Bold Event Title
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F2447), // Deep Navy text
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Subtitle
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5A6B82),
              ),
            ),
            const SizedBox(height: 8),

            // Milestone Badge & Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: badgeColor.withOpacity(0.2), width: 0.6),
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

                // Interactive Pill Action
                InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF16325B).withOpacity(0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(actionIcon, size: 9.5, color: const Color(0xFF16325B)),
                        const SizedBox(width: 3),
                        Text(
                          actionLabel,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16325B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

"""

content = content[:start_idx] + new_square_grid_calendar + content[end_idx:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated dashboard_screen.dart with consistent 2x2 square milestone grid successfully!")

