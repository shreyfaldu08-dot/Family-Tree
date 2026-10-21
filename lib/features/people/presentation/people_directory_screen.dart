import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/providers/repository_providers.dart';

enum LifeStatusFilter { all, living, deceased }
enum SortOrder { chronological, alphabetical }

class PeopleDirectoryScreen extends ConsumerStatefulWidget {
  const PeopleDirectoryScreen({super.key});

  @override
  ConsumerState<PeopleDirectoryScreen> createState() => _PeopleDirectoryScreenState();
}

class _PeopleDirectoryScreenState extends ConsumerState<PeopleDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  LifeStatusFilter _statusFilter = LifeStatusFilter.all;
  SortOrder _sortOrder = SortOrder.chronological;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final membership = ref.watch(currentMembershipProvider).valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('People Directory', style: HeritageTypography.displaySmall),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: HeritageColors.charcoal),
              tooltip: 'Add Person Record',
              onPressed: () => context.push('/admin/persons/new'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: HeritageColors.background,
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by full, maiden, or alternate name...',
                    prefixIcon: const Icon(Icons.search, color: HeritageColors.charcoalMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
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

                const SizedBox(height: 10),

                // Status & Sort Filter Chips
                Row(
                  children: [
                    // Life Status Filter
                    Wrap(
                      spacing: 6,
                      children: [
                        _filterChip('All', LifeStatusFilter.all),
                        _filterChip('Living', LifeStatusFilter.living),
                        _filterChip('Deceased', LifeStatusFilter.deceased),
                      ],
                    ),
                    const Spacer(),
                    // Sort order toggle
                    IconButton(
                      icon: Icon(
                        _sortOrder == SortOrder.chronological
                            ? Icons.history
                            : Icons.sort_by_alpha,
                        color: HeritageColors.charcoal,
                      ),
                      tooltip: _sortOrder == SortOrder.chronological
                          ? 'Sort: Chronological'
                          : 'Sort: Alphabetical',
                      onPressed: () {
                        setState(() {
                          _sortOrder = _sortOrder == SortOrder.chronological
                              ? SortOrder.alphabetical
                              : SortOrder.chronological;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List of Persons
          Expanded(
            child: personsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: HeritageColors.forestGreen),
              ),
              error: (err, _) => Center(child: Text('Error loading directory: $err')),
              data: (allPersons) {
                // Apply search filter
                var filtered = allPersons.where((p) => p.matchesQuery(_searchQuery)).toList();

                // Apply life status filter
                if (_statusFilter == LifeStatusFilter.living) {
                  filtered = filtered.where((p) => p.isLiving).toList();
                } else if (_statusFilter == LifeStatusFilter.deceased) {
                  filtered = filtered.where((p) => !p.isLiving).toList();
                }

                // Apply sorting
                if (_sortOrder == SortOrder.chronological) {
                  filtered.sort((a, b) {
                    final aYear = a.birthDate?.year ?? a.birthYearApprox ?? 1700;
                    final bYear = b.birthDate?.year ?? b.birthYearApprox ?? 1700;
                    return aYear.compareTo(bYear);
                  });
                } else {
                  filtered.sort((a, b) => a.lastName.compareTo(b.lastName));
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_search_outlined, size: 48, color: HeritageColors.sage),
                          const SizedBox(height: 12),
                          Text('No Family Members Found', style: HeritageTypography.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Try adjusting your search query or status filter.',
                            textAlign: TextAlign.center,
                            style: HeritageTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final person = filtered[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        gradient: HeritageGradients.premiumCard,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: HeritageShadows.card,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onTap: () => context.push('/people/${person.id}'),
                        leading: Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: HeritageGradients.avatarPill,
                              ),
                              child: Center(
                                child: Text(
                                  person.initials,
                                  style: HeritageTypography.titleMedium.copyWith(
                                    color: HeritageColors.forestGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            if (person.isVerified)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    gradient: HeritageGradients.successBadge,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: HeritageColors.statusSuccess,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          person.displayName,
                          style: HeritageTypography.titleSmall.copyWith(fontSize: 15),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(person.lifeDateSpan, style: HeritageTypography.lifeDates),
                            if (person.birthPlace != null && person.birthPlace!.isNotEmpty)
                              Text(
                                person.birthPlace!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: HeritageTypography.bodySmall.copyWith(fontSize: 11),
                              ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: HeritageColors.charcoalMuted,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, LifeStatusFilter filter) {
    final isSelected = _statusFilter == filter;
    return InkWell(
      onTap: () {
        setState(() {
          _statusFilter = filter;
        });
      },
      borderRadius: HeritageCurves.pill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
          label,
          style: HeritageTypography.labelSmall.copyWith(
            color: isSelected ? HeritageColors.charcoal : HeritageColors.charcoalMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
