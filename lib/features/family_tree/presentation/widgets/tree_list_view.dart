import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../data/models/person.dart';

class TreeListView extends StatefulWidget {
  final List<Person> persons;
  final void Function(Person person) onSelectPerson;

  const TreeListView({
    super.key,
    required this.persons,
    required this.onSelectPerson,
  });

  @override
  State<TreeListView> createState() => _TreeListViewState();
}

class _TreeListViewState extends State<TreeListView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.persons.where((p) {
      if (_query.isEmpty) return true;
      return p.matchesQuery(_query);
    }).toList();

    // Group by generation
    final Map<int, List<Person>> genMap = {};
    for (final p in filtered) {
      final gen = p.generationHint ?? 1;
      genMap.putIfAbsent(gen, () => []).add(p);
    }
    final sortedGens = genMap.keys.toList()..sort();

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: AppColors.background,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.pill,
              boxShadow: HeritageShadows.card,
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search directory...',
                hintStyle: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                icon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchCtrl.clear();
                            _query = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _query = val.trim()),
            ),
          ),
        ),

        // List View grouped by generation
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('No family members found', style: HeritageTypography.bodyMedium),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: sortedGens.length,
                  itemBuilder: (ctx, gIdx) {
                    final gen = sortedGens[gIdx];
                    final members = genMap[gen] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Generation Section Header
                        Padding(
                          padding: const EdgeInsets.only(top: 14, bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.lightSage,
                                  borderRadius: HeritageCurves.pill,
                                ),
                                child: Text(
                                  'Generation $gen',
                                  style: HeritageTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${members.length} members',
                                style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),

                        // Members in this generation
                        ...members.map((p) {
                          final Color genderAccent = p.gender == Gender.male
                              ? AppColors.primary
                              : p.gender == Gender.female
                                  ? AppColors.softMint
                                  : AppColors.paleSage;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => widget.onSelectPerson(p),
                              borderRadius: HeritageCurves.card,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.lightSage,
                                        border: Border.all(color: genderAccent.withOpacity(0.5), width: 1.5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(999),
                                        child: p.portraitUrl != null && p.portraitUrl!.trim().isNotEmpty
                                            ? Image.network(
                                                p.portraitUrl!.trim(),
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => Center(
                                                  child: Text(
                                                    p.initials,
                                                    style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  p.initials,
                                                  style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.displayName,
                                            style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          if (p.maidenName != null) ...[
                                            Text(
                                              'née ${p.maidenName}',
                                              style: HeritageTypography.bodySmall.copyWith(
                                                fontSize: 10.5,
                                                fontStyle: FontStyle.italic,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                          Text(
                                            p.lifeDateSpan + (p.birthPlace != null ? ' • ${p.birthPlace}' : ''),
                                            style: HeritageTypography.bodySmall.copyWith(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.paleSage),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
