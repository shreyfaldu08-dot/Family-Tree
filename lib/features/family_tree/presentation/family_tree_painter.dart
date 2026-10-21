import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../domain/tree_node.dart';

class LivingHeritageTreePainter extends CustomPainter {
  final Map<String, HeritageTreeNode> nodes;
  final String focusPersonId;

  LivingHeritageTreePainter({
    required this.nodes,
    required this.focusPersonId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final branchPaint = Paint()
      ..color = HeritageColors.borderSubtle
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final brassAccentPaint = Paint()
      ..color = HeritageColors.blueHighlight
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = HeritageColors.blueHighlight
      ..style = PaintingStyle.fill;

    // Draw organic curved branches connecting parents to children
    for (final node in nodes.values) {
      final fromPos = node.position;

      for (final child in node.children) {
        if (!nodes.containsKey(child.id)) continue;
        final toPos = child.position;

        // Draw organic S-curve Bézier line from parent to child
        final path = Path();
        path.moveTo(fromPos.dx, fromPos.dy + 38); // Bottom of parent node

        final midY = (fromPos.dy + toPos.dy) / 2;
        path.cubicTo(
          fromPos.dx,
          midY,
          toPos.dx,
          midY,
          toPos.dx,
          toPos.dy - 38, // Top of child node
        );

        canvas.drawPath(path, branchPaint);

        // Draw small brass junction bud at midpoint
        final midX = (fromPos.dx + toPos.dx) / 2;
        canvas.drawCircle(Offset(midX, midY), 3.0, dotPaint);
      }

      // Draw spouse connection if spouse is in the tree
      if (node.spouse != null && nodes.containsKey(node.spouse!.id)) {
        final spPos = node.spouse!.position;
        if (fromPos.dx < spPos.dx) {
          final spousePath = Path();
          spousePath.moveTo(fromPos.dx + 48, fromPos.dy);
          spousePath.lineTo(spPos.dx - 48, spPos.dy);
          canvas.drawPath(spousePath, brassAccentPaint);
          canvas.drawCircle(Offset((fromPos.dx + spPos.dx) / 2, fromPos.dy), 3.5, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LivingHeritageTreePainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.focusPersonId != focusPersonId;
  }
}
