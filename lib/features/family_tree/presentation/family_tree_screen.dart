import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/models/relationship.dart';
import '../../../data/providers/repository_providers.dart';
import '../domain/tree_node.dart';
import '../domain/tree_layout_engine.dart';
import 'family_tree_painter.dart';
import 'widgets/person_node_widget.dart';
import 'widgets/generation_navigator.dart';
import 'widgets/tree_preview_sheet.dart';
import 'widgets/generation_album_view.dart';
import 'widgets/tree_list_view.dart';
import 'widgets/fan_chart_view.dart';

enum TreeViewStyle {
  canvas('🌳 Tree'),
  album('🗂️ Cards'),
  fan('🪭 Fan'),
  list('📋 List');

  final String label;
  const TreeViewStyle(this.label);
}

class FamilyTreeScreen extends ConsumerStatefulWidget {
  final String? initialPersonId;

  const FamilyTreeScreen({super.key, this.initialPersonId});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
  late final TransformationController _transformController;
  TreeViewStyle _viewStyle = TreeViewStyle.canvas;
  TreeMode _currentMode = TreeMode.overview;
  String? _focusedPersonId;
  final Set<String> _collapsedNodeIds = {};
  int _selectedGenFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _focusedPersonId = widget.initialPersonId;

    // Center view on canvas center (2500, 2500)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnNode(const Offset(2500, 2500));
    });
  }

  @override
  void didUpdateWidget(FamilyTreeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPersonId != null &&
        widget.initialPersonId != oldWidget.initialPersonId) {
      setState(() {
        _focusedPersonId = widget.initialPersonId;
      });
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _centerOnNode(Offset target) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final matrix = Matrix4.identity()
      ..translate(
        size.width / 2 - target.dx,
        size.height / 2 - target.dy,
      )
      ..scale(0.95);
    _transformController.value = matrix;
  }

  Set<String> _getBranchPersonIds(String rootId, List<Person> persons, List<Relationship> relationships) {
    final result = <String>{rootId};
    
    // Add ancestors (parents, grandparents)
    final parentQueue = <String>[rootId];
    while (parentQueue.isNotEmpty) {
      final cur = parentQueue.removeAt(0);
      for (final rel in relationships) {
        if (rel.type == RelationshipType.parent && rel.relatedPersonId == cur) {
          if (!result.contains(rel.personId)) {
            result.add(rel.personId);
            parentQueue.add(rel.personId);
          }
        } else if (rel.type == RelationshipType.child && rel.personId == cur) {
          if (!result.contains(rel.relatedPersonId)) {
            result.add(rel.relatedPersonId);
            parentQueue.add(rel.relatedPersonId);
          }
        }
      }
    }

    // Add descendants (children, grandchildren)
    final descQueue = <String>[rootId];
    while (descQueue.isNotEmpty) {
      final cur = descQueue.removeAt(0);
      for (final rel in relationships) {
        if (rel.type == RelationshipType.parent && rel.personId == cur) {
          if (!result.contains(rel.relatedPersonId)) {
            result.add(rel.relatedPersonId);
            descQueue.add(rel.relatedPersonId);
          }
        } else if (rel.type == RelationshipType.child && rel.relatedPersonId == cur) {
          if (!result.contains(rel.personId)) {
            result.add(rel.personId);
            descQueue.add(rel.personId);
          }
        }
      }
    }

    // Add spouses of anyone in the branch so far
    for (final id in Set<String>.from(result)) {
      for (final rel in relationships) {
        if (rel.type == RelationshipType.spouse) {
          if (rel.personId == id && !result.contains(rel.relatedPersonId)) result.add(rel.relatedPersonId);
          if (rel.relatedPersonId == id && !result.contains(rel.personId)) result.add(rel.personId);
        }
      }
    }

    return result;
  }

  void _openPersonPreview(Person person) {
    final membership = ref.read(currentMembershipProvider).valueOrNull;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TreePreviewSheet(
        person: person,
        membership: membership,
        onViewFullProfile: () {
          Navigator.pop(ctx);
          context.push('/member/${person.id}');
        },
        onFocusTree: () {
          Navigator.pop(ctx);
          setState(() {
            _focusedPersonId = person.id;
            _viewStyle = TreeViewStyle.canvas;
          });
        },
        onAddRelative: membership?.canWriteFamilyData == true
            ? () {
                Navigator.pop(ctx);
                context.push('/admin/person/new?initialSourcePersonId=${person.id}');
              }
            : null,
      ),
    );
  }

  void _showTreeLegend() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.paleSage,
                  borderRadius: HeritageCurves.pill,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Family Lineage Guide & Symbols',
              style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Visual indicators designed so any generation can easily identify family heritage.',
              style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            _buildLegendItem(
              icon: Icons.circle,
              iconColor: AppColors.primary,
              title: 'Forest Green Accent',
              subtitle: 'Direct male bloodline and ancestral leaders.',
            ),
            const SizedBox(height: 10),
            _buildLegendItem(
              icon: Icons.circle,
              iconColor: AppColors.softMint,
              title: 'Soft Mint Accent',
              subtitle: 'Direct female bloodline and matriarchs.',
            ),
            const SizedBox(height: 10),
            _buildLegendItem(
              icon: Icons.star_rounded,
              iconColor: AppColors.primary,
              title: 'Star Icon (⭐)',
              subtitle: 'Root ancestor / founding generation of this lineage.',
            ),
            const SizedBox(height: 10),
            _buildLegendItem(
              icon: Icons.eco_rounded,
              iconColor: AppColors.primary,
              title: 'Living Sprout (🌱)',
              subtitle: 'Living family member.',
            ),
            const SizedBox(height: 10),
            _buildLegendItem(
              icon: Icons.park_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Memorial Tree (🕊️)',
              subtitle: 'Honored ancestor who has passed on.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: HeritageTypography.titleSmall.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
              Text(subtitle, style: HeritageTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final relsAsync = ref.watch(familyRelationshipsProvider);
    final isAdmin = ref.watch(isCurrentAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Body Content based on View Switcher
            personsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(child: Text('Error loading tree: $err')),
              data: (persons) {
                return relsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (relationships) {
                    if (persons.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.park_outlined, size: 54, color: AppColors.paleSage),
                            const SizedBox(height: 12),
                            Text('No Family Records Yet', style: HeritageTypography.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                              'Add your family records to view the living lineage.',
                              style: HeritageTypography.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    // Unique Tree ID & Branch Mode Scope Handling
                    final branchMode = ref.watch(branchViewModeProvider);
                    final userBranchId = ref.watch(userBranchPersonIdProvider);

                    List<Person> activePersons = persons;
                    List<Relationship> activeRelationships = relationships;

                    if (branchMode == BranchViewMode.myBranch && userBranchId != null) {
                      final branchIds = _getBranchPersonIds(userBranchId, persons, relationships);
                      activePersons = persons.where((p) => branchIds.contains(p.id)).toList();
                      activeRelationships = relationships.where((r) => branchIds.contains(r.personId) && branchIds.contains(r.relatedPersonId)).toList();
                    }

                    // Render selected view style
                    if (_viewStyle == TreeViewStyle.album) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 86),
                        child: GenerationAlbumView(
                          persons: activePersons,
                          relationships: activeRelationships,
                          isAdmin: isAdmin,
                          onSelectPerson: _openPersonPreview,
                          onAddRelative: (relType, sourceId) {
                            context.push('/admin/person/new?initialRelationType=$relType&initialSourcePersonId=$sourceId');
                          },
                        ),
                      );
                    } else if (_viewStyle == TreeViewStyle.fan) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 86),
                        child: FanChartView(
                          persons: activePersons,
                          onSelectPerson: _openPersonPreview,
                        ),
                      );
                    } else if (_viewStyle == TreeViewStyle.list) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 86),
                        child: TreeListView(
                          persons: activePersons,
                          onSelectPerson: _openPersonPreview,
                        ),
                      );
                    }

                    // Default: Interactive Canvas Tree
                    final focusId = _focusedPersonId ?? (activePersons.isNotEmpty ? activePersons.first.id : persons.first.id);

                    final layoutResult = TreeLayoutEngine.computeLayout(
                      persons: activePersons,
                      relationships: activeRelationships,
                      focusPersonId: focusId,
                      mode: _currentMode,
                      collapsedNodeIds: _collapsedNodeIds,
                    );

                    return Stack(
                      children: [
                        // Panning and Zooming Canvas
                        InteractiveViewer(
                          transformationController: _transformController,
                          boundaryMargin: const EdgeInsets.all(2500),
                          minScale: 0.2,
                          maxScale: 2.5,
                          constrained: false,
                          child: SizedBox(
                            width: layoutResult.canvasSize.width,
                            height: layoutResult.canvasSize.height,
                            child: Stack(
                              children: [
                                // CustomPainter for curved branch lines
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: LivingHeritageTreePainter(
                                      nodes: layoutResult.nodes,
                                      focusPersonId: focusId,
                                    ),
                                  ),
                                ),

                                // Interactive Person Node Widgets
                                ...layoutResult.nodes.values.map((node) {
                                  return Positioned(
                                    left: node.position.dx - 87,
                                    top: node.position.dy - 50,
                                    child: PersonNodeWidget(
                                      node: node,
                                      isAdmin: isAdmin,
                                      onAddRelative: (relationType) {
                                        context.push('/admin/person/new?initialRelationType=$relationType&initialSourcePersonId=${node.person.id}');
                                      },
                                      onTap: () {
                                        _openPersonPreview(node.person);
                                      },
                                      onToggleExpand: () {
                                        setState(() {
                                          if (_collapsedNodeIds.contains(node.id)) {
                                            _collapsedNodeIds.remove(node.id);
                                          } else {
                                            _collapsedNodeIds.add(node.id);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Generation Navigator Floating Pill
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 24,
                          child: Center(
                            child: GenerationNavigator(
                              minGeneration: layoutResult.minGeneration,
                              maxGeneration: layoutResult.maxGeneration,
                              currentRelativeGeneration: _selectedGenFilter,
                              onSelectGeneration: (gen) {
                                setState(() {
                                  _selectedGenFilter = gen;
                                });
                                // Center on first node of that generation
                                final genNodes = layoutResult.nodes.values
                                    .where((n) => n.relativeGeneration == gen);
                                if (genNodes.isNotEmpty) {
                                  _centerOnNode(genNodes.first.position);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // Top Header: View Switcher (Tree / Generations / Directory) & Controls
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  _buildBranchScopeBar(
                    ref.watch(uniqueFamilyTreeIdProvider),
                    ref.watch(branchViewModeProvider),
                    ref.watch(userBranchPersonIdProvider),
                    personsAsync.valueOrNull ?? [],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // View Switcher Pill (🌳 Tree / 🗂️ Generations / 📋 Directory)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: HeritageCurves.pill,
                            boxShadow: HeritageShadows.card,
                          ),
                          child: Row(
                            children: TreeViewStyle.values.map((style) {
                              final isSelected = style == _viewStyle;
                              return Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _viewStyle = style),
                                  borderRadius: HeritageCurves.pill,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      borderRadius: HeritageCurves.pill,
                                      boxShadow: isSelected ? HeritageShadows.activePill : null,
                                    ),
                                    child: Text(
                                      style.label,
                                      textAlign: TextAlign.center,
                                      style: HeritageTypography.labelSmall.copyWith(
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Legend & Help Guide Button
                      InkWell(
                        onTap: _showTreeLegend,
                        borderRadius: HeritageCurves.pill,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: HeritageShadows.card,
                          ),
                          child: const Icon(
                            Icons.help_outline_rounded,
                            size: 19,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      if (_viewStyle == TreeViewStyle.canvas) ...[
                        const SizedBox(width: 6),
                        // Reset View Center Button
                        InkWell(
                          onTap: () => _centerOnNode(const Offset(2500, 2500)),
                          borderRadius: HeritageCurves.pill,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              boxShadow: HeritageShadows.card,
                            ),
                            child: const Icon(
                              Icons.center_focus_strong_rounded,
                              size: 19,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Mode Selector within Canvas mode (Full / Ancestors / Descendants)
                  if (_viewStyle == TreeViewStyle.canvas) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.92),
                        borderRadius: HeritageCurves.pill,
                        boxShadow: HeritageShadows.card,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: TreeMode.values.map((mode) {
                          final isSelected = mode == _currentMode;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => setState(() => _currentMode = mode),
                              borderRadius: HeritageCurves.pill,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.paleSage : Colors.transparent,
                                  borderRadius: HeritageCurves.pill,
                                ),
                                child: Text(
                                  mode.label,
                                  style: HeritageTypography.labelSmall.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchScopeBar(String treeId, BranchViewMode branchMode, String? userBranchPersonId, List<Person> persons) {
    final activeMember = persons.firstWhere(
      (p) => p.id == userBranchPersonId,
      orElse: () => persons.isNotEmpty ? persons.first : Person(
        id: 'fallback',
        familyId: 'fam',
        firstName: 'Branch',
        lastName: 'Member',
        alternateNames: const [],
        gender: Gender.male,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Unique Tree ID Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.pill,
              boxShadow: HeritageShadows.card,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.vpn_key_rounded, size: 13, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(
                  'Tree ID: $treeId',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Branch Scope Switcher (My Branch vs Full Clan Tree)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.pill,
              boxShadow: HeritageShadows.card,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => ref.read(branchViewModeProvider.notifier).setMode(BranchViewMode.myBranch),
                  borderRadius: HeritageCurves.pill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: branchMode == BranchViewMode.myBranch ? AppColors.primary : Colors.transparent,
                      borderRadius: HeritageCurves.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          size: 13,
                          color: branchMode == BranchViewMode.myBranch ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'My Branch (${activeMember.displayName.split(" ").first})',
                          style: TextStyle(
                            color: branchMode == BranchViewMode.myBranch ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => ref.read(branchViewModeProvider.notifier).setMode(BranchViewMode.fullTree),
                  borderRadius: HeritageCurves.pill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: branchMode == BranchViewMode.fullTree ? AppColors.primary : Colors.transparent,
                      borderRadius: HeritageCurves.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.diversity_3_rounded,
                          size: 13,
                          color: branchMode == BranchViewMode.fullTree ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Full Clan Tree',
                          style: TextStyle(
                            color: branchMode == BranchViewMode.fullTree ? Colors.white : AppColors.textPrimary,
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
          ),
          const SizedBox(width: 8),

          // Sibling Branch Head Switcher (for testing/demoing different brother views)
          InkWell(
            onTap: () => _showBranchSwitcherDialog(persons),
            borderRadius: HeritageCurves.pill,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.lightSage.withOpacity(0.5),
                borderRadius: HeritageCurves.pill,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Switch Brother',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBranchSwitcherDialog(List<Person> persons) {
    final brothers = persons.where((p) => p.generation == 2 || p.generation == 3).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch Active Branch Head'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Simulate logging in as different brothers to see how each branch admin views their generation vs the full tree.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            ...brothers.map((p) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.lightSage,
                child: Icon(Icons.person, color: AppColors.primary, size: 18),
              ),
              title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Gen ${p.generation} Branch Head'),
              onTap: () {
                ref.read(userBranchPersonIdProvider.notifier).setPersonId(p.id);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
}

