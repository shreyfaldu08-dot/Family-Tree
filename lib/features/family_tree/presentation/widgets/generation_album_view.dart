import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../data/models/person.dart';
import '../../../../data/models/relationship.dart';

class GenerationAlbumView extends StatefulWidget {
  final List<Person> persons;
  final List<Relationship> relationships;
  final bool isAdmin;
  final void Function(Person person) onSelectPerson;
  final void Function(String relationType, String sourcePersonId)? onAddRelative;

  const GenerationAlbumView({
    super.key,
    required this.persons,
    required this.relationships,
    required this.isAdmin,
    required this.onSelectPerson,
    this.onAddRelative,
  });

  @override
  State<GenerationAlbumView> createState() => _GenerationAlbumViewState();
}

class _GenerationAlbumViewState extends State<GenerationAlbumView> {
  int? _selectedGenFilter;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _getGenEraTitle(int gen) {
    switch (gen) {
      case 1:
        return 'Founding Ancestors & Roots';
      case 2:
        return 'Grandparents & Senior Elders';
      case 3:
        return 'Parents, Aunts & Uncles';
      case 4:
        return 'Current Generation & Cousins';
      case 5:
        return 'Next Generation & Youth';
      default:
        return 'Generation $gen Heritage';
    }
  }

  String _getGenEraSubtitle(List<Person> group) {
    final years = group
        .map((p) => p.birthDate?.year ?? p.birthYear ?? p.birthYearApprox)
        .where((y) => y != null)
        .map((y) => y!)
        .toList();

    String eraSpan = '';
    if (years.isNotEmpty) {
      years.sort();
      eraSpan = 'Era c. ${years.first} – ${years.last} • ';
    }
    return '$eraSpan${group.length} ${group.length == 1 ? 'member' : 'members'}';
  }

  String? _findSpouseName(Person person) {
    for (final r in widget.relationships) {
      if (r.type == RelationshipType.spouse) {
        if (r.personId == person.id) {
          final spouse = widget.persons.where((p) => p.id == r.relatedPersonId).firstOrNull;
          if (spouse != null) return spouse.displayName;
        } else if (r.relatedPersonId == person.id) {
          final spouse = widget.persons.where((p) => p.id == r.personId).firstOrNull;
          if (spouse != null) return spouse.displayName;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Filter persons by search query
    final filtered = widget.persons.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.matchesQuery(_searchQuery);
    }).toList();

    // Group persons by generationHint (defaults to 1 if null)
    final Map<int, List<Person>> generationMap = {};
    for (final p in filtered) {
      final gen = p.generationHint ?? 1;
      generationMap.putIfAbsent(gen, () => []).add(p);
    }

    final sortedGenerations = generationMap.keys.toList()..sort();

    return Column(
      children: [
        // Top filter bar: Search & Generation quick jump pills
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: AppColors.background,
          child: Column(
            children: [
              // Search field (capsule, borderless)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.pill,
                  boxShadow: HeritageShadows.card,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by name, maiden name, or hometown...',
                    hintStyle: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    icon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchCtrl.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Generation Quick-Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildGenFilterChip(null, 'All Generations (${filtered.length})'),
                    ...sortedGenerations.map((gen) {
                      final count = generationMap[gen]?.length ?? 0;
                      return _buildGenFilterChip(gen, 'Gen $gen ($count)');
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Generations List / Grid Content
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_search_rounded, size: 48, color: AppColors.paleSage),
                      const SizedBox(height: 12),
                      Text('No Family Members Found', style: HeritageTypography.titleMedium),
                      const SizedBox(height: 4),
                      Text('Try adjusting your search query.', style: HeritageTypography.bodySmall),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _selectedGenFilter != null
                      ? 1
                      : sortedGenerations.length,
                  itemBuilder: (context, index) {
                    final gen = _selectedGenFilter ?? sortedGenerations[index];
                    final members = generationMap[gen] ?? [];
                    if (members.isEmpty) return const SizedBox.shrink();

                    return _buildGenerationSection(context, gen, members);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGenFilterChip(int? gen, String label) {
    final isSelected = _selectedGenFilter == gen;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGenFilter = gen;
          });
        },
        borderRadius: HeritageCurves.pill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: HeritageCurves.pill,
            boxShadow: isSelected ? HeritageShadows.activePill : HeritageShadows.card,
          ),
          child: Text(
            label,
            style: HeritageTypography.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerationSection(BuildContext context, int gen, List<Person> members) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generation Milestone Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: HeritageGradients.accentPill,
              borderRadius: HeritageCurves.card,
              boxShadow: HeritageShadows.card,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'G$gen',
                    style: HeritageTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generation $gen: ${_getGenEraTitle(gen)}',
                        style: HeritageTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _getGenEraSubtitle(members),
                        style: HeritageTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Responsive Member Cards Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isMobile ? 0.82 : 0.95,
            ),
            itemBuilder: (context, idx) {
              final person = members[idx];
              return _buildMemberCard(context, person);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Person person) {
    final spouseName = _findSpouseName(person);
    final Color genderAccent = person.gender == Gender.male
        ? AppColors.primary
        : person.gender == Gender.female
            ? AppColors.softMint
            : AppColors.paleSage;

    return InkWell(
      onTap: () => widget.onSelectPerson(person),
      borderRadius: HeritageCurves.card,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: HeritageCurves.card,
          boxShadow: HeritageShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Portrait Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightSage,
                    border: Border.all(color: genderAccent.withOpacity(0.5), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: person.portraitUrl != null && person.portraitUrl!.trim().isNotEmpty
                        ? Image.network(
                            person.portraitUrl!.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => _buildMonogram(person),
                          )
                        : _buildMonogram(person),
                  ),
                ),
                if (!person.isLiving)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.park_outlined, size: 12, color: AppColors.textSecondary),
                    ),
                  )
                else
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco_rounded, size: 12, color: AppColors.primary),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Full Name
            Text(
              person.displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HeritageTypography.titleSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            // Maiden Name or Nickname
            if (person.maidenName != null && person.maidenName!.trim().isNotEmpty) ...[
              Text(
                'née ${person.maidenName}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HeritageTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else if (person.alternateNames.isNotEmpty) ...[
              Text(
                '"${person.alternateNames.first}"',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HeritageTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const Spacer(),

            // Life Span
            Text(
              person.lifeDateSpan,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HeritageTypography.lifeDates.copyWith(
                fontSize: 10,
                color: person.isLiving ? AppColors.primary : AppColors.textSecondary,
                fontWeight: person.isLiving ? FontWeight.w600 : FontWeight.w500,
              ),
            ),

            // Spouse hint if married
            if (spouseName != null) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded, size: 9, color: AppColors.softMint),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      spouseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HeritageTypography.bodySmall.copyWith(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Hometown / Origin
            if (person.birthPlace != null && person.birthPlace!.trim().isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                '📍 ${person.birthPlace!.split(',').first}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HeritageTypography.bodySmall.copyWith(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonogram(Person person) {
    return Center(
      child: Text(
        person.initials,
        style: HeritageTypography.titleMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
