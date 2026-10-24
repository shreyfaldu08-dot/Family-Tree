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
    // Normal relationship line (#DCE7DA Soft Border)
    final normalBranchPaint = Paint()
      ..color = AppColors.treeNormalLine
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Emphasized relationship line (#9BC5A0 Fresh Green)
    final emphasizedBranchPaint = Paint()
      ..color = AppColors.treeEmphasizedLine
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Selected direct line (#76A982 Primary Green)
    final selectedBranchPaint = Paint()
      ..color = AppColors.treeSelectedPath
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final normalDotPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.fill;

    // Draw organic curved branches connecting parents to children
    for (final node in nodes.values) {
      final fromPos = node.position;
      final isFromFocused = node.id == focusPersonId;

      for (final child in node.children) {
        if (!nodes.containsKey(child.id)) continue;
        final toPos = child.position;
        final isToFocused = child.id == focusPersonId;
        final isConnectedToFocus = isFromFocused || isToFocused;

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

        final paint = isConnectedToFocus
            ? (node.isSelected || child.isSelected ? selectedBranchPaint : emphasizedBranchPaint)
            : normalBranchPaint;

        canvas.drawPath(path, paint);

        // Draw small junction bud at midpoint
        final midX = (fromPos.dx + toPos.dx) / 2;
        canvas.drawCircle(Offset(midX, midY), isConnectedToFocus ? 3.0 : 2.5, isConnectedToFocus ? dotPaint : normalDotPaint);
      }

      // Draw spouse connection if spouse is in the tree
      if (node.spouse != null && nodes.containsKey(node.spouse!.id)) {
        final spPos = node.spouse!.position;
        if (fromPos.dx < spPos.dx) {
          final isSpouseFocused = node.id == focusPersonId || node.spouse!.id == focusPersonId;
          final spousePath = Path();
          spousePath.moveTo(fromPos.dx + 48, fromPos.dy);
          spousePath.lineTo(spPos.dx - 48, spPos.dy);
          canvas.drawPath(spousePath, isSpouseFocused ? selectedBranchPaint : emphasizedBranchPaint);
          canvas.drawCircle(Offset((fromPos.dx + spPos.dx) / 2, fromPos.dy), 3.0, isSpouseFocused ? dotPaint : normalDotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LivingHeritageTreePainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.focusPersonId != focusPersonId;
  }
}
