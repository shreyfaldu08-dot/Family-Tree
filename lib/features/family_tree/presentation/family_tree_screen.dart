import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';
import '../domain/tree_node.dart';
import '../domain/tree_layout_engine.dart';
import 'family_tree_painter.dart';
import 'widgets/person_node_widget.dart';
import 'widgets/generation_navigator.dart';
import 'widgets/tree_preview_sheet.dart';

class FamilyTreeScreen extends ConsumerStatefulWidget {
  final String? initialPersonId;

  const FamilyTreeScreen({super.key, this.initialPersonId});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen> {
  late final TransformationController _transformController;
  TreeMode _currentMode = TreeMode.overview;
  String? _focusedPersonId;
  final Set<String> _collapsedNodeIds = {};
  int _selectedGenFilter = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
          context.push('/people/${person.id}');
        },
        onFocusTree: () {
          Navigator.pop(ctx);
          setState(() {
            _focusedPersonId = person.id;
          });
        },
        onAddRelative: membership?.canWriteFamilyData == true
            ? () {
                Navigator.pop(ctx);
                context.push('/admin/relationships/new?sourcePersonId=${person.id}');
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final relsAsync = ref.watch(familyRelationshipsProvider);

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      body: SafeArea(
        child: Stack(
          children: [
            // Interactive Graph Canvas
            personsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: HeritageColors.forestGreen),
              ),
              error: (err, _) => Center(child: Text('Error loading tree: $err')),
              data: (persons) {
                return relsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: HeritageColors.forestGreen),
                  ),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (relationships) {
                    if (persons.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.park_outlined, size: 54, color: HeritageColors.sage),
                            const SizedBox(height: 12),
                            Text('No Family Records Yet', style: HeritageTypography.displaySmall),
                            const SizedBox(height: 6),
                            Text(
                              'Add your family records to view the interactive living lineage.',
                              style: HeritageTypography.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    // Default focus person
                    final focusId = _focusedPersonId ?? persons.first.id;

                    final layoutResult = TreeLayoutEngine.computeLayout(
                      persons: persons,
                      relationships: relationships,
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
                                    left: node.position.dx - 75,
                                    top: node.position.dy - 40,
                                    child: PersonNodeWidget(
                                      node: node,
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

            // Top Header Bar & Mode Selector
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Back / Brand button
                      InkWell(
                        onTap: () => context.go('/'),
                        borderRadius: HeritageCurves.pill,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: HeritageShadows.card,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Mode Switcher Pill (Ancestry / Descendants / Full)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: HeritageCurves.pill,
                            boxShadow: HeritageShadows.card,
                          ),
                          child: Row(
                            children: TreeMode.values.map((mode) {
                              final isSelected = mode == _currentMode;
                              final displayLabel = mode == TreeMode.overview
                                  ? 'Full'
                                  : mode.label.split(' ').first;
                              return Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _currentMode = mode;
                                    });
                                  },
                                  borderRadius: HeritageCurves.pill,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.paleSage : Colors.transparent,
                                      borderRadius: HeritageCurves.pill,
                                      boxShadow: isSelected ? HeritageShadows.activePill : null,
                                    ),
                                    child: Text(
                                      displayLabel,
                                      textAlign: TextAlign.center,
                                      style: HeritageTypography.labelSmall.copyWith(
                                        fontSize: 12.5,
                                        color: isSelected
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Reset Zoom / Center Button
                      InkWell(
                        onTap: () => _centerOnNode(const Offset(2500, 2500)),
                        borderRadius: HeritageCurves.pill,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: HeritageShadows.card,
                          ),
                          child: const Icon(
                            Icons.center_focus_strong_rounded,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search toggle
                  const SizedBox(height: 10),
                  if (_isSearching)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        gradient: HeritageGradients.premiumCard,
                        borderRadius: HeritageCurves.pill,
                        boxShadow: HeritageShadows.pill,
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search person in tree...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          icon: const Icon(Icons.search, size: 18, color: HeritageColors.charcoalMuted),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _isSearching = false;
                                _searchController.clear();
                              });
                            },
                          ),
                        ),
                        onSubmitted: (query) {
                          if (query.trim().isEmpty) return;
                          final persons = personsAsync.valueOrNull ?? const [];
                          final match = persons.where((p) => p.matchesQuery(query)).firstOrNull;
                          if (match != null) {
                            setState(() {
                              _focusedPersonId = match.id;
                              _isSearching = false;
                            });
                            _centerOnNode(const Offset(2500, 2500));
                          }
                        },
                      ),
                    )
                  else
                    Align(
                      alignment: Alignment.centerRight,
                      child: ActionChip(
                        avatar: const Icon(Icons.search, size: 16, color: HeritageColors.charcoal),
                        label: Text('Find in Tree', style: HeritageTypography.labelSmall),
                        backgroundColor: HeritageColors.surfaceCard.withOpacity(0.95),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                        elevation: 1,
                        shadowColor: HeritageColors.subtleShadow,
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
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
}
