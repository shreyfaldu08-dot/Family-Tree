import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

class PeopleDirectoryScreen extends ConsumerStatefulWidget {
  const PeopleDirectoryScreen({super.key});

  @override
  ConsumerState<PeopleDirectoryScreen> createState() => _PeopleDirectoryScreenState();
}

class _PeopleDirectoryScreenState extends ConsumerState<PeopleDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final isAdmin = ref.watch(isCurrentAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // ===============================================================
            // 1. TOP NAVY HEADER (Screen 2: Deep Navy, Title, Search Pill + Filter)
            // ===============================================================
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                decoration: const BoxDecoration(
                  color: AppColors.primary, // #101D38 Deep Navy
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Back button < and ... button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (isAdmin)
                              IconButton(
                                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                                tooltip: 'Add Person',
                                onPressed: () => context.push('/admin/person/new'),
                              ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.more_horiz_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Title: "Find The Right Relative"
                    Text(
                      'Find The Right\nRelative',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Search Pill + Filter Icon Button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: HeritageCurves.pill,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search relatives, branches...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary.withOpacity(0.7),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textSecondary),
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim();
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Round Filter Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // 2. BENTO CARDS GRID (Screen 2 Reference)
            // ===============================================================
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Large Featured Card (Top: Archibald / Founding Patriarch)
                  InkWell(
                    onTap: () {
                      final all = personsAsync.valueOrNull ?? [];
                      final p = all.where((item) => item.generationHint == 1).firstOrNull ?? all.firstOrNull;
                      if (p != null) context.push('/people/${p.id}');
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      height: 190,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: HeritageShadows.card,
                        color: AppColors.primary,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/images/archibald_portrait.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF1E2E48),
                                child: const Center(
                                  child: Icon(Icons.person, color: Colors.white54, size: 48),
                                ),
                              ),
                            ),
                          ),
                          // Gradient dark overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.78),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 18,
                            bottom: 18,
                            right: 68,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Founding Patriarch',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Generation 1 • Sir Archibald Vansora (1842)',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 18,
                            bottom: 18,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Split 2-Card Row: Vault Documents & Matriarchs
                  Row(
                    children: [
                      // Left Card: Archival Documents
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push('/archive'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: HeritageShadows.card,
                              color: const Color(0xFF2C3E50),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/images/vintage_vault_documents.jpg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFF34495E),
                                      child: const Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 36),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.82),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 14,
                                  bottom: 14,
                                  right: 48,
                                  child: Text(
                                    'Living Vault &\nDocuments',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Right Card: Matriarch Portrait
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            final all = personsAsync.valueOrNull ?? [];
                            final p = all.where((item) => item.gender == Gender.female).firstOrNull ?? all.firstOrNull;
                            if (p != null) context.push('/people/${p.id}');
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: HeritageShadows.card,
                              color: const Color(0xFF1E2A38),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/matriarch_portrait.jpg',
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFF2A3A4D),
                                      child: const Icon(Icons.person, color: Colors.white54, size: 36),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.82),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 14,
                                  bottom: 14,
                                  right: 48,
                                  child: Text(
                                    'Pillars &\nMatriarchs',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // "Talk to a Specialist / Branch Custodians" Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4E3FA), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Branch Custodians',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Consult lineage records with branch admins',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Stacked 3 avatar circles
                        SizedBox(
                          width: 72,
                          height: 34,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: _miniAvatar('assets/images/modern_father.jpg'),
                              ),
                              Positioned(
                                left: 18,
                                child: _miniAvatar('assets/images/user_sara_portrait.jpg'),
                              ),
                              Positioned(
                                left: 36,
                                child: _miniAvatar('assets/images/modern_young_man.jpg'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Circular white arrow
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Directory Members List with real portrait photos
                  Text(
                    'Directory Records',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),
                ]),
              ),
            ),

            // Sliver List for all members
            personsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
              data: (allPersons) {
                var filtered = allPersons;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered.where((p) => p.displayName.toLowerCase().contains(q)).toList();
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final person = filtered[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border, width: 0.8),
                            boxShadow: HeritageShadows.card,
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () => context.push('/people/${person.id}'),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: Image.asset(
                                  person.effectivePortraitAsset,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              person.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              'Generation ${person.generation} • ${person.lifeDateSpan}',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.paleBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _miniAvatar(String asset) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
