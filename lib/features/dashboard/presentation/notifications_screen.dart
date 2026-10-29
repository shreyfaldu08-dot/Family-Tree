import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/providers/repository_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(familyPersonsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications & Milestones', style: HeritageTypography.displaySmall),
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (persons) {
          final living = persons.where((p) => p.isLiving).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Header announcement
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.signatureGradient,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_rounded, color: AppColors.textPrimary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heritage Vault Milestone',
                            style: HeritageTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'New verified life chronicles and historical photographs added.',
                            style: HeritageTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text('Upcoming Birthdays & Anniversaries', style: HeritageTypography.displaySmall),
              const SizedBox(height: 10),

              if (living.isEmpty)
                const Center(child: Text('No living relatives recorded.'))
              else
                ...living.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: HeritageCurves.card,
                      boxShadow: HeritageShadows.card,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.lightSage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cake_rounded, color: AppColors.primary, size: 22),
                      ),
                      title: Text(p.displayName, style: HeritageTypography.titleSmall),
                      subtitle: Text(
                        'Born: ${p.birthDate != null ? "${p.birthDate!.day}/${p.birthDate!.month}" : (p.birthYear?.toString() ?? "Date on record")}',
                        style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightSage,
                          borderRadius: HeritageCurves.pill,
                        ),
                        child: Text(
                          'Upcoming',
                          style: HeritageTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
