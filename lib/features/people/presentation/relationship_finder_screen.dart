import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

class RelationshipFinderScreen extends ConsumerStatefulWidget {
  const RelationshipFinderScreen({super.key});

  @override
  ConsumerState<RelationshipFinderScreen> createState() => _RelationshipFinderScreenState();
}

class _RelationshipFinderScreenState extends ConsumerState<RelationshipFinderScreen> {
  Person? _personA;
  Person? _personB;
  String? _calculatedRelation;

  void _calculateRelation() {
    if (_personA == null || _personB == null) return;
    if (_personA!.id == _personB!.id) {
      setState(() => _calculatedRelation = 'Same person selected');
      return;
    }

    final genA = _personA!.generationHint ?? 1;
    final genB = _personB!.generationHint ?? 1;
    final diff = genA - genB;

    if (diff == 0) {
      if (_personA!.gender == Gender.male) {
        _calculatedRelation = 'Brother / Cousin / Peer generation relative';
      } else if (_personA!.gender == Gender.female) {
        _calculatedRelation = 'Sister / Cousin / Peer generation relative';
      } else {
        _calculatedRelation = 'Cousin (Same Generation)';
      }
    } else if (diff == 1) {
      _calculatedRelation = _personA!.gender == Gender.male ? 'Father / Paternal Uncle' : 'Mother / Maternal Aunt';
    } else if (diff == -1) {
      _calculatedRelation = _personA!.gender == Gender.male ? 'Son / Nephew' : 'Daughter / Niece';
    } else if (diff == 2) {
      _calculatedRelation = _personA!.gender == Gender.male ? 'Grandfather' : 'Grandmother';
    } else if (diff == -2) {
      _calculatedRelation = _personA!.gender == Gender.male ? 'Grandson' : 'Granddaughter';
    } else if (diff > 2) {
      _calculatedRelation = 'Ancestor ($diff Generations Above)';
    } else {
      _calculatedRelation = 'Descendant (${diff.abs()} Generations Below)';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(familyPersonsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Relationship Finder', style: HeritageTypography.displaySmall),
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (persons) {
          if (persons.length < 2) {
            return Center(
              child: Text(
                'At least two family members are required to calculate relationships.',
                style: HeritageTypography.bodyMedium,
              ),
            );
          }

          _personA ??= persons.first;
          _personB ??= persons.length > 1 ? persons[1] : persons.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.cardLarge,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Kinship Connection',
                        style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select any two relatives to determine their ancestral and generational relation.',
                        style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),

                      const SizedBox(height: 20),

                      // Person A Dropdown
                      Text('First Person:', style: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<Person>(
                        value: _personA,
                        isExpanded: true,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded)),
                        items: persons.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(
                              '${p.displayName} (Gen ${p.generationHint ?? "?"})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _personA = val;
                            _calculatedRelation = null;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.lightSage,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Person B Dropdown
                      Text('Second Person:', style: HeritageTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<Person>(
                        value: _personB,
                        isExpanded: true,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded)),
                        items: persons.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(
                              '${p.displayName} (Gen ${p.generationHint ?? "?"})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _personB = val;
                            _calculatedRelation = null;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: _calculateRelation,
                        icon: const Icon(Icons.hub_rounded, size: 18),
                        label: const Text('Calculate Kinship Relation'),
                      ),
                    ],
                  ),
                ),

                if (_calculatedRelation != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.signatureGradient,
                      borderRadius: HeritageCurves.cardLarge,
                      boxShadow: HeritageShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KINSHIP RESULT',
                          style: HeritageTypography.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _calculatedRelation!,
                          style: HeritageTypography.displaySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_personA?.displayName} relative to ${_personB?.displayName}',
                          style: HeritageTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
