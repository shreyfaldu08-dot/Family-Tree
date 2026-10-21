import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/models/relationship.dart';
import '../../../data/providers/repository_providers.dart';

class PersonProfileScreen extends ConsumerWidget {
  final String personId;

  const PersonProfileScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final relsAsync = ref.watch(familyRelationshipsProvider);
    final mediaAsync = ref.watch(familyMediaProvider);
    final timelineAsync = ref.watch(familyTimelineProvider);
    final membership = ref.watch(currentMembershipProvider).valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;

    return personsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: HeritageColors.warmIvory,
        body: Center(child: CircularProgressIndicator(color: HeritageColors.forestGreen)),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (allPersons) {
        final person = allPersons.where((p) => p.id == personId).firstOrNull;

        if (person == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Person record not found.', style: HeritageTypography.titleMedium),
            ),
          );
        }

        final allRels = relsAsync.valueOrNull ?? const [];
        final allMedia = mediaAsync.valueOrNull ?? const [];
        final allEvents = timelineAsync.valueOrNull ?? const [];

        // Linked family members
        final parentIds = allRels
            .where((r) => r.type == RelationshipType.parent && r.relatedPersonId == person.id)
            .map((r) => r.personId)
            .toSet();
        final childIds = allRels
            .where((r) => r.type == RelationshipType.parent && r.personId == person.id)
            .map((r) => r.relatedPersonId)
            .toSet();
        final spouseIds = allRels
            .where((r) => r.type == RelationshipType.spouse && (r.personId == person.id || r.relatedPersonId == person.id))
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
            backgroundColor: HeritageColors.warmIvory,
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
                    icon: const Icon(Icons.edit_outlined, color: HeritageColors.forestGreen),
                    tooltip: 'Edit Record (Admin)',
                    onPressed: () => context.push('/admin/persons/edit/${person.id}'),
                  ),
              ],
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: HeritageColors.forestGreen,
                labelColor: HeritageColors.forestGreen,
                unselectedLabelColor: HeritageColors.charcoalMuted,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: HeritageColors.warmIvoryLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: HeritageColors.stone, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HeritageColors.stoneLight,
                  border: Border.all(color: HeritageColors.mutedBrass, width: 2),
                ),
                child: Center(
                  child: Text(
                    person.initials,
                    style: HeritageTypography.displayMedium.copyWith(
                      color: HeritageColors.forestGreen,
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: person.isLiving
                                ? HeritageColors.forestGreen.withOpacity(0.12)
                                : HeritageColors.stoneDark.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            person.isLiving ? 'Living' : 'Deceased',
                            style: HeritageTypography.labelSmall.copyWith(
                              color: person.isLiving ? HeritageColors.forestGreen : HeritageColors.charcoal,
                            ),
                          ),
                        ),
                        if (person.isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: HeritageColors.mutedBrass.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_outlined, size: 12, color: HeritageColors.mutedBrass),
                                const SizedBox(width: 3),
                                Text(
                                  'Archival Verified',
                                  style: HeritageTypography.labelSmall.copyWith(color: HeritageColors.mutedBrassDark),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HeritageColors.warmIvoryLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: HeritageColors.stone, width: 1),
            ),
            child: Text(
              person.bio!,
              style: HeritageTypography.bodyMedium.copyWith(height: 1.5),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HeritageColors.warmIvoryLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HeritageColors.stone, width: 1),
            ),
            child: Text('No $title recorded yet.', style: HeritageTypography.bodySmall),
          )
        else
          ...people.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  tileColor: HeritageColors.warmIvoryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: HeritageColors.stone, width: 1),
                  ),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: HeritageColors.warmIvoryLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: HeritageColors.stone, width: 1.2),
          ),
          child: Text(
            story,
            style: HeritageTypography.storyBody,
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HeritageColors.warmIvoryLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: HeritageColors.stone, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_outlined, color: HeritageColors.forestGreen, size: 28),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HeritageColors.warmIvoryLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: HeritageColors.stone, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, color: HeritageColors.mutedBrass, size: 28),
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
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HeritageColors.warmIvoryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HeritageColors.stone, width: 1),
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
              style: HeritageTypography.labelMedium.copyWith(color: HeritageColors.charcoalMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: HeritageTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
