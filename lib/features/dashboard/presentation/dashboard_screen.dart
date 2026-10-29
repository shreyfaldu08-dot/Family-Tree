import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/family.dart';
import '../../../data/models/person.dart';
import '../../../data/models/relationship.dart';
import '../../../data/providers/repository_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PageController _siblingPageController = PageController();
  int _siblingPageIndex = 0;
  bool _hasSpouse = false;
  bool _isGenerationsExpanded = false;
@override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _siblingPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(currentFamilyProvider);
    final membershipAsync = ref.watch(currentMembershipProvider);
    final personsAsync = ref.watch(familyPersonsProvider);
    final mediaAsync = ref.watch(familyMediaProvider);
    final relationshipsAsync = ref.watch(familyRelationshipsProvider);

    final membership = membershipAsync.valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;
    final family = familyAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(currentFamilyProvider);
            ref.invalidate(familyPersonsProvider);
            ref.invalidate(familyMediaProvider);
            ref.invalidate(familyRelationshipsProvider);
            ref.invalidate(familyTimelineProvider);
          },
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            children: [
              // =============================================================
              // 1. TOP HEADER (User Portrait + Greeting + Tree ID & Bell)
              // =============================================================
              _buildTopHeader(context, family, isAdmin),

              const SizedBox(height: 18),

              // =============================================================
              // 2. MINIMAL SEARCH & DIRECTORY BAR
              // =============================================================
              _buildMinimalSearchBar(context),

              const SizedBox(height: 16),

              // =============================================================
              // 3. HERITAGE OVERVIEW (Minimalist 3-Metric Summary Bar)
              // =============================================================
              _buildCompactHeritageOverview(personsAsync, mediaAsync),

              const SizedBox(height: 24),

              // =============================================================
              // 4. MY DIRECT LINEAGE HIERARCHY (Cinematic Bento Full-Image Hero)
              // =============================================================
              _buildViewerLineageSection(context, personsAsync, relationshipsAsync),

              const SizedBox(height: 24),

              // =============================================================
              // 5. FAMILY CONNECTION & ENGAGEMENT
              // =============================================================
              _buildFamilyConnectionSection(context, personsAsync.valueOrNull ?? []),



              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Top Header: Refined User avatar, personalized greeting, Tree ID pill, bell
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(BuildContext context, Family? family, bool isAdmin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // User Avatar with delicate double-ring border
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: HeritageShadows.card,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.asset(
                    'assets/images/user_sara_portrait.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.paleBlue,
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Welcome Back,',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.paleBlue,
                            borderRadius: HeritageCurves.pill,
                          ),
                          child: Text(
                            'ID: VANS-8842',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sara Wilson',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Action Button: Notification Bell
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vansora Lineage Vault is synchronized. Tree Code: VANS-8842'),
                duration: Duration(seconds: 2),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 0.8),
              boxShadow: HeritageShadows.card,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 21,
                  color: AppColors.textPrimary,
                ),
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Minimal Clean Search Pill
  // ---------------------------------------------------------------------------
  Widget _buildMinimalSearchBar(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/people'),
      borderRadius: HeritageCurves.pill,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: HeritageCurves.pill,
          border: Border.all(color: AppColors.border, width: 0.9),
          boxShadow: HeritageShadows.card,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search relatives, generations, archives...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary.withOpacity(0.85),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.paleBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 15,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Compact Heritage Overview (Minimal, Breathable, Pure White with Hairlines)
  // ---------------------------------------------------------------------------
  Widget _buildCompactHeritageOverview(
    AsyncValue<List<Person>> personsAsync,
    AsyncValue<List<dynamic>> mediaAsync,
  ) {
    final memberCount = personsAsync.maybeWhen(
      data: (list) => '${list.length}',
      orElse: () => '19',
    );
    final genCount = personsAsync.maybeWhen(
      data: (list) {
        final hints = list.map((p) => p.generationHint).whereType<int>().toSet();
        return '${hints.isNotEmpty ? hints.length : 10}';
      },
      orElse: () => '10',
    );
    final mediaCount = mediaAsync.maybeWhen(
      data: (list) => '${list.length}',
      orElse: () => '24',
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: HeritageShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactMetricItem(
              label: 'Relatives',
              value: memberCount,
              icon: Icons.people_outline_rounded,
            ),
          ),
          Container(
            height: 26,
            width: 1,
            color: AppColors.border.withOpacity(0.7),
          ),
          Expanded(
            child: _buildCompactMetricItem(
              label: 'Generations',
              value: '$genCount/10',
              icon: Icons.account_tree_outlined,
            ),
          ),
          Container(
            height: 26,
            width: 1,
            color: AppColors.border.withOpacity(0.7),
          ),
          Expanded(
            child: _buildCompactMetricItem(
              label: 'Vault Media',
              value: mediaCount,
              icon: Icons.photo_library_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetricItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.paleBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14.5, color: AppColors.primary),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. My Direct Lineage Hierarchy (Bento Full-Image Hero with Frosted Glassmorphism)
  // ---------------------------------------------------------------------------
  Widget _buildViewerLineageSection(
    BuildContext context,
    AsyncValue<List<Person>> personsAsync,
    AsyncValue<List<Relationship>> relsAsync,
  ) {
    final allPersons = personsAsync.valueOrNull ?? [];

    // Find Viewer (Sara Wilson, Generation 9)
    final viewer = allPersons.firstWhere(
      (p) => p.firstName.toLowerCase() == 'sara' || p.id == 'p_gen9_sara',
      orElse: () => allPersons.where((p) => p.generationHint == 9).firstOrNull ??
          allPersons.firstOrNull ??
          Person(
            id: 'p_gen9_sara',
            familyId: 'fam_kensington_01',
            firstName: 'Sara',
            lastName: 'Wilson',
            gender: Gender.female,
            generationHint: 9,
            portraitUrl: 'assets/images/user_sara_portrait.jpg',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    // Find Parents (Generation 8: David & Sophia)
    final father = allPersons.where((p) => p.generationHint == 8 && p.gender == Gender.male).firstOrNull;
    final mother = allPersons.where((p) => p.generationHint == 8 && p.gender == Gender.female).firstOrNull;

    // Find Grandparents (Generation 7: Julian & Helena)
    final grandfather = allPersons.where((p) => p.generationHint == 7 && p.gender == Gender.male).firstOrNull;
    final grandmother = allPersons.where((p) => p.generationHint == 7 && p.gender == Gender.female).firstOrNull;

    // Find Siblings (Generation 9: Lucas & James, brothers of viewer)
    final siblings = allPersons.where((p) => p.generationHint == 9 && p.id != viewer.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Lineage Hierarchy',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Direct ancestral lineage & immediate family branch',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: HeritageCurves.pill,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Text(
                'GEN ${viewer.generationHint ?? 9} • YOU',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 1. Myself as Viewer (Large Full-Image Bento Card OR Married Side-by-Side Cards)
        if (!_hasSpouse)
          _buildSingleViewerCard(context: context, viewer: viewer)
        else
          _buildMarriedViewerRow(context: context, viewer: viewer),

        // 2. Siblings (Option A: Full-Size Bento Photo Cards in Horizontal Scrollable Ribbon)
        if (siblings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSiblingsRibbon(context, siblings),
        ],

        const SizedBox(height: 16),

        // 3. Parents: Father & Mother (2 separate full-image cards side-by-side)
        _buildParentsRow(
          context: context,
          father: father,
          mother: mother,
        ),

        const SizedBox(height: 14),

        // 4. Grandparents: Grandfather & Grandmother (2 separate full-image cards side-by-side)
        _buildGrandparentsRow(
          context: context,
          grandfather: grandfather,
          grandmother: grandmother,
        ),

        const SizedBox(height: 18),

        // 5. "View More" Title & All Generations (Relative to Viewer's Generation)
        _buildViewMoreGenerationsSection(context, viewer, allPersons),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Single Viewer Large Bento Hero Card (Full cover image with cinematic gradient & glassmorphic badges)
  // ---------------------------------------------------------------------------
  Widget _buildSingleViewerCard({
    required BuildContext context,
    required Person viewer,
  }) {
    return InkWell(
      onTap: () => context.push('/people/${viewer.id}'),
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 205,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          color: AppColors.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full cover portrait of Sara Wilson
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.asset(
                viewer.effectivePortraitAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3D6A),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 54),
                  ),
                ),
              ),
            ),

            // 2. Cinematic Dual Gradient for Luxury Depth & Text Legibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                    const Color(0xFF0F223D).withOpacity(0.55),
                    const Color(0xFF0B192C).withOpacity(0.92),
                  ],
                ),
              ),
            ),

            // 3. Inset Hairline Border for Premium Finish
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.9),
              ),
            ),

            // 4. Frosted Glass Status Badge (Top Left)
            Positioned(
              top: 14,
              left: 14,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'YOU • ARCHIVIST',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 5. Card Text Content (Bottom Left)
            Positioned(
              left: 18,
              bottom: 18,
              right: 64,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewer.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Generation ${viewer.generationHint ?? 9} • Living Heritage Archivist',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // 6. Floating White Round Arrow Button (Bottom Right)
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Married Viewer Row (Myself + Spouse Side-by-Side in Bento Image Style)
  // ---------------------------------------------------------------------------
  Widget _buildMarriedViewerRow({
    required BuildContext context,
    required Person viewer,
  }) {
    return Row(
      children: [
        // Viewer Bento Card
        Expanded(
          child: _buildBentoPersonCard(
            context: context,
            rolePill: 'YOU (VIEWER)',
            name: viewer.displayName,
            subtitle: 'Gen ${viewer.generationHint ?? 9} • You',
            imageAsset: viewer.effectivePortraitAsset,
            onTap: () => context.push('/people/${viewer.id}'),
          ),
        ),
        const SizedBox(width: 12),
        // Spouse Bento Card
        Expanded(
          child: _buildBentoPersonCard(
            context: context,
            rolePill: 'SPOUSE',
            name: 'Ethan Wilson',
            subtitle: 'Gen 9 • Married',
            imageAsset: 'assets/images/modern_young_man.jpg',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viewing Ethan Wilson (Spouse)'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            topTrailingWidget: InkWell(
              onTap: () {
                setState(() {
                  _hasSpouse = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Switched back to single viewer card.'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Parents Row (Father & Mother Side-by-Side in Bento Image Style)
  // ---------------------------------------------------------------------------
  Widget _buildParentsRow({
    required BuildContext context,
    required Person? father,
    required Person? mother,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildBentoPersonCard(
            context: context,
            rolePill: 'FATHER',
            name: father?.displayName ?? 'David Kensington',
            subtitle: father?.lifeDateSpan ?? 'Gen 8 • 1962 – Present',
            imageAsset: father?.effectivePortraitAsset ?? 'assets/images/modern_father.jpg',
            onTap: () {
              if (father != null) {
                context.push('/people/${father.id}');
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBentoPersonCard(
            context: context,
            rolePill: 'MOTHER',
            name: mother?.displayName ?? 'Sophia Kensington',
            subtitle: mother?.lifeDateSpan ?? 'Gen 8 • 1966 – Present',
            imageAsset: 'assets/images/vintage_lady_portrait.jpg',
            onTap: () {
              if (mother != null) {
                context.push('/people/${mother.id}');
              }
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Grandparents Row (Grandfather & Grandmother Side-by-Side in Bento Image Style)
  // ---------------------------------------------------------------------------
  Widget _buildGrandparentsRow({
    required BuildContext context,
    required Person? grandfather,
    required Person? grandmother,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildBentoPersonCard(
            context: context,
            rolePill: 'GRANDFATHER',
            name: grandfather?.displayName ?? 'Julian Kensington',
            subtitle: grandfather?.lifeDateSpan ?? 'Gen 7 • 1930 – 2012',
            imageAsset: grandfather?.effectivePortraitAsset ?? 'assets/images/midcentury_father.jpg',
            onTap: () {
              if (grandfather != null) {
                context.push('/people/${grandfather.id}');
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBentoPersonCard(
            context: context,
            rolePill: 'GRANDMOTHER',
            name: grandmother?.displayName ?? 'Helena Kensington',
            subtitle: grandmother?.lifeDateSpan ?? 'Gen 7 • 1935 – 2021',
            imageAsset: 'assets/images/matriarch_portrait.jpg',
            onTap: () {
              if (grandmother != null) {
                context.push('/people/${grandmother.id}');
              }
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable Bento Person Card (Full cover image with gradient overlay & arrow)
  // ---------------------------------------------------------------------------
  Widget _buildBentoPersonCard({
    required BuildContext context,
    required String rolePill,
    required String name,
    required String subtitle,
    required String imageAsset,
    required VoidCallback onTap,
    Widget? topTrailingWidget,
    double height = 155,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          color: AppColors.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3D6A),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 36),
                  ),
                ),
              ),
            ),

            // Smooth dark gradient overlay for deep contrast & readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                    const Color(0xFF0B192C).withOpacity(0.92),
                  ],
                ),
              ),
            ),

            // Inset hairline border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.8),
              ),
            ),

            // 1. Role Pill Badge (Top Left)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.6),
                    ),
                    child: Text(
                      rolePill,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Top Trailing Action: Frosted Translucent Minimal Glass Icon
            Positioned(
              top: 8,
              right: 8,
              child: topTrailingWidget ??
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.24),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.35), width: 0.7),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
            ),

            // 3. Text Content: Single Line Fitted (Never cut, never pushed below)
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Siblings Ribbon (Exactly 3 properly visible per page, no cut-off, with dots when > 3)
  // ---------------------------------------------------------------------------
  Widget _buildSiblingsRibbon(BuildContext context, List<Person> siblings) {
    // Chunk siblings into pages of max 3 items
    final pages = <List<Person>>[];
    for (var i = 0; i < siblings.length; i += 3) {
      final end = (i + 3 > siblings.length) ? siblings.length : i + 3;
      pages.add(siblings.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    'My Siblings',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.paleBlue,
                        borderRadius: HeritageCurves.pill,
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: Text(
                        'BROTHERS & SISTERS • GEN 9',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${siblings.length} ${siblings.length == 1 ? "Sibling" : "Siblings"}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (pages.length <= 1)
          // 3 or fewer siblings: Exactly 3 visible across width, no half cut, no scroll
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (pages.isNotEmpty && i < pages[0].length)
                  Expanded(
                    child: _buildBentoPersonCard(
                      context: context,
                      rolePill: pages[0][i].gender == Gender.female ? 'SISTER' : 'BROTHER',
                      name: pages[0][i].displayName,
                      subtitle: pages[0][i].lifeDateSpan,
                      imageAsset: pages[0][i].effectivePortraitAsset,
                      height: 155,
                      onTap: () => context.push('/people/${pages[0][i].id}'),
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),
                if (i < 2) const SizedBox(width: 8),
              ],
            ],
          )
        else
          // More than 3 siblings: PageView where each page shows exactly 3 max, with dot pagination below
          Column(
            children: [
              SizedBox(
                height: 155,
                child: PageView.builder(
                  controller: _siblingPageController,
                  itemCount: pages.length,
                  onPageChanged: (idx) {
                    setState(() {
                      _siblingPageIndex = idx;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final pageItems = pages[pageIndex];
                    return Row(
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          if (i < pageItems.length)
                            Expanded(
                              child: _buildBentoPersonCard(
                                context: context,
                                rolePill: pageItems[i].gender == Gender.female ? 'SISTER' : 'BROTHER',
                                name: pageItems[i].displayName,
                                subtitle: pageItems[i].lifeDateSpan,
                                imageAsset: pageItems[i].effectivePortraitAsset,
                                height: 155,
                                onTap: () => context.push('/people/${pageItems[i].id}'),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox.shrink()),
                          if (i < 2) const SizedBox(width: 8),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Sleek Floating Capsule Pagination Control
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.pill,
                    border: Border.all(color: AppColors.border, width: 0.8),
                    boxShadow: HeritageShadows.card,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_siblingPageIndex > 0)
                        InkWell(
                          onTap: () {
                            _siblingPageController.previousPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 2),
                      ...List.generate(pages.length, (idx) {
                        final isCurrent = idx == _siblingPageIndex;
                        return InkWell(
                          onTap: () {
                            _siblingPageController.animateToPage(
                              idx,
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          borderRadius: BorderRadius.circular(3),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: isCurrent ? 16 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isCurrent ? AppColors.primary : AppColors.border,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 2),
                      if (_siblingPageIndex < pages.length - 1)
                        InkWell(
                          onTap: () {
                            _siblingPageController.nextPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // "View More" Generations Section (Relative to Viewer)
  // ---------------------------------------------------------------------------
  Widget _buildViewMoreGenerationsSection(
    BuildContext context,
    Person viewer,
    List<Person> allPersons,
  ) {
    final genMap = <int, List<Person>>{};
    for (final p in allPersons) {
      final g = p.generationHint ?? 1;
      genMap.putIfAbsent(g, () => []).add(p);
    }

    // Ensure generations 1 to 10 are represented
    for (int g = 1; g <= 10; g++) {
      genMap.putIfAbsent(g, () => []);
    }

    final totalGenerations = genMap.keys.toList()..sort();
    final viewerGen = viewer.generationHint ?? 9;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        children: [
          // Header / Trigger
          InkWell(
            onTap: () {
              setState(() {
                _isGenerationsExpanded = !_isGenerationsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.paleBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_tree_outlined,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View More Generations',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'All 10 generations relative to you (Generation $viewerGen)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: HeritageCurves.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isGenerationsExpanded ? 'Hide' : 'View More',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          _isGenerationsExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isGenerationsExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                children: totalGenerations.reversed.map((g) {
                  final list = genMap[g] ?? [];
                  final diff = g - viewerGen;
                  final String relativeLabel;
                  final bool isViewerGen = diff == 0;

                  if (diff == 0) {
                    relativeLabel = 'Current Generation (You)';
                  } else if (diff == 1) {
                    relativeLabel = 'Children / Next Generation (+1)';
                  } else if (diff > 1) {
                    relativeLabel = 'Grandchildren (+$diff Gen)';
                  } else if (diff == -1) {
                    relativeLabel = 'Parents (-1 Gen)';
                  } else if (diff == -2) {
                    relativeLabel = 'Grandparents (-2 Gen)';
                  } else if (diff == -3) {
                    relativeLabel = 'Great-Grandparents (-3 Gen)';
                  } else if (diff == -4) {
                    relativeLabel = '2nd Great-Grandparents (-4 Gen)';
                  } else if (diff == -5) {
                    relativeLabel = '3rd Great-Grandparents (-5 Gen)';
                  } else if (diff == -6) {
                    relativeLabel = '4th Great-Grandparents (-6 Gen)';
                  } else if (diff == -7) {
                    relativeLabel = '5th Great-Grandparents (-7 Gen)';
                  } else if (diff == -8) {
                    relativeLabel = 'Founding Ancestors (Root • -8 Gen)';
                  } else {
                    relativeLabel = '${(-diff)}th Ancestral Generation';
                  }

                  final namesSummary = list.isNotEmpty
                      ? list.map((p) => p.firstName).take(2).join(' & ')
                      : 'Records in archive';

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: isViewerGen ? AppColors.paleBlue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isViewerGen ? AppColors.primary.withOpacity(0.35) : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isViewerGen ? AppColors.primary : AppColors.secondaryNavy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'GEN $g',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                relativeLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: isViewerGen ? FontWeight.w700 : FontWeight.w600,
                                  color: isViewerGen ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${list.length} ${list.length == 1 ? "member" : "members"} • $namesSummary',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => context.push('/tree'),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. Family Connection & Engagement Section (Milestones, Reunions, Vault)
  // ===========================================================================
  Widget _buildFamilyConnectionSection(BuildContext context, List<Person> allPersons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family Connection & Engagement',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Milestones, annual reunions & shared vault memories',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: HeritageCurves.pill,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'ACTIVE',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Subsection 1: Annual Kensington Family Gathering Banner
        _buildAnnualGatheringCard(context),

        const SizedBox(height: 14),

        // Subsection 2: Grandfather's Brother & Extended Cousins Branch
        _buildGrandfatherBrothersAndCousinsCard(context),

        const SizedBox(height: 14),

        // Subsection 3: Upcoming Birthdays & Anniversaries Calendar Card
        _buildBirthdaysAndAnniversariesCalendarCard(context),


      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Birthdays & Anniversaries Calendar Card (Consistent 2x2 Square Grid & Blue/Beige Palette)
  // ---------------------------------------------------------------------------
  Widget _buildBirthdaysAndAnniversariesCalendarCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF16325B), // Deep Dusk Blue
            Color(0xFF0D1E36), // Rich Midnight Navy
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFC7B198).withOpacity(0.35), // Warm Beige Hairline
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1E36).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Cream & Beige Typography on Dusk Blue Gradient)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Birthdays & Anniversaries',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Upcoming celebrations, milestones & remembrance days',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFFD6C8B4), // Warm Sand / Beige
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C8B4).withOpacity(0.18),
                  borderRadius: HeritageCurves.pill,
                  border: Border.all(
                    color: const Color(0xFFD6C8B4).withOpacity(0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: Color(0xFFEFE8DC),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4 MILESTONES',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEFE8DC),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x2 Square Grid of Milestones (Consistent with Cousins Branch layout)
          Row(
            children: [
              // Top-Left: Oliver's 22nd Birthday
              Expanded(
                child: _buildSquareMilestoneCard(
                  context: context,
                  month: 'NOV',
                  day: '14',
                  title: "Oliver's 22nd",
                  subtitle: 'Cousin Brother • Gen 9',
                  badgeText: 'IN 16 DAYS',
                  badgeColor: const Color(0xFF7C3AED),
                  badgeBgColor: const Color(0xFFF5F3FF),
                  imageAsset: 'assets/images/modern_young_man.jpg',
                  actionLabel: 'Wish 🎂',
                  actionIcon: Icons.cake_outlined,
                  onAction: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Birthday greeting scheduled for Oliver on Nov 14! 🎂"),
                      backgroundColor: Color(0xFF16325B),
                    ),
                  ),
                  onCardTap: () => context.push('/people/p_gen9_oliver'),
                ),
              ),
              const SizedBox(width: 10),
              // Top-Right: Parents David & Sophia's 34th Anniversary
              Expanded(
                child: _buildSquareMilestoneCard(
                  context: context,
                  month: 'DEC',
                  day: '04',
                  title: "Parents' 34th",
                  subtitle: 'David & Sophia • Gen 8',
                  badgeText: '34 YEARS',
                  badgeColor: const Color(0xFFB45309),
                  badgeBgColor: const Color(0xFFFEF3C7),
                  imageAsset: 'assets/images/modern_father.jpg',
                  secondaryImageAsset: 'assets/images/vintage_lady_portrait.jpg',
                  actionLabel: 'Cheer 🥂',
                  actionIcon: Icons.favorite_border_rounded,
                  onAction: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Anniversary celebration note saved for David & Sophia! 🥂"),
                      backgroundColor: Color(0xFF16325B),
                    ),
                  ),
                  onCardTap: () => context.push('/people/p_gen8_david'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Bottom-Left: Grandfather Julian Kensington Memorial Day
              Expanded(
                child: _buildSquareMilestoneCard(
                  context: context,
                  month: 'JAN',
                  day: '08',
                  title: "Julian's Memorial",
                  subtitle: 'Grandfather • 1930–2012',
                  badgeText: 'MEMORIAL',
                  badgeColor: const Color(0xFF475569),
                  badgeBgColor: const Color(0xFFF1F5F9),
                  imageAsset: 'assets/images/vintage_elder_father.jpg',
                  actionLabel: 'Vault 📜',
                  actionIcon: Icons.history_edu_rounded,
                  onAction: () => context.push('/archive'),
                  onCardTap: () => context.push('/people/p_gen7_julian'),
                ),
              ),
              const SizedBox(width: 10),
              // Bottom-Right: Baby Noah 1st Month Milestone (Generation 10)
              Expanded(
                child: _buildSquareMilestoneCard(
                  context: context,
                  month: 'FEB',
                  day: '14',
                  title: "Baby Noah",
                  subtitle: 'Elena • Generation 10',
                  badgeText: 'NEWBORN',
                  badgeColor: const Color(0xFF059669),
                  badgeBgColor: const Color(0xFFECFDF5),
                  imageAsset: 'assets/images/child_portrait.jpg',
                  actionLabel: 'Love ❤️',
                  actionIcon: Icons.favorite_rounded,
                  onAction: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You sent love to Baby Noah and Elena! ❤️"),
                      backgroundColor: Color(0xFF16325B),
                    ),
                  ),
                  onCardTap: () => context.push('/people/p_gen9_elena'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: const Color(0xFFC7B198).withOpacity(0.22)),
          const SizedBox(height: 10),

          // Action footer in Warm Champagne
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viewing All Family Dates & Milestones for 2026'),
                  backgroundColor: Color(0xFF16325B),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Full 2026 Family Milestone Calendar',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE5D9C8), // Champagne Beige
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: Color(0xFFE5D9C8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Square Milestone Card Helper (Consistent Square Design in Linen & Navy)
  // ---------------------------------------------------------------------------
  Widget _buildSquareMilestoneCard({
    required BuildContext context,
    required String month,
    required String day,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBgColor,
    required String imageAsset,
    String? secondaryImageAsset,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onAction,
    required VoidCallback onCardTap,
  }) {
    return InkWell(
      onTap: onCardTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2), // Warm Linen / Beige Tile
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2D6C3), // Soft Sand Hairline Border
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Date Box & Portrait Avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Calendar Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3863), // Deep Navy
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFC7B198).withOpacity(0.4),
                      width: 0.7,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        month,
                        style: GoogleFonts.inter(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFDFCEB5), // Champagne Gold
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 3.5),
                      Text(
                        day,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Avatar or Stacked Avatars
                if (secondaryImageAsset != null)
                  SizedBox(
                    width: 44,
                    height: 30,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2D6C3), width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Image.asset(imageAsset, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2D6C3), width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Image.asset(secondaryImageAsset, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2D6C3), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFEFE8DC),
                          child: const Icon(Icons.person, size: 16, color: Color(0xFF16325B)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Bold Event Title
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F2447), // Deep Navy text
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Subtitle
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5A6B82),
              ),
            ),
            const SizedBox(height: 8),

            // Milestone Badge & Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: badgeColor.withOpacity(0.2), width: 0.6),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Interactive Pill Action
                InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF16325B).withOpacity(0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(actionIcon, size: 9.5, color: const Color(0xFF16325B)),
                        const SizedBox(width: 3),
                        Text(
                          actionLabel,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16325B),
                          ),
                        ),
                      ],
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

  // ---------------------------------------------------------------------------
  // Annual Gathering Banner (Cinematic Full Cover Bento Style)
  // ---------------------------------------------------------------------------
  Widget _buildAnnualGatheringCard(BuildContext context) {
    return Container(
      height: 196,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background photo
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset(
              'assets/images/family_gathering.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1B3D6A),
                child: const Center(
                  child: Icon(Icons.people_rounded, size: 40, color: Colors.white54),
                ),
              ),
            ),
          ),

          // 2. Cinematic Gradient overlay for depth & readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.40, 1.0],
                colors: [
                  Colors.black.withOpacity(0.35),
                  const Color(0xFF0F223D).withOpacity(0.60),
                  const Color(0xFF0A1728).withOpacity(0.95),
                ],
              ),
            ),
          ),

          // 3. Inset hairline border for premium finish
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.9),
            ),
          ),

          // 4. Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Days Countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.6),
                          ),
                          child: Text(
                            'ANNUAL REUNION • SUMMER 2026',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: HeritageCurves.pill,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'IN 82 DAYS',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Middle: Title & Subtitle (Full width, no horizontal squeeze)
                Text(
                  'Kensington Family Gathering',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'July 18 – 20, 2026 • Lakeview Estate Grounds, WA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.88),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom Row: Avatars on Left, RSVP Pill Button on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 58,
                          height: 24,
                          child: Stack(
                            children: [
                              Positioned(left: 0, child: _buildMiniAvatar('assets/images/user_sara_portrait.jpg')),
                              Positioned(left: 14, child: _buildMiniAvatar('assets/images/modern_father.jpg')),
                              Positioned(left: 28, child: _buildMiniAvatar('assets/images/modern_young_man.jpg')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+14 attending',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reunion RSVP: You are registered as attending!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'RSVP',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String asset) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card 1: Grandfather's Brother & Extended Cousins Branch
  // (2x2 Grid of Relatives styled after modern boutique reference cards with Arc Rings)
  // ---------------------------------------------------------------------------
  Widget _buildGrandfatherBrothersAndCousinsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Grandfather's Brother & Cousins Branch",
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Great-Uncle William's lineage & living cousins in Gen 9",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: HeritageCurves.pill,
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Text(
                  '6 RELATIVES',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x2 Grid of Relatives (Explicit Cousins & Extended Branch with Live Navigation)
          Row(
            children: [
              // Top-Left: Cousin Brother (Oliver)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  title: 'Cousin Brother',
                  personName: 'Oliver Kensington',
                  rolePill: 'COUSIN',
                  imageAsset: 'assets/images/modern_young_man.jpg',
                  ringColor: const Color(0xFF8B5CF6),
                  pillBgColor: const Color(0xFFF5F3FF),
                  sweepAngle: 5.0,
                  onTap: () => context.push('/people/p_gen9_oliver'),
                ),
              ),
              const SizedBox(width: 10),
              // Top-Right: Cousin Sister (Clara)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  title: 'Cousin Sister',
                  personName: 'Clara Kensington',
                  rolePill: 'COUSIN',
                  imageAsset: 'assets/images/child_portrait.jpg',
                  ringColor: const Color(0xFFEC4899),
                  pillBgColor: const Color(0xFFFDF2F8),
                  sweepAngle: 4.2,
                  onTap: () => context.push('/people/p_gen9_clara'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Bottom-Left: Grandfather's Brother (William)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  title: "Grandfather's Brother",
                  personName: 'William Kensington',
                  rolePill: 'GREAT-UNCLE',
                  imageAsset: 'assets/images/vintage_elder_father.jpg',
                  ringColor: const Color(0xFF26538D),
                  pillBgColor: const Color(0xFFEBF3FC),
                  sweepAngle: 4.8,
                  onTap: () => context.push('/people/p_gen7_william'),
                ),
              ),
              const SizedBox(width: 10),
              // Bottom-Right: Cousin's Father / Uncle (Richard)
              Expanded(
                child: _buildReferenceStyleRelativeCard(
                  context: context,
                  title: "Cousin's Father",
                  personName: 'Richard Kensington',
                  rolePill: 'UNCLE',
                  imageAsset: 'assets/images/modern_father.jpg',
                  ringColor: const Color(0xFF4F46E5),
                  pillBgColor: const Color(0xFFEEF2FF),
                  sweepAngle: 4.4,
                  onTap: () => context.push('/people/p_gen8_richard'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Action footer
          InkWell(
            onTap: () => context.push('/tree?personId=p_gen9_oliver'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore Collateral Cousins Branch in Tree',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reference-Style Relative Card (Avatar + Colored Arc Ring + Title + Subtitle)
  // ---------------------------------------------------------------------------
  Widget _buildReferenceStyleRelativeCard({
    required BuildContext context,
    required String title,
    required String personName,
    required String rolePill,
    required String imageAsset,
    required Color ringColor,
    required Color pillBgColor,
    required double sweepAngle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.85), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: ringColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top: Arc Ring Portrait Avatar & Role Pill Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(
                    painter: _HeritageArcRingPainter(
                      color: ringColor,
                      sweepAngle: sweepAngle,
                      strokeWidth: 2.3,
                    ),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset(
                            imageAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.paleBlue,
                              child: Icon(Icons.person, size: 20, color: ringColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ringColor.withOpacity(0.25), width: 0.6),
                  ),
                  child: Text(
                    rolePill,
                    style: GoogleFonts.inter(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                      color: ringColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Bold Title: e.g. "Cousin Brother", "Cousin Sister", "Grandfather's Brother"
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Subtitle: Person Name
            Text(
              personName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),

            // Action Affordance (Go inside)
            Row(
              children: [
                Text(
                  'View Profile',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: ringColor,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 10,
                  color: ringColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}


// ---------------------------------------------------------------------------
// Heritage Arc Ring Painter (Matches modern circular progress arc reference)
// ---------------------------------------------------------------------------
class _HeritageArcRingPainter extends CustomPainter {
  final Color color;
  final double sweepAngle;
  final double strokeWidth;

  const _HeritageArcRingPainter({
    required this.color,
    this.sweepAngle = 4.71239, // ~270 degrees
    this.strokeWidth = 2.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Subtle track circle behind
    final trackPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Dynamic accent arc with rounded caps
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start at top (-90 degrees)
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeritageArcRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.sweepAngle != sweepAngle;
}
