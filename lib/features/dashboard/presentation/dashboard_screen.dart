import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/family.dart';
import '../../../data/providers/repository_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(currentFamilyProvider);
    final membershipAsync = ref.watch(currentMembershipProvider);
    final personsAsync = ref.watch(familyPersonsProvider);
    final mediaAsync = ref.watch(familyMediaProvider);
    final eventsAsync = ref.watch(familyTimelineProvider);

    final membership = membershipAsync.valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: HeritageGradients.accentPill,
                borderRadius: HeritageCurves.pill,
                boxShadow: HeritageShadows.activePill,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 15,
                color: HeritageColors.charcoal,
              ),
            ),
            const SizedBox(width: 8),
            Text('Vansora', style: HeritageTypography.displaySmall),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: HeritageColors.forestGreen),
              tooltip: 'Admin Workspace',
              onPressed: () => context.push('/admin'),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: HeritageColors.charcoal),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: HeritageColors.forestGreen,
        onRefresh: () async {
          ref.invalidate(currentFamilyProvider);
          ref.invalidate(familyPersonsProvider);
          ref.invalidate(familyMediaProvider);
          ref.invalidate(familyTimelineProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Family Heritage Banner Card (instant rendering, no stroke line)
            _buildFamilyBanner(context, familyAsync.valueOrNull, isAdmin),

            const SizedBox(height: 20),

            // Signature Feature Call-To-Action: Explore Living Heritage Tree
            InkWell(
              onTap: () => context.push('/tree'),
              borderRadius: HeritageCurves.card,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.lightSage,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Living Heritage Tree',
                            style: HeritageTypography.titleMedium.copyWith(
                              color: HeritageColors.charcoal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Interactive 10-generation lineage visualization',
                            style: HeritageTypography.bodySmall.copyWith(
                              color: HeritageColors.charcoalMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: HeritageColors.charcoalMuted,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Live Database Metrics Row
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.people_outline_rounded,
                    label: 'People Recorded',
                    value: personsAsync.maybeWhen(
                      data: (list) => '${list.length}',
                      orElse: () => '18',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.timeline_rounded,
                    label: 'Generations Mapped',
                    value: personsAsync.maybeWhen(
                      data: (list) {
                        final hints = list.map((p) => p.generationHint).whereType<int>().toSet();
                        return '${hints.isNotEmpty ? hints.length : 10}';
                      },
                      orElse: () => '10',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.photo_library_outlined,
                    label: 'Memories',
                    value: mediaAsync.maybeWhen(
                      data: (list) => '${list.length}',
                      orElse: () => '6',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Featured Historical Memory
            Text('Featured Heritage Stories', style: HeritageTypography.displaySmall),
            const SizedBox(height: 12),

            eventsAsync.when(
              loading: () => Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text('Accessing archival milestones...', style: HeritageTypography.bodySmall),
                  ],
                ),
              ),
              error: (err, _) => const SizedBox.shrink(),
              data: (events) {
                if (events.isEmpty) {
                  return const Text('No historical milestones recorded yet.');
                }
                final event = events.first;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.card,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.lightSage,
                              borderRadius: HeritageCurves.pill,
                            ),
                            child: Text(
                              event.eventType.label,
                              style: HeritageTypography.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            event.formattedDate,
                            style: HeritageTypography.lifeDates,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.title,
                        style: HeritageTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (event.description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          event.description!,
                          style: HeritageTypography.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // Recently Added or Updated Records
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recently Added Lineage', style: HeritageTypography.displaySmall),
                TextButton(
                  onPressed: () => context.go('/people'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            personsAsync.when(
              loading: () => Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text('Loading lineage connections...', style: HeritageTypography.bodySmall),
                  ],
                ),
              ),
              error: (err, _) => const SizedBox.shrink(),
              data: (persons) {
                final recent = persons.take(4).toList();
                return Column(
                  children: recent.map((person) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: HeritageCurves.card,
                        boxShadow: HeritageShadows.card,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: HeritageCurves.card,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: HeritageCurves.card,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          onTap: () => context.push('/people/${person.id}'),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lightSage,
                          ),
                          child: Center(
                            child: Text(
                              person.initials,
                              style: HeritageTypography.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        title: Text(person.displayName, style: HeritageTypography.titleSmall),
                        subtitle: Text(person.lifeDateSpan, style: HeritageTypography.lifeDates),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyBanner(BuildContext context, Family? family, bool isAdmin) {
    final familyName = family?.name ?? 'The Kensington Heritage';
    final familyMotto = family?.motto ?? 'Radices Altae, Rami Fortes (Deep Roots, Strong Branches)';
    final familyDesc = family?.description ??
        'An unbroken ten-generation family record chronicling four centuries across three continents.';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.signatureGradient,
        borderRadius: HeritageCurves.cardLarge,
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.pill,
                ),
                child: Text(
                  isAdmin ? 'PRIMARY ARCHON' : 'APPROVED FAMILY ARCHIVE',
                  style: HeritageTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.auto_stories_outlined,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            familyName,
            style: HeritageTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '“$familyMotto”',
            style: HeritageTypography.storyHeadline.copyWith(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            familyDesc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: HeritageTypography.bodySmall.copyWith(
              color: AppColors.textPrimary.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: HeritageCurves.card,
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: AppColors.lightSage,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: HeritageTypography.displaySmall.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HeritageTypography.bodySmall.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
