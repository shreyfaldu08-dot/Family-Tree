import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../data/models/person.dart';
import '../../../../data/models/membership.dart';

class TreePreviewSheet extends StatelessWidget {
  final Person person;
  final FamilyMembership? membership;
  final VoidCallback onViewFullProfile;
  final VoidCallback onFocusTree;
  final VoidCallback? onAddRelative;

  const TreePreviewSheet({
    super.key,
    required this.person,
    required this.membership,
    required this.onViewFullProfile,
    required this.onFocusTree,
    this.onAddRelative,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = membership?.canWriteFamilyData ?? false;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: HeritageColors.warmIvoryLight,
        borderRadius: HeritageCurves.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: HeritageColors.borderSubtle,
                borderRadius: HeritageCurves.pill,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: HeritageGradients.avatarPill,
                ),
                child: Center(
                  child: Text(
                    person.initials,
                    style: HeritageTypography.displaySmall.copyWith(
                      color: HeritageColors.charcoal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.displayName,
                      style: HeritageTypography.displaySmall.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      person.lifeDateSpan,
                      style: HeritageTypography.lifeDates.copyWith(fontSize: 13),
                    ),
                    if (person.birthPlace != null && person.birthPlace!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: HeritageColors.charcoalMuted,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              person.birthPlace!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HeritageTypography.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (person.bio != null && person.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: HeritageGradients.premiumCard,
                borderRadius: BorderRadius.circular(22),
                boxShadow: HeritageShadows.card,
              ),
              child: Text(
                person.bio!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: HeritageTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: HeritageColors.charcoal,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFocusTree,
                  icon: const Icon(Icons.filter_center_focus, size: 18),
                  label: const Text('Focus Tree'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onViewFullProfile,
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text('Full Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          if (isAdmin && onAddRelative != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onAddRelative,
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('Add Relative Connection (Admin)'),
              style: TextButton.styleFrom(
                foregroundColor: HeritageColors.charcoal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
