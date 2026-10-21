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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: HeritageGradients.pillTrack,
        borderRadius: HeritageCurves.pill,
        boxShadow: HeritageShadows.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timeline_rounded,
            size: 16,
            color: HeritageColors.charcoal,
          ),
          const SizedBox(width: 8),
          Text(
            'Generations:',
            style: HeritageTypography.labelSmall.copyWith(
              color: HeritageColors.charcoalMuted,
            ),
          ),
          const SizedBox(width: 8),
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
                      borderRadius: HeritageCurves.pill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? HeritageGradients.accentPill
                              : null,
                          color: isSelected
                              ? null
                              : HeritageColors.surfaceSecondary,
                          borderRadius: HeritageCurves.pill,
                          boxShadow: isSelected
                              ? HeritageShadows.activePill
                              : null,
                        ),
                        child: Text(
                          g == 0 ? '0' : (g > 0 ? '+$g' : '$g'),
                          style: HeritageTypography.labelSmall.copyWith(
                            color: isSelected
                                ? HeritageColors.charcoal
                                : HeritageColors.charcoalMuted,
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
