import 'package:flutter_test/flutter_test.dart';
import 'package:family_legacy/data/models/person.dart';
import 'package:family_legacy/data/models/relationship.dart';
import 'package:family_legacy/features/family_tree/domain/tree_layout_engine.dart';
import 'package:family_legacy/features/family_tree/domain/tree_node.dart';

void main() {
  group('TreeLayoutEngine 10-Generation Lineage Tests', () {
    final now = DateTime.now();

    // Create 10 generations in a straight parent-child line
    final persons = <Person>[];
    final relationships = <Relationship>[];

    for (var i = 1; i <= 10; i++) {
      persons.add(Person(
        id: 'p_gen_$i',
        familyId: 'fam_test',
        firstName: 'Person',
        lastName: 'Gen$i',
        generationHint: i,
        birthDate: DateTime(1700 + (i * 30)),
        createdAt: now,
        updatedAt: now,
      ));

      if (i > 1) {
        relationships.add(Relationship(
          id: 'rel_${i - 1}_$i',
          familyId: 'fam_test',
          personId: 'p_gen_${i - 1}',
          relatedPersonId: 'p_gen_$i',
          type: RelationshipType.parent,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }

    test('Computes layout centered on Generation 10 focusing upwards on 9 ancestor generations', () {
      final result = TreeLayoutEngine.computeLayout(
        persons: persons,
        relationships: relationships,
        focusPersonId: 'p_gen_10',
        mode: TreeMode.ancestors,
      );

      expect(result.nodes.containsKey('p_gen_10'), isTrue);
      expect(result.nodes['p_gen_10']!.relativeGeneration, equals(0));

      // Immediate parent (Gen 9) must be relativeGeneration -1
      expect(result.nodes['p_gen_9']!.relativeGeneration, equals(-1));

      // Oldest ancestor (Gen 1) must be relativeGeneration -9
      expect(result.nodes['p_gen_1']!.relativeGeneration, equals(-9));

      // Minimum relative generation should be -9
      expect(result.minGeneration, equals(-9));
      expect(result.maxGeneration, equals(0));
    });

    test('Computes layout centered on Generation 5 in Overview mode (both ancestors and descendants)', () {
      final result = TreeLayoutEngine.computeLayout(
        persons: persons,
        relationships: relationships,
        focusPersonId: 'p_gen_5',
        mode: TreeMode.overview,
      );

      expect(result.nodes['p_gen_5']!.relativeGeneration, equals(0));

      // Gen 1 ancestor should be -4
      expect(result.nodes['p_gen_1']!.relativeGeneration, equals(-4));

      // Gen 10 descendant should be +5
      expect(result.nodes['p_gen_10']!.relativeGeneration, equals(5));

      expect(result.minGeneration, equals(-4));
      expect(result.maxGeneration, equals(5));
    });

    test('Relative depth calculations place earlier generations higher up (negative Y pitch)', () {
      final result = TreeLayoutEngine.computeLayout(
        persons: persons,
        relationships: relationships,
        focusPersonId: 'p_gen_5',
        mode: TreeMode.overview,
      );

      final gen5Y = result.nodes['p_gen_5']!.position.dy;
      final gen1Y = result.nodes['p_gen_1']!.position.dy;
      final gen10Y = result.nodes['p_gen_10']!.position.dy;

      // Ancestors have lower Y coordinates (drawn upwards)
      expect(gen1Y, lessThan(gen5Y));
      // Descendants have higher Y coordinates (drawn downwards)
      expect(gen10Y, greaterThan(gen5Y));
    });
  });
}
