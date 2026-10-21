import 'dart:ui';
import '../../../data/models/person.dart';

enum TreeMode {
  ancestors,
  descendants,
  overview;

  String get label {
    switch (this) {
      case TreeMode.ancestors:
        return 'Ancestry Line';
      case TreeMode.descendants:
        return 'Descendants Line';
      case TreeMode.overview:
        return 'Full Overview';
    }
  }
}

class HeritageTreeNode {
  final Person person;
  final int relativeGeneration; // 0 = focused person, -1 = parents, +1 = children
  Offset position; // Center coordinate on the virtual canvas
  bool isExpanded;
  bool isSelected;

  // Graph structural links
  final List<HeritageTreeNode> parents;
  final List<HeritageTreeNode> children;
  HeritageTreeNode? spouse;

  HeritageTreeNode({
    required this.person,
    required this.relativeGeneration,
    this.position = Offset.zero,
    this.isExpanded = true,
    this.isSelected = false,
    List<HeritageTreeNode>? parents,
    List<HeritageTreeNode>? children,
    this.spouse,
  })  : parents = parents ?? [],
        children = children ?? [];

  String get id => person.id;
}
