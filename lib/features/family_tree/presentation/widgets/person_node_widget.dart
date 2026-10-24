import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../domain/tree_node.dart';

class PersonNodeWidget extends StatelessWidget {
  final HeritageTreeNode node;
  final VoidCallback onTap;
  final VoidCallback? onToggleExpand;

  const PersonNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final person = node.person;
    final isSelected = node.isSelected;
    final isDirectLine = node.relativeGeneration != 0;
    final hasBranch = node.children.isNotEmpty || node.parents.isNotEmpty;
    final isRoot = person.generationHint == 1;

    // Node Background & Border per Vansora Specification
    final Color nodeBg = isSelected
        ? AppColors.treeNodeSelectedBackground // #C7E2C9 Soft Mint
        : (isDirectLine ? AppColors.treeNodeAncestorBackground : AppColors.treeNodeNormalBackground); // #EDF4EA / #FFFFFF

    return InkWell(
      onTap: onTap,
      borderRadius: HeritageCurves.card,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 154,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: nodeBg,
          borderRadius: HeritageCurves.card,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 14,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  ...HeritageShadows.card,
                ]
              : HeritageShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Portrait Avatar
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.paleSage : AppColors.lightSage,
                  ),
                  child: Center(
                    child: Text(
                      person.initials,
                      style: HeritageTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (isRoot)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.paleSage,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 10,
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

            const SizedBox(height: 6),

            // Name
            Text(
              person.displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HeritageTypography.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 2),

            // Life Dates
            Text(
              person.lifeDateSpan,
              textAlign: TextAlign.center,
              style: HeritageTypography.lifeDates.copyWith(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),

            // Branch expand / collapse indicator
            if (hasBranch && onToggleExpand != null) ...[
              const SizedBox(height: 5),
              GestureDetector(
                onTap: onToggleExpand,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: node.isExpanded ? AppColors.lightSage : AppColors.paleSage,
                    borderRadius: HeritageCurves.pill,
                  ),
                  child: Icon(
                    node.isExpanded ? Icons.remove : Icons.add,
                    size: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
