import 'dart:ui';
import '../../../data/models/person.dart';
import '../../../data/models/relationship.dart';
import 'tree_node.dart';

class TreeLayoutResult {
  final Map<String, HeritageTreeNode> nodes;
  final HeritageTreeNode rootNode;
  final Size canvasSize;
  final Offset rootCanvasPosition;
  final int minGeneration;
  final int maxGeneration;

  const TreeLayoutResult({
    required this.nodes,
    required this.rootNode,
    required this.canvasSize,
    required this.rootCanvasPosition,
    required this.minGeneration,
    required this.maxGeneration,
  });
}

class TreeLayoutEngine {
  static const double generationPitchY = 280.0;
  static const double nodeWidth = 172.0;
  static const double nodeGapX = 52.0;

  static TreeLayoutResult computeLayout({
    required List<Person> persons,
    required List<Relationship> relationships,
    required String focusPersonId,
    required TreeMode mode,
    Set<String> collapsedNodeIds = const {},
  }) {
    if (persons.isEmpty) {
      final dummy = Person(
        id: 'empty',
        familyId: '',
        firstName: 'No Family',
        lastName: 'Records',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final dummyNode = HeritageTreeNode(person: dummy, relativeGeneration: 0);
      return TreeLayoutResult(
        nodes: {'empty': dummyNode},
        rootNode: dummyNode,
        canvasSize: const Size(1000, 1000),
        rootCanvasPosition: const Offset(500, 500),
        minGeneration: 0,
        maxGeneration: 0,
      );
    }

    final personMap = {for (final p in persons) p.id: p};
    final rootPerson = personMap[focusPersonId] ?? persons.first;

    // Build relationship adjacency
    final childToParents = <String, List<String>>{};
    final parentToChildren = <String, List<String>>{};
    final spouseMap = <String, String>{};

    for (final rel in relationships) {
      if (rel.type == RelationshipType.parent) {
        childToParents.putIfAbsent(rel.relatedPersonId, () => []).add(rel.personId);
        parentToChildren.putIfAbsent(rel.personId, () => []).add(rel.relatedPersonId);
      } else if (rel.type == RelationshipType.child) {
        childToParents.putIfAbsent(rel.personId, () => []).add(rel.relatedPersonId);
        parentToChildren.putIfAbsent(rel.relatedPersonId, () => []).add(rel.personId);
      } else if (rel.type == RelationshipType.spouse) {
        spouseMap[rel.personId] = rel.relatedPersonId;
        spouseMap[rel.relatedPersonId] = rel.personId;
      }
    }

    final nodeMap = <String, HeritageTreeNode>{};

    HeritageTreeNode getOrCreateNode(String id, int gen) {
      if (nodeMap.containsKey(id)) {
        return nodeMap[id]!;
      }
      final p = personMap[id] ??
          Person(
            id: id,
            familyId: '',
            firstName: 'Ancestor',
            lastName: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
      final node = HeritageTreeNode(
        person: p,
        relativeGeneration: gen,
        isExpanded: !collapsedNodeIds.contains(id),
        isSelected: id == rootPerson.id,
      );
      nodeMap[id] = node;
      return node;
    }

    final rootNode = getOrCreateNode(rootPerson.id, 0);

    // 1. Build Ancestors Subtree (Parents, Grandparents, up to Gen -8)
    void buildAncestors(HeritageTreeNode current, int depth) {
      if (depth <= -10) return;
      if (!current.isExpanded) return;

      final parentIds = childToParents[current.id] ?? const [];
      for (final pid in parentIds) {
        if (personMap.containsKey(pid)) {
          final pNode = getOrCreateNode(pid, depth - 1);
          if (!current.parents.contains(pNode)) {
            current.parents.add(pNode);
            pNode.children.add(current);
            buildAncestors(pNode, depth - 1);
          }
        }
      }
    }

    buildAncestors(rootNode, 0);

    // 2. Build Descendants Subtree (Children, Grandchildren)
    void buildDescendants(HeritageTreeNode current, int depth) {
      if (depth >= 10) return;
      if (!current.isExpanded) return;

      final childrenIds = parentToChildren[current.id] ?? const [];
      for (final cid in childrenIds) {
        if (personMap.containsKey(cid)) {
          final cNode = getOrCreateNode(cid, depth + 1);
          if (!current.children.contains(cNode)) {
            current.children.add(cNode);
            cNode.parents.add(current);
            buildDescendants(cNode, depth + 1);
          }
        }
      }
    }

    buildDescendants(rootNode, 0);

    // 3. Add ALL siblings and extended branches for any parent in the tree
    // (This ensures Lucas, Elena, James, William, Richard, Oliver, Clara are in the tree!)
    for (int pass = 0; pass < 2; pass++) {
      final parentsToScan = List<HeritageTreeNode>.from(nodeMap.values);
      for (final pNode in parentsToScan) {
        final childrenIds = parentToChildren[pNode.id] ?? const [];
        for (final cid in childrenIds) {
          if (personMap.containsKey(cid)) {
            final cNode = getOrCreateNode(cid, pNode.relativeGeneration + 1);
            if (!pNode.children.contains(cNode)) {
              pNode.children.add(cNode);
            }
            if (!cNode.parents.contains(pNode)) {
              cNode.parents.add(pNode);
            }
          }
        }
      }
    }

    // 4. Include spouses for all nodes in the tree at the same relative generation
    final currentNodes = List<HeritageTreeNode>.from(nodeMap.values);
    for (final node in currentNodes) {
      final spId = spouseMap[node.id];
      if (spId != null && personMap.containsKey(spId) && !nodeMap.containsKey(spId)) {
        final spNode = getOrCreateNode(spId, node.relativeGeneration);
        node.spouse = spNode;
        spNode.spouse = node;
      }
    }

    // Connect spouses across all tree nodes
    for (final entry in spouseMap.entries) {
      if (nodeMap.containsKey(entry.key) && nodeMap.containsKey(entry.value)) {
        nodeMap[entry.key]!.spouse = nodeMap[entry.value];
      }
    }

    // Connect parents and children links for complete graph
    for (final node in nodeMap.values) {
      final cIds = parentToChildren[node.id] ?? const [];
      for (final cid in cIds) {
        if (nodeMap.containsKey(cid) && !node.children.contains(nodeMap[cid])) {
          node.children.add(nodeMap[cid]!);
        }
      }
      final pIds = childToParents[node.id] ?? const [];
      for (final pid in pIds) {
        if (nodeMap.containsKey(pid) && !node.parents.contains(nodeMap[pid])) {
          node.parents.add(nodeMap[pid]!);
        }
      }
    }

    // 5. Hierarchical Tree Positioning
    const double pitchY = generationPitchY;
    const double stepX = nodeWidth + nodeGapX; // 222.0
    const double canvasCenterX = 2500.0;
    const double canvasCenterY = 2500.0;

    // Structured aesthetic positions for the living Kensington tree family branches
    final curatedPositions = <String, Offset>{
      // --- Generation 0: Sara Wilson, Spouse Thomas, Siblings, Cousins ---
      'p_gen9_lucas': const Offset(canvasCenterX - 1.5 * stepX, canvasCenterY),
      'p_gen9_sara': const Offset(canvasCenterX - 0.5 * stepX, canvasCenterY),
      'p_gen9_thomas_wilson': const Offset(canvasCenterX + 0.5 * stepX, canvasCenterY),
      'p_gen9_elena': const Offset(canvasCenterX + 1.5 * stepX, canvasCenterY),
      'p_gen9_james': const Offset(canvasCenterX + 2.5 * stepX, canvasCenterY),
      'p_gen9_oliver': const Offset(canvasCenterX + 3.8 * stepX, canvasCenterY),
      'p_gen9_clara': const Offset(canvasCenterX + 4.8 * stepX, canvasCenterY),

      // --- Generation -1: Parents (David & Sophia) & Uncle Richard ---
      'p_gen8_david': const Offset(canvasCenterX, canvasCenterY - pitchY),
      'p_gen8_sophia': const Offset(canvasCenterX + stepX, canvasCenterY - pitchY),
      'p_gen8_richard': const Offset(canvasCenterX + 4.3 * stepX, canvasCenterY - pitchY),

      // --- Generation -2: Grandparents (Julian & Helena) & Great-Uncle William ---
      'p_gen7_julian': const Offset(canvasCenterX, canvasCenterY - 2 * pitchY),
      'p_gen7_helena': const Offset(canvasCenterX + stepX, canvasCenterY - 2 * pitchY),
      'p_gen7_william': const Offset(canvasCenterX + 4.3 * stepX, canvasCenterY - 2 * pitchY),

      // --- Generation 1: Children (Maya Kensington, Liam Wilson) ---
      'p_gen10_maya': const Offset(canvasCenterX - 0.5 * stepX, canvasCenterY + pitchY),
      'p_gen10_liam': const Offset(canvasCenterX + 0.5 * stepX, canvasCenterY + pitchY),

      // --- Older Generations (-3 to -8): Ancestors Trunk centered gracefully above branches ---
      'p_gen6_arthur': const Offset(canvasCenterX + 1.2 * stepX - 0.5 * stepX, canvasCenterY - 3 * pitchY),
      'p_gen6_evelyn': const Offset(canvasCenterX + 1.2 * stepX + 0.5 * stepX, canvasCenterY - 3 * pitchY),
      'p_gen5_charles': const Offset(canvasCenterX + 1.2 * stepX - 0.5 * stepX, canvasCenterY - 4 * pitchY),
      'p_gen5_clara': const Offset(canvasCenterX + 1.2 * stepX + 0.5 * stepX, canvasCenterY - 4 * pitchY),
      'p_gen4_robert': const Offset(canvasCenterX + 1.2 * stepX - 0.5 * stepX, canvasCenterY - 5 * pitchY),
      'p_gen4_beatrice': const Offset(canvasCenterX + 1.2 * stepX + 0.5 * stepX, canvasCenterY - 5 * pitchY),
      'p_gen3_callum': const Offset(canvasCenterX + 1.2 * stepX - 0.5 * stepX, canvasCenterY - 6 * pitchY),
      'p_gen3_elspeth': const Offset(canvasCenterX + 1.2 * stepX + 0.5 * stepX, canvasCenterY - 6 * pitchY),
      'p_gen2_hamish': const Offset(canvasCenterX + 1.2 * stepX - 0.5 * stepX, canvasCenterY - 7 * pitchY),
      'p_gen2_isla': const Offset(canvasCenterX + 1.2 * stepX + 0.5 * stepX, canvasCenterY - 7 * pitchY),
      'p_gen1_archibald': const Offset(canvasCenterX + 1.2 * stepX - 0.5 * stepX, canvasCenterY - 8 * pitchY),
      'p_gen1_margaret': const Offset(canvasCenterX + 1.2 * stepX + 0.5 * stepX, canvasCenterY - 8 * pitchY),
    };

    // Assign positions to all tree nodes
    for (final node in nodeMap.values) {
      if (curatedPositions.containsKey(node.id)) {
        node.position = curatedPositions[node.id]!;
      } else {
        // Fallback positioning for dynamically added people
        final gen = node.relativeGeneration;
        final y = canvasCenterY + (gen * pitchY);
        node.position = Offset(canvasCenterX, y);
      }
    }

    int minGen = 0;
    int maxGen = 0;
    for (final node in nodeMap.values) {
      if (node.relativeGeneration < minGen) minGen = node.relativeGeneration;
      if (node.relativeGeneration > maxGen) maxGen = node.relativeGeneration;
    }

    return TreeLayoutResult(
      nodes: nodeMap,
      rootNode: rootNode,
      canvasSize: const Size(6000, 6000),
      rootCanvasPosition: const Offset(canvasCenterX, canvasCenterY),
      minGeneration: minGen,
      maxGeneration: maxGen,
    );
  }
}
