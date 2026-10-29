import re

path = r'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read().replace('\r\n', '\n')

# 1. Overview and metric item
old_overview = """    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: HeritageShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactMetricItem(
            label: 'Relatives',
            value: memberCount,
            icon: Icons.people_outline_rounded,
          ),
          Container(
            height: 28,
            width: 1,
            color: AppColors.border,
          ),
          _buildCompactMetricItem(
            label: 'Generations',
            value: '$genCount/10',
            icon: Icons.account_tree_outlined,
          ),
          Container(
            height: 28,
            width: 1,
            color: AppColors.border,
          ),
          _buildCompactMetricItem(
            label: 'Vault Media',
            value: mediaCount,
            icon: Icons.photo_library_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetricItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.paleBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );"""

new_overview = """    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: HeritageShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactMetricItem(
              label: 'Relatives',
              value: memberCount,
              icon: Icons.people_outline_rounded,
            ),
          ),
          Container(
            height: 26,
            width: 1,
            color: AppColors.border.withOpacity(0.7),
          ),
          Expanded(
            child: _buildCompactMetricItem(
              label: 'Generations',
              value: '$genCount/10',
              icon: Icons.account_tree_outlined,
            ),
          ),
          Container(
            height: 26,
            width: 1,
            color: AppColors.border.withOpacity(0.7),
          ),
          Expanded(
            child: _buildCompactMetricItem(
              label: 'Vault Media',
              value: mediaCount,
              icon: Icons.photo_library_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetricItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.paleBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14.5, color: AppColors.primary),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );"""

assert old_overview in content, "old_overview not found"
content = content.replace(old_overview, new_overview)

# 2. Lineage Hierarchy Header
old_lineage_header = """        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Lineage Hierarchy',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Direct ancestral lineage & immediate family branch',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: HeritageCurves.pill,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Text(
                'GEN ${viewer.generationHint ?? 9} • YOU',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),"""

new_lineage_header = """        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Lineage Hierarchy',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Direct ancestral lineage & immediate family branch',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: HeritageCurves.pill,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Text(
                'GEN ${viewer.generationHint ?? 9} • YOU',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),"""

assert old_lineage_header in content, "old_lineage_header not found"
content = content.replace(old_lineage_header, new_lineage_header)

# 3. Siblings Header
old_siblings_header = """        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'My Siblings',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    borderRadius: HeritageCurves.pill,
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    'BROTHERS & SISTERS • GEN 9',
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
            Text(
              '${siblings.length} ${siblings.length == 1 ? "Sibling" : "Siblings"}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),"""

new_siblings_header = """        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    'My Siblings',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.paleBlue,
                        borderRadius: HeritageCurves.pill,
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Text(
                        'BROTHERS & SISTERS • GEN 9',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${siblings.length} ${siblings.length == 1 ? "Sibling" : "Siblings"}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),"""

assert old_siblings_header in content, "old_siblings_header not found"
content = content.replace(old_siblings_header, new_siblings_header)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Part 1: headers and metrics updated successfully!")

