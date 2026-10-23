import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/relationship.dart';
import '../../../data/providers/repository_providers.dart';

class RelationshipManagerScreen extends ConsumerStatefulWidget {
  final String? initialSourcePersonId;

  const RelationshipManagerScreen({super.key, this.initialSourcePersonId});

  @override
  ConsumerState<RelationshipManagerScreen> createState() => _RelationshipManagerScreenState();
}

class _RelationshipManagerScreenState extends ConsumerState<RelationshipManagerScreen> {
  String? _personAId;
  String? _personBId;
  RelationshipType _relType = RelationshipType.parent;
  LineageType _lineage = LineageType.biological;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _personAId = widget.initialSourcePersonId;
  }

  Future<void> _createRelationship() async {
    if (_personAId == null || _personBId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both family members.')),
      );
      return;
    }

    if (_personAId == _personBId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A person cannot have a relationship with themselves.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final membership = ref.read(currentMembershipProvider).valueOrNull;
      final repo = ref.read(relationshipRepositoryProvider);

      final rel = Relationship(
        id: 'rel_${DateTime.now().millisecondsSinceEpoch}',
        familyId: 'fam_kensington_01',
        personId: _personAId!,
        relatedPersonId: _personBId!,
        type: _relType,
        lineage: _lineage,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.addRelationship(rel, membership);
      ref.invalidate(familyRelationshipsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relationship successfully connected.'),
            backgroundColor: HeritageColors.forestGreen,
          ),
        );
        setState(() {
          _personBId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Relationship Error', style: HeritageTypography.displaySmall),
            content: Text('$e', style: HeritageTypography.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);
    final relsAsync = ref.watch(familyRelationshipsProvider);
    final membership = ref.watch(currentMembershipProvider).valueOrNull;
    final repo = ref.watch(relationshipRepositoryProvider);

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Relationship Builder', style: HeritageTypography.displaySmall),
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HeritageColors.forestGreen)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (allPersons) {
          final personMap = {for (final p in allPersons) p.id: p};

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Builder Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: HeritageGradients.premiumCard,
                  borderRadius: HeritageCurves.cardLarge,
                  boxShadow: HeritageShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Connect Family Members', style: HeritageTypography.titleMedium),
                    const SizedBox(height: 14),

                    // Person A
                    DropdownButtonFormField<String>(
                      value: _personAId,
                      decoration: const InputDecoration(labelText: 'Primary Person (A)'),
                      items: allPersons.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.displayName} (${p.lifeDateSpan})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _personAId = val);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Relationship Type
                    DropdownButtonFormField<RelationshipType>(
                      value: _relType,
                      decoration: const InputDecoration(labelText: 'is'),
                      items: RelationshipType.values.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(
                            t == RelationshipType.parent
                                ? 'Parent of'
                                : t == RelationshipType.child
                                    ? 'Child of'
                                    : t == RelationshipType.spouse
                                        ? 'Spouse / Partner of'
                                        : 'Sibling of',
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _relType = val);
                      },
                    ),

                    if (_relType == RelationshipType.parent || _relType == RelationshipType.child) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<LineageType>(
                        value: _lineage,
                        decoration: const InputDecoration(labelText: 'Lineage / Classification'),
                        items: LineageType.values.map((l) {
                          return DropdownMenuItem(
                            value: l,
                            child: Text(l.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _lineage = val);
                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Person B
                    DropdownButtonFormField<String>(
                      value: _personBId,
                      decoration: const InputDecoration(labelText: 'Related Person (B)'),
                      items: allPersons.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.displayName} (${p.lifeDateSpan})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _personBId = val);
                      },
                    ),

                    const SizedBox(height: 18),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _createRelationship,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Relationship Edge'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text('Existing Graph Connections', style: HeritageTypography.displaySmall),
              const SizedBox(height: 12),

              relsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: HeritageColors.forestGreen)),
                error: (err, _) => Text('Error: $err'),
                data: (rels) {
                  return Column(
                    children: rels.map((r) {
                      final pA = personMap[r.personId];
                      final pB = personMap[r.relatedPersonId];
                      if (pA == null || pB == null) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          gradient: HeritageGradients.premiumCard,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: HeritageShadows.card,
                        ),
                        child: ListTile(
                          title: Text(
                            '${pA.displayName} → ${r.type.label} → ${pB.displayName}',
                            style: HeritageTypography.titleSmall.copyWith(fontSize: 13.5),
                          ),
                          subtitle: Text('ID: ${r.id}', style: HeritageTypography.bodySmall.copyWith(fontSize: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: HeritageColors.statusError),
                            onPressed: () async {
                              await repo.deleteRelationship(r.id, membership);
                              ref.invalidate(familyRelationshipsProvider);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
