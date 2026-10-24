import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

class PersonProfileScreen extends ConsumerWidget {
  final String personId;

  const PersonProfileScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final relationshipsAsync = ref.watch(familyRelationshipsProvider);
    final mediaAsync = ref.watch(familyMediaProvider);
    final timelineAsync = ref.watch(familyTimelineProvider);
    final membership = ref.watch(currentMembershipProvider).valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;

    return personsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $err')),
      ),
      data: (allPersons) {
        final person = allPersons.where((p) => p.id == personId).firstOrNull;
        if (person == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('Person record not found.')),
          );
        }

        final allRels = relationshipsAsync.valueOrNull ?? const [];
        final allMedia = mediaAsync.valueOrNull ?? const [];
        final allEvents = timelineAsync.valueOrNull ?? const [];

        // Linked relatives
        final parentIds = allRels
            .where((r) => r.relatedPersonId == person.id && r.type.dbValue == 'parent')
            .map((r) => r.personId)
            .toSet();

        final childIds = allRels
            .where((r) => r.personId == person.id && r.type.dbValue == 'parent')
            .map((r) => r.relatedPersonId)
            .toSet();

        final spouseIds = allRels
            .where((r) =>
                (r.personId == person.id || r.relatedPersonId == person.id) &&
                r.type.dbValue == 'spouse')
            .map((r) => r.personId == person.id ? r.relatedPersonId : r.personId)
            .toSet();

        final parents = allPersons.where((p) => parentIds.contains(p.id)).toList();
        final children = allPersons.where((p) => childIds.contains(p.id)).toList();
        final spouses = allPersons.where((p) => spouseIds.contains(p.id)).toList();

        // Linked timeline events
        final personEvents = allEvents.where((e) => e.linkedPersonIds.contains(person.id)).toList();

        return DefaultTabController(
          length: 6,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(person.displayName, style: HeritageTypography.displaySmall),
              actions: [
                IconButton(
                  icon: const Icon(Icons.account_tree_outlined),
                  tooltip: 'Focus in Family Tree',
                  onPressed: () => context.push('/tree?personId=${person.id}'),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                    tooltip: 'Edit Record (Admin)',
                    onPressed: () => context.push('/admin/persons/edit/${person.id}'),
                  ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.pill,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: TabBar(
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.paleSage,
                      borderRadius: HeritageCurves.pill,
                    ),
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Connections'),
                      Tab(text: 'Life Story'),
                      Tab(text: 'Memories'),
                      Tab(text: 'Documents'),
                      Tab(text: 'Timeline'),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                // 1. Overview Tab
                _buildOverviewTab(person),

                // 2. Family Connections Tab
                _buildConnectionsTab(context, parents, spouses, children, isAdmin, person.id),

                // 3. Life Story Tab
                _buildStoryTab(person),

                // 4. Memories Tab
                _buildMemoriesTab(allMedia),

                // 5. Documents Tab
                _buildDocumentsTab(allMedia),

                // 6. Timeline Tab
                _buildTimelineTab(personEvents),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(Person person) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Portrait & Core Identity Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: HeritageCurves.cardLarge,
            boxShadow: HeritageShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightSage,
                ),
                child: Center(
                  child: Text(
                    person.initials,
                    style: HeritageTypography.displayMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.displayName, style: HeritageTypography.displaySmall),
                    if (person.maidenName != null) ...[
                      const SizedBox(height: 2),
                      Text('née ${person.maidenName}', style: HeritageTypography.bodySmall),
                    ],
                    const SizedBox(height: 4),
                    Text(person.lifeDateSpan, style: HeritageTypography.lifeDates),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.lightSage,
                            borderRadius: HeritageCurves.pill,
                          ),
                          child: Text(
                            person.isLiving ? 'Living' : 'Deceased',
                            style: HeritageTypography.labelSmall.copyWith(
                              color: person.isLiving ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (person.isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.paleSage,
                              borderRadius: HeritageCurves.pill,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Archival Verified',
                                  style: HeritageTypography.labelSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Vital Life Events summary
        _detailRow('Birth Place', person.birthPlace ?? 'Unrecorded in archive'),
        if (!person.isLiving)
          _detailRow('Death Place', person.deathPlace ?? 'Unrecorded in archive'),
        if (person.alternateNames.isNotEmpty)
          _detailRow('Alternate Names', person.alternateNames.join(', ')),

        const SizedBox(height: 16),

        if (person.bio != null) ...[
          Text('Biographical Summary', style: HeritageTypography.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightSage,
              borderRadius: HeritageCurves.card,
            ),
            child: Text(
              person.bio!,
              style: HeritageTypography.bodyMedium.copyWith(
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConnectionsTab(
    BuildContext context,
    List<Person> parents,
    List<Person> spouses,
    List<Person> children,
    bool isAdmin,
    String currentPersonId,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _connectionSection(context, 'Parents', parents),
        const SizedBox(height: 16),
        _connectionSection(context, 'Spouse / Partner', spouses),
        const SizedBox(height: 16),
        _connectionSection(context, 'Children', children),
        if (isAdmin) ...[
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.push('/admin/relationships/new?sourcePersonId=$currentPersonId'),
            icon: const Icon(Icons.add_link),
            label: const Text('Add Relationship Connection (Admin)'),
          ),
        ],
      ],
    );
  }

  Widget _connectionSection(BuildContext context, String title, List<Person> people) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: HeritageTypography.titleMedium),
        const SizedBox(height: 8),
        if (people.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.card,
              boxShadow: HeritageShadows.card,
            ),
            child: Text('No $title recorded yet.', style: HeritageTypography.bodySmall),
          )
        else
          ...people.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: HeritageCurves.card,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  onTap: () => context.push('/people/${p.id}'),
                  title: Text(p.displayName, style: HeritageTypography.titleSmall),
                  subtitle: Text(p.lifeDateSpan, style: HeritageTypography.lifeDates),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ),
              )),
      ],
    );
  }

  Widget _buildStoryTab(Person person) {
    final story = person.lifeStory ?? person.bio ?? 'No narrative story recorded yet for this family member.';
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Life Chronicle', style: HeritageTypography.displaySmall),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: HeritageCurves.cardLarge,
            boxShadow: HeritageShadows.card,
          ),
          child: Text(
            story,
            style: HeritageTypography.storyBody.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoriesTab(List<dynamic> media) {
    final photos = media.where((m) => m.mediaType.dbValue == 'photo').toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Preserved Photographs', style: HeritageTypography.titleMedium),
        const SizedBox(height: 12),
        if (photos.isEmpty)
          const Text('No photographs cataloged in archive.')
        else
          ...photos.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightSage,
                      ),
                      child: const Icon(Icons.photo_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: HeritageTypography.titleSmall),
                          if (m.description != null)
                            Text(m.description!, style: HeritageTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildDocumentsTab(List<dynamic> media) {
    final docs = media.where((m) => m.mediaType.dbValue == 'document').toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Archival Documents & Certifications', style: HeritageTypography.titleMedium),
        const SizedBox(height: 12),
        if (docs.isEmpty)
          const Text('No historical documents attached.')
        else
          ...docs.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightSage,
                      ),
                      child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.title, style: HeritageTypography.titleSmall),
                          if (d.description != null)
                            Text(d.description!, style: HeritageTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildTimelineTab(List<dynamic> events) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Individual Timeline', style: HeritageTypography.titleMedium),
        const SizedBox(height: 12),
        if (events.isEmpty)
          const Text('No linked historical events recorded.')
        else
          ...events.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.formattedDate, style: HeritageTypography.lifeDates),
                    const SizedBox(height: 4),
                    Text(e.title, style: HeritageTypography.titleSmall),
                    if (e.description != null) ...[
                      const SizedBox(height: 4),
                      Text(e.description!, style: HeritageTypography.bodySmall),
                    ],
                  ],
                ),
              )),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: HeritageTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: HeritageTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
