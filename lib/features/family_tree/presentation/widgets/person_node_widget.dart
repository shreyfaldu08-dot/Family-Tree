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
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 154,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? HeritageGradients.heroCard
              : HeritageGradients.premiumCard,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? HeritageShadows.activePill
              : HeritageShadows.card,
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: HeritageGradients.avatarPill,
                  ),
                  child: Center(
                    child: Text(
                      person.initials,
                      style: HeritageTypography.titleMedium.copyWith(
                        color: HeritageColors.charcoal,
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
                        color: HeritageColors.statusSuccessBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 11,
                        color: HeritageColors.statusSuccess,
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
                color: HeritageColors.charcoal,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: node.isExpanded
                        ? null
                        : HeritageGradients.accentPill,
                    color: node.isExpanded
                        ? HeritageColors.surfaceSecondary
                        : null,
                    borderRadius: HeritageCurves.pill,
                  ),
                  child: Icon(
                    node.isExpanded ? Icons.remove : Icons.add,
                    size: 11,
                    color: HeritageColors.charcoal,
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
