import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/family.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

enum FamilyCategoryFilter {
  all('All'),
  living('Living Relatives'),
  ancestors('Ancestors'),
  gen1to3('Gen 1–3'),
  gen4to7('Gen 4–7'),
  gen8plus('Gen 8–10');

  final String label;
  const FamilyCategoryFilter(this.label);
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  FamilyCategoryFilter _activeFilter = FamilyCategoryFilter.all;
  bool _isGuideExpanded = false;
  bool _showAllMembers = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _scrollToSearch() {
    _searchFocusNode.requestFocus();
  }

  List<Person> _filterPersons(List<Person> persons) {
    var result = persons.where((p) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = p.displayName.toLowerCase().contains(query);
        final matchesAlt = p.alternateNames.any((a) => a.toLowerCase().contains(query));
        final matchesPlace = (p.birthPlace?.toLowerCase().contains(query) ?? false) ||
            (p.deathPlace?.toLowerCase().contains(query) ?? false);
        final matchesBio = p.bio?.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesAlt && !matchesPlace && !matchesBio) {
          return false;
        }
      }

      // 2. Category Filter
      switch (_activeFilter) {
        case FamilyCategoryFilter.all:
          return true;
        case FamilyCategoryFilter.living:
          return p.isLiving;
        case FamilyCategoryFilter.ancestors:
          return !p.isLiving;
        case FamilyCategoryFilter.gen1to3:
          final gen = p.generationHint ?? 1;
          return gen >= 1 && gen <= 3;
        case FamilyCategoryFilter.gen4to7:
          final gen = p.generationHint ?? 4;
          return gen >= 4 && gen <= 7;
        case FamilyCategoryFilter.gen8plus:
          final gen = p.generationHint ?? 8;
          return gen >= 8;
      }
    }).toList();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(currentFamilyProvider);
    final membershipAsync = ref.watch(currentMembershipProvider);
    final personsAsync = ref.watch(familyPersonsProvider);
    final mediaAsync = ref.watch(familyMediaProvider);
    final eventsAsync = ref.watch(familyTimelineProvider);

    final membership = membershipAsync.valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;
    final family = familyAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: HeritageGradients.accentPill,
                borderRadius: HeritageCurves.pill,
                boxShadow: HeritageShadows.activePill,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 16,
                color: HeritageColors.charcoal,
              ),
            ),
            const SizedBox(width: 8),
            Text('Vansora', style: HeritageTypography.displaySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGuideExpanded ? Icons.help_rounded : Icons.help_outline_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'How Vansora Works',
            onPressed: () {
              setState(() {
                _isGuideExpanded = !_isGuideExpanded;
              });
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: HeritageColors.forestGreen),
              tooltip: 'Admin Workspace',
              onPressed: () => context.push('/admin'),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: HeritageColors.charcoal),
            tooltip: 'Settings',
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
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // -------------------------------------------------------------
            // PROBLEM 1 SOLUTION: Hero Welcome & Purpose Onboarding Capsule
            // -------------------------------------------------------------
            _buildWelcomeHeroCapsule(context, family, isAdmin),

            const SizedBox(height: 14),

            // Collapsible "How Vansora Works" Quick Guide
            if (_isGuideExpanded) ...[
              _buildHowItWorksGuide(),
              const SizedBox(height: 16),
            ],

            // 3 Guided Launchpads (Living Tree, Member Directory, Vault)
            _buildQuickLaunchpads(context),

            const SizedBox(height: 24),

            // -------------------------------------------------------------
            // PROBLEM 2 SOLUTION: Effortless Family Discovery & Member Search
            // -------------------------------------------------------------
            _buildFamilyDiscoverySection(context, personsAsync),

            const SizedBox(height: 28),

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
                    label: 'Generations',
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

            // Featured Historical Memory Section
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

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Problem 1: Onboarding Hero Capsule
  // ---------------------------------------------------------------------------
  Widget _buildWelcomeHeroCapsule(BuildContext context, Family? family, bool isAdmin) {
    final familyName = family?.name ?? 'The Kensington Heritage';

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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      isAdmin ? 'PRIMARY ARCHON • $familyName' : 'PRIVATE FAMILY SANCTUARY',
                      style: HeritageTypography.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isGuideExpanded = !_isGuideExpanded;
                  });
                },
                borderRadius: HeritageCurves.pill,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.85),
                    borderRadius: HeritageCurves.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isGuideExpanded ? Icons.visibility_off_outlined : Icons.help_outline_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isGuideExpanded ? 'Close Guide' : 'How it works',
                        style: HeritageTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your Living Family Heritage',
            style: HeritageTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Welcome to Vansora — your private digital sanctuary to explore generations of lineage, discover ancestors, preserve precious family photographs, and connect with living relatives.',
            style: HeritageTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Problem 1: "How Vansora Works" Interactive Guide Capsule
  // ---------------------------------------------------------------------------
  Widget _buildHowItWorksGuide() {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.lightSage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Getting Started with Vansora',
                  style: HeritageTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGuideStep(
            icon: Icons.account_tree_rounded,
            title: '1. Explore Interactive Family Tree',
            description: 'Navigate up to 10 generations of lineage with zoom and pan. Tap any relative to explore their branch.',
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            icon: Icons.person_search_rounded,
            title: '2. Instant Family Members Lookup',
            description: 'Use the live search bar below to filter relatives by generation, living status, or life stories.',
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            icon: Icons.photo_library_outlined,
            title: '3. Preserved Records & Memories',
            description: 'Browse archival certificates, verified life stories, and cherished photographs in the vault.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.paleSage,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: HeritageTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: HeritageTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3 Guided Launchpads (Tree, Directory, Archive)
  // ---------------------------------------------------------------------------
  Widget _buildQuickLaunchpads(BuildContext context) {
    return Column(
      children: [
        // Launchpad 1: Living Tree
        InkWell(
          onTap: () => context.push('/tree'),
          borderRadius: HeritageCurves.card,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.card,
              boxShadow: HeritageShadows.card,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.lightSage,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_tree_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Living Heritage Tree',
                        style: HeritageTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Interactive 10-generation tree with direct lineages',
                        style: HeritageTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightSage,
                    borderRadius: HeritageCurves.pill,
                  ),
                  child: Text(
                    'Open Tree',
                    style: HeritageTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Launchpad 2 & 3: Directory and Vault (Side by Side)
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _scrollToSearch,
                borderRadius: HeritageCurves.card,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.card,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.lightSage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Family Members',
                              style: HeritageTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Search & Directory',
                              style: HeritageTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => context.push('/archive'),
                borderRadius: HeritageCurves.card,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.card,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.lightSage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Archival Vault',
                              style: HeritageTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Photos & Records',
                              style: HeritageTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Problem 2: Effortless Family Members Discovery & Quick Search
  // ---------------------------------------------------------------------------
  Widget _buildFamilyDiscoverySection(BuildContext context, AsyncValue<List<Person>> personsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with View All Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Family Members', style: HeritageTypography.displaySmall),
                const SizedBox(height: 2),
                Text(
                  'Quickly explore and locate any relative',
                  style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.push('/people'),
              icon: const Icon(Icons.people_outline_rounded, size: 16),
              label: const Text('All Directory'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Real-Time Search Field Capsule (Unified borderless capsule pill)
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: HeritageCurves.pill,
            boxShadow: HeritageShadows.card,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search by relative name, birthplace, or generation...',
              hintStyle: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
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

        // Quick Category Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: FamilyCategoryFilter.values.map((filter) {
              final isSelected = _activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _activeFilter = filter;
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
                      filter.label,
                      style: HeritageTypography.labelSmall.copyWith(
                        color: isSelected ? AppColors.surface : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // Members List or Empty State
        personsAsync.when(
          loading: () => Container(
            height: 90,
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
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text('Loading family connections...', style: HeritageTypography.bodySmall),
              ],
            ),
          ),
          error: (err, _) => const SizedBox.shrink(),
          data: (persons) {
            final filtered = _filterPersons(persons);

            if (filtered.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.card,
                  boxShadow: HeritageShadows.card,
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.person_search_rounded, size: 36, color: AppColors.primary),
                    const SizedBox(height: 10),
                    Text(
                      'No matching relatives found',
                      style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try searching by first or last name, or clear filters.',
                      style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _activeFilter = FamilyCategoryFilter.all;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightSage,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                      ),
                      child: const Text('Reset Search & Filters'),
                    ),
                  ],
                ),
              );
            }

            // If not searching and not showing all, display top 4
            final displayList = (_searchQuery.isNotEmpty || _showAllMembers)
                ? filtered
                : filtered.take(4).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match Count Indicator
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Showing ${displayList.length} of ${filtered.length} relatives',
                    style: HeritageTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Member Capsule Cards
                ...displayList.map((person) => _buildMemberCapsuleCard(context, person)),

                // Expand / Collapse or View All Toggle
                if (_searchQuery.isEmpty && filtered.length > 4) ...[
                  const SizedBox(height: 6),
                  Center(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showAllMembers = !_showAllMembers;
                        });
                      },
                      borderRadius: HeritageCurves.pill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: HeritageCurves.pill,
                          boxShadow: HeritageShadows.card,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _showAllMembers
                                  ? 'Show Less'
                                  : 'Show All ${filtered.length} Relatives',
                              style: HeritageTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _showAllMembers ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Problem 2: Rich Lineage Member Capsule Card
  // ---------------------------------------------------------------------------
  Widget _buildMemberCapsuleCard(BuildContext context, Person person) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: HeritageCurves.card,
        boxShadow: HeritageShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar + Name + Generation Pill
            Row(
              children: [
                // Avatar with Verification Badge
                Stack(
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
                          style: HeritageTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
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
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Name & Lifespan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.displayName,
                        style: HeritageTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        person.lifeDateSpan,
                        style: HeritageTypography.lifeDates,
                      ),
                    ],
                  ),
                ),
                // Generation / Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: person.isLiving ? AppColors.softMint.withOpacity(0.4) : AppColors.lightSage,
                    borderRadius: HeritageCurves.pill,
                  ),
                  child: Text(
                    person.isLiving
                        ? 'Living'
                        : 'Gen ${person.generationHint ?? "Ancestor"}',
                    style: HeritageTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            if (person.birthPlace != null && person.birthPlace!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      person.birthPlace!,
                      style: HeritageTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // 1-Tap Action Pill Buttons (Profile & Locate in Tree)
            Row(
              children: [
                // Button 1: View Profile
                Expanded(
                  child: InkWell(
                    onTap: () => context.push('/people/${person.id}'),
                    borderRadius: HeritageCurves.pill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightSage,
                        borderRadius: HeritageCurves.pill,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'View Profile',
                            style: HeritageTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Button 2: Locate in Family Tree
                Expanded(
                  child: InkWell(
                    onTap: () => context.push('/tree?personId=${person.id}'),
                    borderRadius: HeritageCurves.pill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: HeritageCurves.pill,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_tree_rounded, size: 15, color: AppColors.surface),
                          const SizedBox(width: 6),
                          Text(
                            'Locate in Tree',
                            style: HeritageTypography.labelSmall.copyWith(
                              color: AppColors.surface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
              fontSize: 20,
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
