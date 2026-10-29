import re

file_path = 'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Target start and end markers around _buildGrandfatherBrothersAndCousinsCard and _buildCollateralRelativeTile
start_marker = "  // ---------------------------------------------------------------------------\n  // Card 1: Grandfather's Brother & Extended Cousins Branch\n  // (Great-Uncle William's Lineage, Richard & Living 2nd Cousins Oliver/Clara)\n  // ---------------------------------------------------------------------------\n  Widget _buildGrandfatherBrothersAndCousinsCard(BuildContext context) {"
end_marker = "  // ---------------------------------------------------------------------------\n  // Card 2: Ancestral Origins & 246-Year Migration Journey"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print(f"Error: start_idx={start_idx}, end_idx={end_idx}")
    exit(1)

new_code = """  // ---------------------------------------------------------------------------
  // Card 1: Grandfather's Brother & Extended Cousins Branch
  // (2x2 Grid of Relatives styled after modern boutique reference cards with Arc Rings)
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

          // 2x2 Grid of Relatives (Matching the Reference Image style)
          Row(
            children: [
              // Top-Left: Great-Uncle William Kensington
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  name: 'William Kensington',
                  rolePill: 'GREAT-UNCLE',
                  subtitle: '1932 — 2018',
                  statusDetail: "Julian's Brother",
                  imageAsset: 'assets/images/vintage_elder_father.jpg',
                  ringColor: const Color(0xFF26538D),
                  pillBgColor: const Color(0xFFEBF3FC),
                  sweepAngle: 4.8,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Viewing Great-Uncle William Kensington's branch"),
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Top-Right: Richard Kensington (1st Cousin 1R)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  name: 'Richard Kensington',
                  rolePill: '1ST COUSIN 1R',
                  subtitle: 'b. 1964 • Living',
                  statusDetail: 'Senior Architect',
                  imageAsset: 'assets/images/modern_father.jpg',
                  ringColor: const Color(0xFF4F46E5),
                  pillBgColor: const Color(0xFFEEF2FF),
                  sweepAngle: 4.4,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Viewing Cousin Richard Kensington's profile"),
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Bottom-Left: Oliver Kensington (2nd Cousin • Gen 9)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  name: 'Oliver Kensington',
                  rolePill: '2ND COUSIN',
                  subtitle: 'Gen 9 • b. 2004',
                  statusDetail: 'Digital Design',
                  imageAsset: 'assets/images/modern_young_man.jpg',
                  ringColor: const Color(0xFF8B5CF6),
                  pillBgColor: const Color(0xFFF5F3FF),
                  sweepAngle: 5.0,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Viewing Cousin Oliver Kensington"),
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Bottom-Right: Clara Kensington (2nd Cousin • Gen 9)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  name: 'Clara Kensington',
                  rolePill: '2ND COUSIN',
                  subtitle: 'Gen 9 • b. 2006',
                  statusDetail: 'Junior Archivist',
                  imageAsset: 'assets/images/child_portrait.jpg',
                  ringColor: const Color(0xFFEC4899),
                  pillBgColor: const Color(0xFFFDF2F8),
                  sweepAngle: 4.2,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Viewing Cousin Clara Kensington"),
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
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

  // ---------------------------------------------------------------------------
  // Reference-Style Relative Card (Avatar + Colored Arc Ring + Title + Subtitle)
  // ---------------------------------------------------------------------------
  Widget _buildReferenceStyleRelativeCard({
    required BuildContext context,
    required String name,
    required String rolePill,
    required String subtitle,
    required String statusDetail,
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

            // Bold Title / Name (Matches Reference Image)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                name,
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

            // Subtitle / Lifespan (Matches Reference Image percentage/stat)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 1),

            // Lineage status note
            Text(
              statusDetail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: ringColor.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

"""

content = content[:start_idx] + new_code + content[end_idx:]

# Also define _HeritageArcRingPainter at the end of the file if not already present
if "_HeritageArcRingPainter" not in content:
    arc_ring_painter_code = """

// ---------------------------------------------------------------------------
// Heritage Arc Ring Painter (Matches modern circular progress arc reference)
// ---------------------------------------------------------------------------
class _HeritageArcRingPainter extends CustomPainter {
  final Color color;
  final double sweepAngle;
  final double strokeWidth;

  const _HeritageArcRingPainter({
    required this.color,
    this.sweepAngle = 4.71239, // ~270 degrees
    this.strokeWidth = 2.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Subtle track circle behind
    final trackPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Dynamic accent arc with rounded caps
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start at top (-90 degrees)
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeritageArcRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.sweepAngle != sweepAngle;
}
"""
    content += arc_ring_painter_code

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated dashboard_screen.dart with 2x2 grid reference card design successfully!")

