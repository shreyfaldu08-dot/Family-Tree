import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/models/relationship.dart';
import '../../../data/providers/repository_providers.dart';

class RelationshipFinderScreen extends ConsumerStatefulWidget {
  const RelationshipFinderScreen({super.key});

  @override
  ConsumerState<RelationshipFinderScreen> createState() => _RelationshipFinderScreenState();
}

class _RelationshipFinderScreenState extends ConsumerState<RelationshipFinderScreen> {
  Person? _personA;
  Person? _personB;
  _KinshipResult? _result;

  void _calculateKinship(List<Person> allPersons, List<Relationship> allRelationships) {
    if (_personA == null || _personB == null) return;
    if (_personA!.id == _personB!.id) {
      setState(() {
        _result = _KinshipResult(
          title: 'Self (Same Individual)',
          relationshipCategory: 'Identical Identity',
          explanation: '${_personA!.displayName} is the same person selected twice.',
          pathHops: [],
        );
      });
      return;
    }

    final pathfinder = _KinshipPathfinder(
      persons: allPersons,
      relationships: allRelationships,
    );

    final res = pathfinder.findKinship(_personA!, _personB!);
    setState(() {
      _result = res;
    });
  }

  void _swapPersons(List<Person> allPersons, List<Relationship> allRelationships) {
    setState(() {
      final temp = _personA;
      _personA = _personB;
      _personB = temp;
    });
    _calculateKinship(allPersons, allRelationships);
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final relationshipsAsync = ref.watch(familyRelationshipsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Kinship Graph Pathfinder', style: HeritageTypography.displaySmall),
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error loading relatives: $err')),
        data: (persons) {
          final relationships = relationshipsAsync.valueOrNull ?? [];

          if (persons.length < 2) {
            return Center(
              child: Text(
                'At least two family members are required to calculate relationships.',
                style: HeritageTypography.bodyMedium,
              ),
            );
          }

          // Default initial selection: Sara Wilson and Thomas Wilson or Oliver
          _personA ??= persons.where((p) => p.id == 'p_gen9_sara').firstOrNull ?? persons.first;
          _personB ??= persons.where((p) => p.id == 'p_gen9_oliver').firstOrNull ??
              (persons.length > 1 ? persons[1] : persons.first);

          if (_result == null && _personA != null && _personB != null) {
            _calculateKinship(persons, relationships);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selector Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.cardLarge,
                    boxShadow: HeritageShadows.card,
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightSage,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BFS Kinship & Ancestry Engine',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Trace Lowest Common Ancestor (LCA) and step-by-step bloodlines',
                                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Relative A Dropdown
                      Text('First Relative (Point A):', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      _buildPersonDropdown(
                        persons: persons,
                        selected: _personA,
                        onChanged: (val) {
                          setState(() => _personA = val);
                          _calculateKinship(persons, relationships);
                        },
                      ),

                      const SizedBox(height: 14),

                      // Swap Button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => _swapPersons(persons, relationships),
                          icon: const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.primary),
                          label: Text(
                            'Swap Perspective',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Relative B Dropdown
                      Text('Second Relative (Point B):', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      _buildPersonDropdown(
                        persons: persons,
                        selected: _personB,
                        onChanged: (val) {
                          setState(() => _personB = val);
                          _calculateKinship(persons, relationships);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Kinship Results Display
                if (_result != null) ...[
                  _buildKinshipResultCard(_result!),
                  const SizedBox(height: 20),
                  _buildStepByStepPathCard(_result!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonDropdown({
    required List<Person> persons,
    required Person? selected,
    required ValueChanged<Person?> onChanged,
  }) {
    return DropdownButtonFormField<Person>(
      value: selected,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: persons.map((p) {
        return DropdownMenuItem(
          value: p,
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.paleSage),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.asset(
                    p.effectivePortraitAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(p.initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${p.displayName} (Gen ${p.generationHint ?? "?"})',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildKinshipResultCard(_KinshipResult result) {
    Color badgeColor = const Color(0xFF1D4ED8);
    Color badgeBg = const Color(0xFFEFF6FF);

    if (result.relationshipCategory.contains('Direct')) {
      badgeColor = const Color(0xFF15803D);
      badgeBg = const Color(0xFFF0FDF4);
    } else if (result.relationshipCategory.contains('Marriage')) {
      badgeColor = const Color(0xFFB45309);
      badgeBg = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: HeritageCurves.cardLarge,
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.relationshipCategory.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: badgeColor, letterSpacing: 0.4),
                ),
              ),
              if (result.generationDifference != null)
                Text(
                  result.generationDifference == 0
                      ? 'Same Generation'
                      : '${result.generationDifference! > 0 ? "+" : ""}${result.generationDifference} Generations',
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            result.title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            result.explanation,
            style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: AppColors.textPrimary.withOpacity(0.85)),
          ),

          if (result.commonAncestor != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.paleSage,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Image.asset(
                      result.commonAncestor!.effectivePortraitAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(result.commonAncestor!.initials, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        'Lowest Common Ancestor (LCA)',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${result.commonAncestor!.displayName} (Gen ${result.commonAncestor!.generationHint ?? 1})',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightSage,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Shared Apex',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepByStepPathCard(_KinshipResult result) {
    if (result.pathHops.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: HeritageCurves.cardLarge,
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Direct Visual Lineage Path (${result.pathHops.length} hops)',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.pathHops.length,
            itemBuilder: (ctx, i) {
              final hop = result.pathHops[i];
              final isLast = i == result.pathHops.length - 1;

              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.paleSage),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Image.asset(
                            hop.from.effectivePortraitAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(hop.from.initials, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                              hop.from.displayName,
                              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Generation ${hop.from.generationHint ?? "?"}',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Connection Hop
                  Container(
                    margin: const EdgeInsets.only(left: 18),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: AppColors.border, width: 2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Row(
                        children: [
                          Icon(hop.icon, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.lightSage,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hop.label,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isLast)
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.paleSage),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Image.asset(
                              hop.to.effectivePortraitAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(hop.to.initials, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                                hop.to.displayName,
                                style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              Text(
                                'Generation ${hop.to.generationHint ?? "?"} (Target)',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BFS Graph Pathfinder & Kinship Engine
// =============================================================================

class _KinshipHop {
  final Person from;
  final Person to;
  final String label;
  final IconData icon;

  const _KinshipHop({
    required this.from,
    required this.to,
    required this.label,
    required this.icon,
  });
}

class _KinshipResult {
  final String title;
  final String relationshipCategory;
  final Person? commonAncestor;
  final int? generationDifference;
  final List<_KinshipHop> pathHops;
  final String explanation;

  const _KinshipResult({
    required this.title,
    required this.relationshipCategory,
    this.commonAncestor,
    this.generationDifference,
    required this.pathHops,
    required this.explanation,
  });
}

class _KinshipPathfinder {
  final List<Person> persons;
  final List<Relationship> relationships;
  final Map<String, Person> _personMap = {};
  final Map<String, List<String>> _parentsOf = {};
  final Map<String, List<String>> _childrenOf = {};
  final Map<String, List<String>> _spousesOf = {};
  final Map<String, List<_GraphEdge>> _adj = {};

  _KinshipPathfinder({
    required this.persons,
    required this.relationships,
  }) {
    for (final p in persons) {
      _personMap[p.id] = p;
      _parentsOf[p.id] = [];
      _childrenOf[p.id] = [];
      _spousesOf[p.id] = [];
      _adj[p.id] = [];
    }

    for (final rel in relationships) {
      final p1 = rel.personId;
      final p2 = rel.relatedPersonId;

      if (!_personMap.containsKey(p1) || !_personMap.containsKey(p2)) continue;

      if (rel.type == RelationshipType.parent) {
        _parentsOf[p2]!.add(p1);
        _childrenOf[p1]!.add(p2);
        _addEdge(p1, p2, _personMap[p1]!.gender == Gender.male ? 'Father of' : 'Mother of', Icons.south_rounded);
        _addEdge(p2, p1, _personMap[p2]!.gender == Gender.male ? 'Son of' : 'Daughter of', Icons.north_rounded);
      } else if (rel.type == RelationshipType.child) {
        _parentsOf[p1]!.add(p2);
        _childrenOf[p2]!.add(p1);
        _addEdge(p2, p1, _personMap[p2]!.gender == Gender.male ? 'Father of' : 'Mother of', Icons.south_rounded);
        _addEdge(p1, p2, _personMap[p1]!.gender == Gender.male ? 'Son of' : 'Daughter of', Icons.north_rounded);
      } else if (rel.type == RelationshipType.spouse) {
        _spousesOf[p1]!.add(p2);
        _spousesOf[p2]!.add(p1);
        _addEdge(p1, p2, _personMap[p1]!.gender == Gender.male ? 'Husband of' : 'Wife of', Icons.favorite_rounded);
        _addEdge(p2, p1, _personMap[p2]!.gender == Gender.male ? 'Husband of' : 'Wife of', Icons.favorite_rounded);
      } else if (rel.type == RelationshipType.sibling) {
        _addEdge(p1, p2, _personMap[p1]!.gender == Gender.male ? 'Brother of' : 'Sister of', Icons.people_outline_rounded);
        _addEdge(p2, p1, _personMap[p2]!.gender == Gender.male ? 'Brother of' : 'Sister of', Icons.people_outline_rounded);
      }
    }
  }

  void _addEdge(String from, String to, String label, IconData icon) {
    _adj[from]!.add(_GraphEdge(to: to, label: label, icon: icon));
  }

  _KinshipResult findKinship(Person a, Person b) {
    final genA = a.generationHint ?? 1;
    final genB = b.generationHint ?? 1;
    final genDiff = genA - genB;

    // 1. Direct Spouse Check
    if (_spousesOf[a.id]?.contains(b.id) ?? false) {
      final title = a.gender == Gender.male ? 'Husband' : (a.gender == Gender.female ? 'Wife' : 'Spouse');
      final hops = _bfsPath(a.id, b.id);
      return _KinshipResult(
        title: '$title of ${b.displayName}',
        relationshipCategory: 'Marital Bond (Spouses)',
        generationDifference: 0,
        explanation: '${a.displayName} and ${b.displayName} are verified canonical spouses in the living family tree.',
        pathHops: hops,
      );
    }

    // 2. Lowest Common Ancestor (LCA) search
    final ancestorsA = _getAncestorsWithDepth(a.id);
    final ancestorsB = _getAncestorsWithDepth(b.id);

    final common = ancestorsA.keys.where((id) => ancestorsB.containsKey(id)).toList();

    Person? lca;
    int minTotalDist = 999999;

    for (final cId in common) {
      final total = ancestorsA[cId]! + ancestorsB[cId]!;
      if (total < minTotalDist) {
        minTotalDist = total;
        lca = _personMap[cId];
      }
    }

    final pathHops = _bfsPath(a.id, b.id);

    if (lca != null) {
      final dA = ancestorsA[lca.id]!;
      final dB = ancestorsB[lca.id]!;

      final kinship = _deriveKinshipFromLCA(a, b, lca, dA, dB);
      return _KinshipResult(
        title: kinship.title,
        relationshipCategory: kinship.category,
        commonAncestor: lca,
        generationDifference: genDiff,
        explanation: '${a.displayName} and ${b.displayName} share lowest common ancestor ${lca.displayName} (Generation ${lca.generationHint}). ${kinship.explanation}',
        pathHops: pathHops,
      );
    }

    // 3. Fallback to BFS path or generational distance
    if (pathHops.isNotEmpty) {
      return _KinshipResult(
        title: 'Extended Family Connection',
        relationshipCategory: 'Extended Clan Lineage',
        generationDifference: genDiff,
        explanation: 'Connected through ${pathHops.length} familial links in the Vansora tree.',
        pathHops: pathHops,
      );
    }

    return _KinshipResult(
      title: genDiff == 0 ? 'Generational Peer' : (genDiff > 0 ? '$genDiff Generations Senior' : '${genDiff.abs()} Generations Junior'),
      relationshipCategory: 'Lineage Clan',
      generationDifference: genDiff,
      explanation: '${a.displayName} (Gen $genA) and ${b.displayName} (Gen $genB) belong to the same heritage tree.',
      pathHops: [],
    );
  }

  Map<String, int> _getAncestorsWithDepth(String personId) {
    final map = <String, int>{personId: 0};
    final queue = Queue<_DepthNode>()..add(_DepthNode(personId, 0));
    final visited = <String>{personId};

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final parents = _parentsOf[current.id] ?? [];

      for (final p in parents) {
        if (!visited.contains(p)) {
          visited.add(p);
          final nextDepth = current.depth + 1;
          map[p] = nextDepth;
          queue.add(_DepthNode(p, nextDepth));
        }
      }
    }
    return map;
  }

  _KinshipTitle _deriveKinshipFromLCA(Person a, Person b, Person lca, int dA, int dB) {
    final aMale = a.gender == Gender.male;
    final aFemale = a.gender == Gender.female;

    // Self
    if (dA == 0 && dB == 0) {
      return const _KinshipTitle('Self', 'Identical', 'Same individual.');
    }

    // Direct Ancestry / Descendancy
    if (dA == 0) {
      if (dB == 1) return _KinshipTitle(aMale ? 'Father' : (aFemale ? 'Mother' : 'Parent'), 'Direct Lineage', '${a.displayName} is the biological/legal parent of ${b.displayName}.');
      if (dB == 2) return _KinshipTitle(aMale ? 'Grandfather' : (aFemale ? 'Grandmother' : 'Grandparent'), 'Direct Lineage', '${a.displayName} is the grandparent of ${b.displayName}.');
      if (dB == 3) return _KinshipTitle(aMale ? 'Great-Grandfather' : (aFemale ? 'Great-Grandmother' : 'Great-Grandparent'), 'Direct Lineage', '${a.displayName} is the great-grandparent of ${b.displayName}.');
      return _KinshipTitle(aMale ? 'Direct Ancestor (${dB}x)' : 'Direct Ancestress (${dB}x)', 'Direct Lineage', 'Separated by $dB direct ancestral steps.');
    }

    if (dB == 0) {
      if (dA == 1) return _KinshipTitle(aMale ? 'Son' : (aFemale ? 'Daughter' : 'Child'), 'Direct Lineage', '${a.displayName} is the child of ${b.displayName}.');
      if (dA == 2) return _KinshipTitle(aMale ? 'Grandson' : (aFemale ? 'Granddaughter' : 'Grandchild'), 'Direct Lineage', '${a.displayName} is the grandchild of ${b.displayName}.');
      if (dA == 3) return _KinshipTitle(aMale ? 'Great-Grandson' : (aFemale ? 'Great-Granddaughter' : 'Great-Grandchild'), 'Direct Lineage', '${a.displayName} is the great-grandchild of ${b.displayName}.');
      return _KinshipTitle('Direct Descendant (${dA}x)', 'Direct Lineage', 'Descended by $dA generations.');
    }

    // Siblings
    if (dA == 1 && dB == 1) {
      final title = aMale ? 'Brother' : (aFemale ? 'Sister' : 'Sibling');
      return _KinshipTitle(title, 'Direct Siblings', '${a.displayName} and ${b.displayName} are siblings sharing parent ${lca.displayName}.');
    }

    // Uncle / Aunt vs Niece / Nephew
    if (dA == 1 && dB == 2) {
      final title = aMale ? 'Uncle' : (aFemale ? 'Aunt' : 'Uncle/Aunt');
      return _KinshipTitle(title, 'Collateral Kinship', '${a.displayName} is the uncle/aunt of ${b.displayName}.');
    }

    if (dA == 2 && dB == 1) {
      final title = aMale ? 'Nephew' : (aFemale ? 'Niece' : 'Niece/Nephew');
      return _KinshipTitle(title, 'Collateral Kinship', '${a.displayName} is the niece/nephew of ${b.displayName}.');
    }

    // Great-Uncle / Great-Aunt vs Great-Niece / Great-Nephew
    if (dA == 1 && dB == 3) {
      final title = aMale ? 'Great-Uncle' : (aFemale ? 'Great-Aunt' : 'Great-Uncle/Aunt');
      return _KinshipTitle(title, 'Collateral Kinship', '${a.displayName} is the great-uncle/aunt of ${b.displayName}.');
    }

    if (dA == 3 && dB == 1) {
      final title = aMale ? 'Great-Nephew' : (aFemale ? 'Great-Niece' : 'Great-Niece/Nephew');
      return _KinshipTitle(title, 'Collateral Kinship', '${a.displayName} is the great-niece/nephew of ${b.displayName}.');
    }

    // Cousins
    if (dA >= 2 && dB >= 2) {
      final degree = (dA < dB ? dA : dB) - 1;
      final removed = (dA - dB).abs();

      final ordinals = ['First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth', 'Seventh', 'Eighth'];
      final degreeName = degree <= ordinals.length ? ordinals[degree - 1] : '${degree}th';

      String title;
      if (removed == 0) {
        title = '$degreeName Cousin';
      } else {
        title = '$degreeName Cousin ${removed}x Removed';
      }

      return _KinshipTitle(
        title,
        'Cousin Lineage',
        'Cousins sharing common ancestor ${lca.displayName} at degree $degree with $removed generational shift(s).',
      );
    }

    return const _KinshipTitle('Family Relative', 'Extended Lineage', 'Connected through canonical lineage records.');
  }

  List<_KinshipHop> _bfsPath(String startId, String endId) {
    if (startId == endId) return [];

    final queue = Queue<List<_GraphEdgeHop>>()..add([]);
    final visited = <String>{startId};
    final nodeQueue = Queue<String>()..add(startId);

    while (nodeQueue.isNotEmpty) {
      final curr = nodeQueue.removeFirst();
      final path = queue.removeFirst();

      if (curr == endId) {
        return path.map((e) => _KinshipHop(
          from: _personMap[e.from]!,
          to: _personMap[e.to]!,
          label: e.label,
          icon: e.icon,
        )).toList();
      }

      final edges = _adj[curr] ?? [];
      for (final edge in edges) {
        if (!visited.contains(edge.to)) {
          visited.add(edge.to);
          nodeQueue.add(edge.to);
          final newPath = List<_GraphEdgeHop>.from(path)..add(_GraphEdgeHop(from: curr, to: edge.to, label: edge.label, icon: edge.icon));
          queue.add(newPath);
        }
      }
    }
    return [];
  }
}

class _GraphEdge {
  final String to;
  final String label;
  final IconData icon;

  const _GraphEdge({required this.to, required this.label, required this.icon});
}

class _GraphEdgeHop {
  final String from;
  final String to;
  final String label;
  final IconData icon;

  const _GraphEdgeHop({required this.from, required this.to, required this.label, required this.icon});
}

class _DepthNode {
  final String id;
  final int depth;

  const _DepthNode(this.id, this.depth);
}

class _KinshipTitle {
  final String title;
  final String category;
  final String explanation;

  const _KinshipTitle(this.title, this.category, this.explanation);
}
