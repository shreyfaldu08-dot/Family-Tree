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
  static const double generationPitchY = 220.0;
  static const double nodeWidth = 160.0;
  static const double nodeGapX = 36.0;

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
    // child -> parents
    final childToParents = <String, List<String>>{};
    // parent -> children
    final parentToChildren = <String, List<String>>{};
    // spouse pairs
    final spouseMap = <String, String>{};

    for (final rel in relationships) {
      if (rel.type == RelationshipType.parent) {
        // personId is parent, relatedPersonId is child
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

    // Build Ancestors Subtree recursively (up to 10 generations up: -1 to -10)
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

    // Build Descendants Subtree recursively (up to 10 generations down: +1 to +10)
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

    if (mode == TreeMode.ancestors || mode == TreeMode.overview) {
      buildAncestors(rootNode, 0);
    }
    if (mode == TreeMode.descendants || mode == TreeMode.overview) {
      buildDescendants(rootNode, 0);
    }

    // Assign positions using layered generation spacing
    final generations = <int, List<HeritageTreeNode>>{};
    for (final node in nodeMap.values) {
      generations.putIfAbsent(node.relativeGeneration, () => []).add(node);
    }

    int minGen = 0;
    int maxGen = 0;
    for (final g in generations.keys) {
      if (g < minGen) minGen = g;
      if (g > maxGen) maxGen = g;
    }

    const canvasCenterX = 2500.0;
    const canvasCenterY = 2500.0;

    // Position root node
    rootNode.position = const Offset(canvasCenterX, canvasCenterY);

    // Lay out each generation with symmetrical horizontal spacing
    for (final entry in generations.entries) {
      final gen = entry.key;
      final nodesInGen = entry.value;

      final y = canvasCenterY + (gen * generationPitchY);
      final count = nodesInGen.length;
      final totalWidth = count * nodeWidth + (count - 1) * nodeGapX;
      final startX = canvasCenterX - (totalWidth / 2) + (nodeWidth / 2);

      for (var i = 0; i < count; i++) {
        final x = startX + i * (nodeWidth + nodeGapX);
        nodesInGen[i].position = Offset(x, y);
      }
    }

    return TreeLayoutResult(
      nodes: nodeMap,
      rootNode: rootNode,
      canvasSize: const Size(5000, 5000),
      rootCanvasPosition: const Offset(canvasCenterX, canvasCenterY),
      minGeneration: minGen,
      maxGeneration: maxGen,
    );
  }
}
