import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/colors.dart';
import '../../../../data/models/person.dart';
import '../../domain/tree_node.dart';

/// Visual theme specification for a tree card node corresponding to the reference tablet design
class _NodeVisualTheme {
  final String roleLabel;
  final IconData roleIcon;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color roleColor;
  final Color dateColor;
  final Color statusColor;
  final String statusTag;

  const _NodeVisualTheme({
    required this.roleLabel,
    required this.roleIcon,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.roleColor,
    required this.dateColor,
    required this.statusColor,
    required this.statusTag,
  });
}

class PersonNodeWidget extends StatelessWidget {
  final HeritageTreeNode node;
  final VoidCallback onTap;
  final VoidCallback? onToggleExpand;
  final bool isAdmin;
  final void Function(String relationType)? onAddRelative;

  const PersonNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    this.onToggleExpand,
    this.isAdmin = false,
    this.onAddRelative,
  });

  /// Maps person role and generation level to the reference pastel palette
  _NodeVisualTheme _getTheme(Person person) {
    final relGen = node.relativeGeneration;
    final id = person.id;

    // 1. Myself (Sara Wilson) - Soft Sage / Mint Green
    if (id == 'p_gen9_sara' || (relGen == 0 && person.firstName.toLowerCase() == 'sara')) {
      return const _NodeVisualTheme(
        roleLabel: 'SELF',
        roleIcon: Icons.person_outline_rounded,
        backgroundColor: Color(0xFFE8F4E8),
        borderColor: Color(0xFFC4E4C4),
        titleColor: Color(0xFF1E3D22),
        roleColor: Color(0xFF2C6B34),
        dateColor: Color(0xFF4A7250),
        statusColor: Color(0xFF2C6B34),
        statusTag: 'ACTIVE',
      );
    }

    // 2. Spouse (Thomas Wilson) - Soft Blush Rose Pink
    if (id == 'p_gen9_thomas_wilson' || (relGen == 0 && id.contains('thomas'))) {
      return const _NodeVisualTheme(
        roleLabel: 'SPOUSE',
        roleIcon: Icons.favorite_border_rounded,
        backgroundColor: Color(0xFFFDE7EC),
        borderColor: Color(0xFFF8C4D1),
        titleColor: Color(0xFF4A1322),
        roleColor: Color(0xFF8A2744),
        dateColor: Color(0xFF9E4861),
        statusColor: Color(0xFF8A2744),
        statusTag: 'MANAGED',
      );
    }

    // 3. Siblings (Lucas, Elena, James) - Soft Warm Sand / Linen
    if (id == 'p_gen9_lucas' || id == 'p_gen9_elena' || id == 'p_gen9_james' || 
        (relGen == 0 && !id.contains('oliver') && !id.contains('clara') && !id.contains('thomas'))) {
      return const _NodeVisualTheme(
        roleLabel: 'SIBLING',
        roleIcon: Icons.people_outline_rounded,
        backgroundColor: Color(0xFFF5EBE1),
        borderColor: Color(0xFFE5D5C6),
        titleColor: Color(0xFF3D3126),
        roleColor: Color(0xFF665241),
        dateColor: Color(0xFF7D6C5D),
        statusColor: Color(0xFF665241),
        statusTag: 'MANAGED',
      );
    }

    // 4. Cousins (Oliver & Clara) - Soft Pastel Lavender
    if (id == 'p_gen9_oliver' || id == 'p_gen9_clara' || id.contains('oliver') || id.contains('clara')) {
      return const _NodeVisualTheme(
        roleLabel: 'COUSIN',
        roleIcon: Icons.diversity_1_outlined,
        backgroundColor: Color(0xFFF3EDF7),
        borderColor: Color(0xFFDDD2E8),
        titleColor: Color(0xFF3F2B4D),
        roleColor: Color(0xFF6B4B82),
        dateColor: Color(0xFF7A648C),
        statusColor: Color(0xFF6B4B82),
        statusTag: 'MANAGED',
      );
    }

    // 5. Parents (David & Sophia) - Soft Sky Blue
    if (relGen == -1 && (id == 'p_gen8_david' || id == 'p_gen8_sophia' || id.contains('david') || id.contains('sophia'))) {
      return const _NodeVisualTheme(
        roleLabel: 'PARENT',
        roleIcon: Icons.supervisor_account_outlined,
        backgroundColor: Color(0xFFE6F3FD),
        borderColor: Color(0xFFBFE0FA),
        titleColor: Color(0xFF103659),
        roleColor: Color(0xFF1D5A92),
        dateColor: Color(0xFF38638C),
        statusColor: Color(0xFF1D5A92),
        statusTag: 'MANAGED',
      );
    }

    // 6. Uncle (Richard Kensington) - Soft Ice Blue
    if (relGen == -1 && (id == 'p_gen8_richard' || id.contains('richard'))) {
      return const _NodeVisualTheme(
        roleLabel: 'UNCLE',
        roleIcon: Icons.account_circle_outlined,
        backgroundColor: Color(0xFFEBF5FB),
        borderColor: Color(0xFFCCE4F5),
        titleColor: Color(0xFF174366),
        roleColor: Color(0xFF24689E),
        dateColor: Color(0xFF3F6D91),
        statusColor: Color(0xFF24689E),
        statusTag: 'MANAGED',
      );
    }

    // 7. Grandparents (Julian & Helena) - Soft Warm Peach / Apricot
    if (relGen == -2 && (id == 'p_gen7_julian' || id == 'p_gen7_helena' || id.contains('julian') || id.contains('helena'))) {
      return const _NodeVisualTheme(
        roleLabel: 'GRAND-PARENT',
        roleIcon: Icons.account_balance_outlined,
        backgroundColor: Color(0xFFFDEEDB),
        borderColor: Color(0xFFF6D6B8),
        titleColor: Color(0xFF4A2B14),
        roleColor: Color(0xFF7A4A28),
        dateColor: Color(0xFF8C5D3B),
        statusColor: Color(0xFF7A4A28),
        statusTag: 'MANAGED',
      );
    }

    // 8. Great-Uncle (William Kensington) - Soft Warm Peach
    if (relGen == -2 && (id == 'p_gen7_william' || id.contains('william'))) {
      return const _NodeVisualTheme(
        roleLabel: 'GREAT-UNCLE',
        roleIcon: Icons.elderly_outlined,
        backgroundColor: Color(0xFFFDF0DE),
        borderColor: Color(0xFFF8DCBE),
        titleColor: Color(0xFF4E2F17),
        roleColor: Color(0xFF82522D),
        dateColor: Color(0xFF916543),
        statusColor: Color(0xFF82522D),
        statusTag: 'MANAGED',
      );
    }

    // 9. Older Ancestors (Gen -3 to Gen -8) - Soft Antique Cream / Parchment
    if (relGen <= -3) {
      return const _NodeVisualTheme(
        roleLabel: 'ANCESTOR',
        roleIcon: Icons.history_edu_outlined,
        backgroundColor: Color(0xFFFBF1E6),
        borderColor: Color(0xFFF0DFCC),
        titleColor: Color(0xFF52351E),
        roleColor: Color(0xFF8C5A35),
        dateColor: Color(0xFF996B46),
        statusColor: Color(0xFF8C5A35),
        statusTag: 'MANAGED',
      );
    }

    // 10. Children (Maya Kensington, Liam Wilson) - Soft Pale Lime / Chartreuse
    if (relGen >= 1) {
      return const _NodeVisualTheme(
        roleLabel: 'CHILD',
        roleIcon: Icons.child_care_rounded,
        backgroundColor: Color(0xFFF2F6DB),
        borderColor: Color(0xFFDAE9B1),
        titleColor: Color(0xFF334212),
        roleColor: Color(0xFF4C6A20),
        dateColor: Color(0xFF647B3A),
        statusColor: Color(0xFF4C6A20),
        statusTag: 'MANAGED',
      );
    }

    // Default fallback
    return const _NodeVisualTheme(
      roleLabel: 'RELATIVE',
      roleIcon: Icons.person_outline_rounded,
      backgroundColor: Color(0xFFF5EBE1),
      borderColor: Color(0xFFE5D5C6),
      titleColor: Color(0xFF3D3126),
      roleColor: Color(0xFF665241),
      dateColor: Color(0xFF7D6C5D),
      statusColor: Color(0xFF665241),
      statusTag: 'MANAGED',
    );
  }

  /// Reference naming style (e.g. "Myself", "Mom • Sophia", "Dad • David", "Grampa Julian", "Grandma Helena")
  String _getCardName(Person person) {
    final id = person.id;
    if (id == 'p_gen9_sara') return 'Myself';
    if (id == 'p_gen9_thomas_wilson') return 'Thomas';
    if (id == 'p_gen8_david') return 'Dad • David';
    if (id == 'p_gen8_sophia') return 'Mom • Sophia';
    if (id == 'p_gen8_richard') return 'Uncle Richard';
    if (id == 'p_gen7_julian') return 'Grampa Julian';
    if (id == 'p_gen7_helena') return 'Grandma Helena';
    if (id == 'p_gen7_william') return 'Great-Uncle William';
    return person.displayName;
  }

  String _formatDate(Person person) {
    if (person.birthDate != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final b = person.birthDate!;
      final monthName = months[b.month - 1];
      return '$monthName ${b.day}, ${b.year}';
    }
    return person.lifeDateSpan;
  }

  @override
  Widget build(BuildContext context) {
    final person = node.person;
    final isSelected = node.isSelected;
    final theme = _getTheme(person);
    final cardName = _getCardName(person);
    final dateStr = _formatDate(person);

    const double cardWidth = 172.0;
    const double cardHeight = 156.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The Pastel Squircle Card
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: cardWidth,
              height: cardHeight,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : theme.borderColor,
                  width: isSelected ? 2.2 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: isSelected ? 14 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Upper Row: Centered Portrait Avatar with ... Menu in Top-Right
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered Circular Avatar (Diameter 40px)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: person.portraitUrl != null && person.portraitUrl!.trim().startsWith('http')
                              ? Image.network(
                                  person.portraitUrl!.trim(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Image.asset(
                                    person.effectivePortraitAsset,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  person.effectivePortraitAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => _buildInitials(person, theme),
                                ),
                        ),
                      ),

                      // Top-Right: Three Dots Menu (...)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: PopupMenuButton<String>(
                          tooltip: 'Options',
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: 16,
                            color: theme.dateColor.withOpacity(0.85),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onSelected: (val) {
                            if (val == 'view') {
                              onTap();
                            } else if (onAddRelative != null) {
                              onAddRelative!(val);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'view', child: Text('View Details')),
                            if (isAdmin) ...const [
                              PopupMenuItem(value: 'parent', child: Text('Add Parent')),
                              PopupMenuItem(value: 'spouse', child: Text('Add Spouse')),
                              PopupMenuItem(value: 'child', child: Text('Add Child')),
                              PopupMenuItem(value: 'sibling', child: Text('Add Sibling')),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Middle Section: Name, Role, Date
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Person Name (Bold, clean sans-serif)
                      Text(
                        cardName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: theme.titleColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Role with icon (e.g. 👤 PARENT / 👤 GRAND-PARENT / 👤 SELF)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            theme.roleIcon,
                            size: 11,
                            color: theme.roleColor,
                          ),
                          const SizedBox(width: 3.5),
                          Flexible(
                            child: Text(
                              theme.roleLabel,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                color: theme.roleColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Date with Calendar Icon (e.g. 📅 Feb 13, 1943)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 9.5,
                            color: theme.dateColor,
                          ),
                          const SizedBox(width: 3.5),
                          Flexible(
                            child: Text(
                              dateStr,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: theme.dateColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bottom Row: Status Tag (MANAGED / ACTIVE) & Subtle Corner Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          theme.statusTag,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: theme.statusColor.withOpacity(0.75),
                            letterSpacing: 0.6,
                          ),
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.borderColor.withOpacity(0.6),
                          ),
                          child: Icon(
                            person.isVerified ? Icons.check : Icons.info_outline,
                            size: 9,
                            color: theme.titleColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Interactive Green Circular Plus (+) Button on the RIGHT EDGE (Add Spouse/Sibling)
        Positioned(
          right: -9,
          top: (cardHeight - 20) / 2,
          child: GestureDetector(
            onTap: () {
              if (onAddRelative != null) {
                onAddRelative!('spouse');
              } else {
                onTap();
              }
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(Person person, _NodeVisualTheme theme) {
    return Center(
      child: Text(
        person.initials,
        style: GoogleFonts.inter(
          color: theme.titleColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
