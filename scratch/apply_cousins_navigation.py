file_path = 'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = "          // 2x2 Grid of Relatives (Matching the Reference Image style)\n          Row("
end_marker = "  // ---------------------------------------------------------------------------\n  // Card 2: Ancestral Origins & 246-Year Migration Journey"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print(f"Error: start_idx={start_idx}, end_idx={end_idx}")
    exit(1)

new_grid_code = """          // 2x2 Grid of Relatives (Explicit Cousins & Extended Branch with Live Navigation)
          Row(
            children: [
              // Top-Left: Cousin Brother (Oliver)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  title: 'Cousin Brother',
                  personName: 'Oliver Kensington',
                  rolePill: 'COUSIN',
                  imageAsset: 'assets/images/modern_young_man.jpg',
                  ringColor: const Color(0xFF8B5CF6),
                  pillBgColor: const Color(0xFFF5F3FF),
                  sweepAngle: 5.0,
                  onTap: () => context.push('/people/p_gen9_oliver'),
                ),
              ),
              const SizedBox(width: 10),
              // Top-Right: Cousin Sister (Clara)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  title: 'Cousin Sister',
                  personName: 'Clara Kensington',
                  rolePill: 'COUSIN',
                  imageAsset: 'assets/images/child_portrait.jpg',
                  ringColor: const Color(0xFFEC4899),
                  pillBgColor: const Color(0xFFFDF2F8),
                  sweepAngle: 4.2,
                  onTap: () => context.push('/people/p_gen9_clara'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Bottom-Left: Grandfather's Brother (William)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  title: "Grandfather's Brother",
                  personName: 'William Kensington',
                  rolePill: 'GREAT-UNCLE',
                  imageAsset: 'assets/images/vintage_elder_father.jpg',
                  ringColor: const Color(0xFF26538D),
                  pillBgColor: const Color(0xFFEBF3FC),
                  sweepAngle: 4.8,
                  onTap: () => context.push('/people/p_gen7_william'),
                ),
              ),
              const SizedBox(width: 10),
              // Bottom-Right: Cousin's Father / Uncle (Richard)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  title: "Cousin's Father",
                  personName: 'Richard Kensington',
                  rolePill: 'UNCLE',
                  imageAsset: 'assets/images/modern_father.jpg',
                  ringColor: const Color(0xFF4F46E5),
                  pillBgColor: const Color(0xFFEEF2FF),
                  sweepAngle: 4.4,
                  onTap: () => context.push('/people/p_gen8_richard'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Action footer
          InkWell(
            onTap: () => context.push('/tree?personId=p_gen9_oliver'),
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

  // ---------------------------------------------------------------------------
  // Reference-Style Relative Card (Avatar + Colored Arc Ring + Title + Subtitle)
  // ---------------------------------------------------------------------------
  Widget _buildReferenceStyleRelativeCard({
    required BuildContext context,
    required String title,
    required String personName,
    required String rolePill,
    required String imageAsset,
    required Color ringColor,
    required Color pillBgColor,
    required double sweepAngle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.85), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: ringColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top: Arc Ring Portrait Avatar & Role Pill Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(
                    painter: _HeritageArcRingPainter(
                      color: ringColor,
                      sweepAngle: sweepAngle,
                      strokeWidth: 2.3,
                    ),
                    child: Center(
                      child: Container(
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
                              child: Icon(Icons.person, size: 20, color: ringColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ringColor.withOpacity(0.25), width: 0.6),
                  ),
                  child: Text(
                    rolePill,
                    style: GoogleFonts.inter(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                      color: ringColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Bold Title: e.g. "Cousin Brother", "Cousin Sister", "Grandfather's Brother"
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Subtitle: Person Name
            Text(
              personName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),

            // Action Affordance (Go inside)
            Row(
              children: [
                Text(
                  'View Profile',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: ringColor,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 10,
                  color: ringColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

"""

content = content[:start_idx] + new_grid_code + content[end_idx:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated dashboard_screen.dart with Cousin Brother / Sister titles and live navigation successfully!")

