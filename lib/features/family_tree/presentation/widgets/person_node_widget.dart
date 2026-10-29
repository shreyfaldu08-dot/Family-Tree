import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../data/models/person.dart';
import '../../domain/tree_node.dart';

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

  String _getGenerationBadge(Person person) {
    final gen = person.generationHint ?? (node.relativeGeneration <= 0 ? (1 - node.relativeGeneration) : (node.relativeGeneration + 1));
    switch (gen) {
      case 1:
        return person.gender == Gender.female ? 'Gen 1 • Matriarch' : 'Gen 1 • Patriarch';
      case 2:
        return 'Gen 2 • Elder';
      case 3:
        return 'Gen 3 • Parent';
      case 4:
        return 'Gen 4 • Current';
      case 5:
        return 'Gen 5 • Next Gen';
      default:
        return 'Gen $gen';
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = node.person;
    final isSelected = node.isSelected;
    final isDirectLine = node.relativeGeneration != 0;
    final hasBranch = node.children.isNotEmpty || node.parents.isNotEmpty;
    final isRoot = person.generationHint == 1;

    // Node background - clean realistic white / subtle pale blue surface
    final Color nodeBg = isSelected
        ? Colors.white
        : (isDirectLine ? const Color(0xFFF8FAFD) : Colors.white);

    final Color borderColor = isSelected
        ? AppColors.primary
        : (isDirectLine ? const Color(0xFFC8D9F2) : AppColors.border);

    final String genBadge = _getGenerationBadge(person);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: HeritageCurves.card,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 174,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: nodeBg,
              borderRadius: HeritageCurves.card,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2.0 : 0.9,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      ...HeritageShadows.card,
                    ]
                  : HeritageShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Generation Capsule Tag (instant clarity for future descendants)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.paleBlue,
                    borderRadius: HeritageCurves.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        genBadge,
                        style: HeritageTypography.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Portrait Avatar (with network photo or monogram initials)
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.paleBlue : AppColors.softBlueGrey,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 2.0,
                        ),
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
                                errorBuilder: (ctx, err, stack) => _buildInitials(person, isSelected),
                              ),
                      ),
                    ),
                    if (isRoot)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.paleSage,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (person.isVerified)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Name
                Text(
                  person.displayName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HeritageTypography.titleSmall.copyWith(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                // Maiden name / known name if present
                if (person.maidenName != null && person.maidenName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'née ${person.maidenName}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HeritageTypography.bodySmall.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else if (person.alternateNames.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '"${person.alternateNames.first}"',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HeritageTypography.bodySmall.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 4),

                // Life Dates
                Text(
                  person.lifeDateSpan,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HeritageTypography.lifeDates.copyWith(
                    fontSize: 11,
                    fontWeight: person.isLiving ? FontWeight.w600 : FontWeight.w400,
                    color: person.isLiving ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),

                // Hometown / Place of Origin
                if (person.birthPlace != null && person.birthPlace!.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: HeritageCurves.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 10.5,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            person.birthPlace!.split(',').first.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: HeritageTypography.bodySmall.copyWith(
                              fontSize: 9.5,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Branch expand / collapse indicator
                if (hasBranch && onToggleExpand != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onToggleExpand,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: node.isExpanded ? AppColors.lightSage : AppColors.paleSage,
                        borderRadius: HeritageCurves.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            node.isExpanded ? Icons.remove : Icons.add,
                            size: 11,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            node.isExpanded ? 'Hide' : 'Branch',
                            style: HeritageTypography.labelSmall.copyWith(
                              fontSize: 9.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Admin-only "+" button: Add Parent, Add Spouse, Add Child, Add Sibling
        // A regular user NEVER sees this "+" button
        if (isAdmin)
          Positioned(
            top: 6,
            right: 6,
            child: PopupMenuButton<String>(
              tooltip: 'Add Relative',
              icon: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 15, color: Colors.white),
              ),
              padding: EdgeInsets.zero,
              onSelected: (relationType) {
                onAddRelative?.call(relationType);
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'parent', child: Text('Add Parent')),
                PopupMenuItem(value: 'spouse', child: Text('Add Spouse')),
                PopupMenuItem(value: 'child', child: Text('Add Child')),
                PopupMenuItem(value: 'sibling', child: Text('Add Sibling')),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(Person person, bool isSelected) {
    return Center(
      child: Text(
        person.initials,
        style: HeritageTypography.titleMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
