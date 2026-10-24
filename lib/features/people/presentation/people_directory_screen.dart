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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('People Directory', style: HeritageTypography.displaySmall),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: AppColors.textPrimary),
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
            color: AppColors.background,
            child: Column(
              children: [
                // Search field (Unified borderless capsule pill)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.pill,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by full, maiden, or alternate name...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
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
                        color: AppColors.textPrimary,
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

          const SizedBox(height: 6),

          // List of Persons
          Expanded(
            child: personsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
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
                                color: AppColors.lightSage,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_search_rounded,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Family Members Found',
                              style: HeritageTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try adjusting your search query, or clear your filters to view all recorded ancestors.',
                              textAlign: TextAlign.center,
                              style: HeritageTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
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
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: HeritageCurves.card,
                        boxShadow: HeritageShadows.card,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: HeritageCurves.card,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        onTap: () => context.push('/people/${person.id}'),
                        leading: Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.lightSage,
                              ),
                              child: Center(
                                child: Text(
                                  person.initials,
                                  style: HeritageTypography.titleMedium.copyWith(
                                    color: AppColors.primary,
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
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    size: 13,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          person.displayName,
                          style: HeritageTypography.titleSmall.copyWith(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
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
                                style: HeritageTypography.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
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
          color: isSelected ? AppColors.paleSage : AppColors.lightSage,
          borderRadius: HeritageCurves.pill,
          boxShadow: isSelected ? HeritageShadows.activePill : null,
        ),
        child: Text(
          label,
          style: HeritageTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
