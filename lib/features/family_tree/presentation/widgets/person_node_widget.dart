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
    final hasBranch = node.children.isNotEmpty || node.parents.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: HeritageColors.warmIvoryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? HeritageColors.mutedBrass
                : HeritageColors.stoneDark,
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? HeritageColors.mutedBrass.withOpacity(0.25)
                  : HeritageColors.subtleShadow,
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Portrait Avatar with verification badge
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? HeritageColors.mutedBrass
                          : HeritageColors.forestGreen,
                      width: 1.8,
                    ),
                    color: HeritageColors.stoneLight,
                  ),
                  child: Center(
                    child: Text(
                      person.initials,
                      style: HeritageTypography.titleMedium.copyWith(
                        color: HeritageColors.forestGreen,
                        fontWeight: FontWeight.w700,
                      ),
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
                        color: HeritageColors.forestGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 11,
                        color: HeritageColors.warmIvoryLight,
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
                color: isSelected
                    ? HeritageColors.forestGreenDark
                    : HeritageColors.charcoal,
              ),
            ),

            const SizedBox(height: 2),

            // Life Dates
            Text(
              person.lifeDateSpan,
              textAlign: TextAlign.center,
              style: HeritageTypography.lifeDates.copyWith(
                fontSize: 10.5,
              ),
            ),

            // Expand/collapse indicator if branch exists
            if (hasBranch && onToggleExpand != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onToggleExpand,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: node.isExpanded
                        ? HeritageColors.stone
                        : HeritageColors.mutedBrass.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    node.isExpanded ? Icons.remove : Icons.add,
                    size: 11,
                    color: HeritageColors.forestGreen,
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
