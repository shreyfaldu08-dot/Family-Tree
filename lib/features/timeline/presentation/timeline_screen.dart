import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/life_event.dart';
import '../../../data/providers/repository_providers.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(familyTimelineProvider);
    final membership = ref.watch(currentMembershipProvider).valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Historical Timeline', style: HeritageTypography.displaySmall),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: HeritageColors.forestGreen),
              tooltip: 'Add Historical Milestone (Admin)',
              onPressed: () {
                _showAddMilestoneDialog(context, ref);
              },
            ),
        ],
      ),
      body: timelineAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: HeritageColors.forestGreen),
        ),
        error: (err, _) => Center(child: Text('Error loading timeline: $err')),
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    gradient: HeritageGradients.premiumCard,
                    borderRadius: HeritageCurves.cardLarge,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: HeritageGradients.avatarPill,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.timeline_rounded,
                          size: 28,
                          color: HeritageColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Milestones Yet',
                        style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Document births, marriages, migrations, and major historical achievements across your family generations.',
                        textAlign: TextAlign.center,
                        style: HeritageTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: events.length,
            itemBuilder: (ctx, i) {
              final event = events[i];
              final isLast = i == events.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline track with dot indicator
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: HeritageGradients.accentPill,
                            boxShadow: HeritageShadows.activePill,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: HeritageColors.stoneDark,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // Event Content Card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: HeritageGradients.premiumCard,
                          borderRadius: HeritageCurves.card,
                          boxShadow: HeritageShadows.card,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  event.formattedDate,
                                  style: HeritageTypography.lifeDates.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: HeritageColors.charcoal,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: HeritageGradients.accentPill,
                                    borderRadius: HeritageCurves.pill,
                                    boxShadow: HeritageShadows.activePill,
                                  ),
                                  child: Text(
                                    event.eventType.label,
                                    style: HeritageTypography.labelSmall.copyWith(
                                      color: HeritageColors.charcoal,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              event.title,
                              style: HeritageTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (event.description != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                event.description!,
                                style: HeritageTypography.bodyMedium,
                              ),
                            ],
                            if (event.location != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.place_outlined, size: 14, color: HeritageColors.sage),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.location!,
                                    style: HeritageTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddMilestoneDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Record Family Milestone', style: HeritageTypography.displaySmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Historical Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'Location (City, Country)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              final membership = ref.read(currentMembershipProvider).valueOrNull;
              final repo = ref.read(timelineRepositoryProvider);
              await repo.createLifeEvent(
                LifeEvent(
                  id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
                  familyId: 'fam_kensington_01',
                  eventType: EventType.custom,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  location: locCtrl.text.trim(),
                  eventDate: DateTime.now(),
                  createdAt: DateTime.now(),
                ),
                membership,
              );
              ref.invalidate(familyTimelineProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Record Event'),
          ),
        ],
      ),
    );
  }
}
