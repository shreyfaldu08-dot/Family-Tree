import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

class GenerationNavigator extends StatelessWidget {
  final int minGeneration;
  final int maxGeneration;
  final int currentRelativeGeneration;
  final ValueChanged<int> onSelectGeneration;

  const GenerationNavigator({
    super.key,
    required this.minGeneration,
    required this.maxGeneration,
    required this.currentRelativeGeneration,
    required this.onSelectGeneration,
  });


  @override
  Widget build(BuildContext context) {
    if (minGeneration == maxGeneration) return const SizedBox.shrink();

    final generations = <int>[];
    for (var g = minGeneration; g <= maxGeneration; g++) {
      generations.add(g);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HeritageColors.warmIvoryLight.withOpacity(0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: HeritageColors.stoneDark, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: HeritageColors.subtleShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timeline_rounded,
            size: 16,
            color: HeritageColors.forestGreen,
          ),
          const SizedBox(width: 8),
          Text(
            'Generations:',
            style: HeritageTypography.labelSmall.copyWith(
              color: HeritageColors.charcoalMuted,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: generations.map((g) {
                  final isSelected = g == currentRelativeGeneration;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => onSelectGeneration(g),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? HeritageColors.forestGreen
                              : HeritageColors.stoneLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? HeritageColors.forestGreen
                                : HeritageColors.stone,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          g == 0 ? '0' : (g > 0 ? '+$g' : '$g'),
                          style: HeritageTypography.labelSmall.copyWith(
                            color: isSelected
                                ? HeritageColors.warmIvoryLight
                                : HeritageColors.charcoal,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
