import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

class PersonProfileScreen extends ConsumerStatefulWidget {
  final String personId;

  const PersonProfileScreen({super.key, required this.personId});

  @override
  ConsumerState<PersonProfileScreen> createState() => _PersonProfileScreenState();
}

class _PersonProfileScreenState extends ConsumerState<PersonProfileScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final relationshipsAsync = ref.watch(familyRelationshipsProvider);
    final isAdmin = ref.watch(isCurrentAdminProvider);

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
        final person = allPersons.where((p) => p.id == widget.personId).firstOrNull;
        if (person == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('Person record not found.')),
          );
        }

        final allRels = relationshipsAsync.valueOrNull ?? const [];

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

        final canEdit = ref.watch(canEditPersonProvider(person.id));

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Scrollable Content
              CustomScrollView(
                slivers: [
                  // =========================================================
                  // 1. TOP HERO PHOTOGRAPHY (Screen 3 Reference)
                  // =========================================================
                  SliverAppBar(
                    expandedHeight: 330,
                    pinned: true,
                    backgroundColor: AppColors.background,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Center(
                        child: InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: HeritageShadows.card,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: HeritageShadows.card,
                              ),
                              child: Icon(
                                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 20,
                                color: _isFavorite ? AppColors.statusError : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'person_portrait_${person.id}',
                        child: Image.asset(
                          person.effectivePortraitAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.softBlueGrey,
                            child: const Center(
                              child: Icon(Icons.person, size: 64, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // =========================================================
                  // 2. OVERLAPPING WHITE PROFILE CARD (Screen 3 Reference)
                  // =========================================================
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row + Favorite Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      person.displayName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Generation ${person.generation} • ${person.gender == Gender.female ? 'Matriarchal Line' : 'Patriarchal Line'}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isAdmin || canEdit)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                  tooltip: 'Edit Record',
                                  onPressed: () => context.push('/admin/person/${person.id}/edit'),
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Rating / Verification Row
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFEAB308)),
                              const SizedBox(width: 4),
                              Text(
                                '4.9',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${person.isVerified ? 'Archival Verified' : 'Documented'} • ${person.lifeDateSpan})',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // 4 Circular Specification Pills (Screen 3 Feature Grid)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSpecPill(
                                icon: Icons.favorite_border_rounded,
                                title: 'Lineage',
                                subtitle: 'Root Heritage',
                              ),
                              _buildSpecPill(
                                icon: Icons.people_outline_rounded,
                                title: 'Children',
                                subtitle: '${children.length} Direct',
                              ),
                              _buildSpecPill(
                                icon: Icons.account_tree_outlined,
                                title: 'Generation',
                                subtitle: 'Gen ${person.generation}',
                              ),
                              _buildSpecPill(
                                icon: Icons.verified_user_outlined,
                                title: 'Archive',
                                subtitle: person.isLiving ? 'Living' : 'Preserved',
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),

                          // Lineage Overview / Biography Heading
                          Text(
                            'Lineage Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            person.bio != null && person.bio!.trim().isNotEmpty
                                ? person.bio!
                                : '${person.displayName} is documented in the Vansora Heritage Sanctuary under Generation ${person.generation}. Recorded events and direct relationships preserve the historical continuity of the family branch.',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              height: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Family Connections Section (with real portrait avatar photos!)
                          Text(
                            'Immediate Connections',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (parents.isEmpty && spouses.isEmpty && children.isEmpty)
                            Text(
                              'No direct parents or children recorded yet.',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            )
                          else
                            Column(
                              children: [
                                ...parents.map((p) => _buildRelativeCard(context, p, 'Parent')),
                                ...spouses.map((p) => _buildRelativeCard(context, p, 'Spouse')),
                                ...children.map((p) => _buildRelativeCard(context, p, 'Child')),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // =============================================================
              // 3. FIXED BOTTOM NAVY CTA BAR (Screen 3: "Book Consultation" style)
              // =============================================================
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary, // #101D38 Deep Navy
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Focus in Living Tree',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Branch: Kensington / Vansora',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textOnDarkSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Circular white arrow action button
                      InkWell(
                        onTap: () => context.push('/tree?personId=${person.id}'),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 4 Feature Pills in Screen 3
  // ---------------------------------------------------------------------------
  Widget _buildSpecPill({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4E3FA), width: 1.0),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Relative Card with portrait photograph placeholder
  // ---------------------------------------------------------------------------
  Widget _buildRelativeCard(BuildContext context, Person relative, String relationship) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => context.push('/people/${relative.id}'),
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.asset(
              relative.effectivePortraitAsset,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          relative.displayName,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '$relationship • ${relative.lifeDateSpan}',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
