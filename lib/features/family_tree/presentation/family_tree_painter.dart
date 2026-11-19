import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
    // -------------------------------------------------------------------------
    // 1. Dotted Canvas Grid Matrix (Miro / Figma / reference tablet aesthetic)
    // -------------------------------------------------------------------------
    const double gridSpacing = 28.0;
    final gridPoints = <Offset>[];
    for (double x = 0; x <= size.width; x += gridSpacing) {
      for (double y = 0; y <= size.height; y += gridSpacing) {
        gridPoints.add(Offset(x, y));
      }
    }
    canvas.drawPoints(
      ui.PointMode.points,
      gridPoints,
      Paint()
        ..color = const Color(0xFF64748B).withOpacity(0.22)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // -------------------------------------------------------------------------
    // 2. Line & Dot Paints
    // -------------------------------------------------------------------------
    // Normal relationship line (#94A3B8 clean slate gray)
    final normalBranchPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Emphasized relationship line (#22C55E Fresh Green)
    final emphasizedBranchPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final junctionDotPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    final emphasizedDotPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;

    const double cardHalfWidth = 86.0; // 172 / 2
    const double cardHalfHeight = 78.0; // 156 / 2

    // Set to avoid duplicate spouse drawing
    final processedSpousePairs = <String>{};

    // -------------------------------------------------------------------------
    // 3. Draw Spouse Horizontal Connections
    // -------------------------------------------------------------------------
    for (final node in nodes.values) {
      if (node.spouse != null && nodes.containsKey(node.spouse!.id)) {
        final spNode = node.spouse!;
        final pairKey = node.id.compareTo(spNode.id) < 0
            ? '${node.id}_${spNode.id}'
            : '${spNode.id}_${node.id}';

        if (!processedSpousePairs.contains(pairKey)) {
          processedSpousePairs.add(pairKey);

          final leftNode = node.position.dx <= spNode.position.dx ? node : spNode;
          final rightNode = node.position.dx <= spNode.position.dx ? spNode : node;

          final startX = leftNode.position.dx + cardHalfWidth;
          final endX = rightNode.position.dx - cardHalfWidth;
          final y = leftNode.position.dy;

          if (startX < endX) {
            final isSpouseFocused = leftNode.id == focusPersonId || rightNode.id == focusPersonId;
            final paint = isSpouseFocused ? emphasizedBranchPaint : normalBranchPaint;

            canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);

            // Junction dot at midpoint between spouses
            final midX = (leftNode.position.dx + rightNode.position.dx) / 2;
            canvas.drawCircle(
              Offset(midX, y),
              3.5,
              isSpouseFocused ? emphasizedDotPaint : junctionDotPaint,
            );
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // 4. Draw Orthogonal Parent -> Child Branches
    // -------------------------------------------------------------------------
    for (final node in nodes.values) {
      if (node.children.isEmpty) continue;

      // Avoid drawing duplicate child branch stems if both spouses are in the tree
      if (node.spouse != null && nodes.containsKey(node.spouse!.id)) {
        if (node.id.compareTo(node.spouse!.id) > 0) {
          continue;
        }
      }

      final fromPos = node.position;
      final isFromFocused = node.id == focusPersonId;

      // Group children that exist in nodes
      final validChildren = node.children.where((c) => nodes.containsKey(c.id)).toList();
      if (validChildren.isEmpty) continue;

      // Determine parent junction anchor:
      // If parent has a spouse also displayed, anchor from the midpoint between spouses
      Offset parentAnchor;
      if (node.spouse != null && nodes.containsKey(node.spouse!.id)) {
        final spPos = node.spouse!.position;
        final midX = (fromPos.dx + spPos.dx) / 2;
        parentAnchor = Offset(midX, fromPos.dy);
      } else {
        parentAnchor = Offset(fromPos.dx, fromPos.dy + cardHalfHeight);
      }

      // Generation crossbar Y position (safely centered in the open air gap between parent bottom and child top)
      final parentBottomY = fromPos.dy + cardHalfHeight;
      final avgChildY = validChildren.map((c) => c.position.dy).reduce((a, b) => a + b) / validChildren.length;
      final childTopY = avgChildY - cardHalfHeight;
      final crossbarY = (parentBottomY + childTopY) / 2;

      final isParentFocused = isFromFocused || (node.spouse != null && node.spouse!.id == focusPersonId);

      // Vertical stem dropping from parent anchor to crossbar
      final stemPaint = isParentFocused ? emphasizedBranchPaint : normalBranchPaint;
      canvas.drawLine(parentAnchor, Offset(parentAnchor.dx, crossbarY), stemPaint);

      // Junction dot at parent anchor & crossbar junction
      canvas.drawCircle(
        parentAnchor,
        3.0,
        isParentFocused ? emphasizedDotPaint : junctionDotPaint,
      );
      canvas.drawCircle(
        Offset(parentAnchor.dx, crossbarY),
        3.5,
        isParentFocused ? emphasizedDotPaint : junctionDotPaint,
      );

      // Draw horizontal crossbar spanning to each child
      for (final child in validChildren) {
        final toPos = child.position;
        final isChildFocused = child.id == focusPersonId;
        final isPathFocused = isParentFocused || isChildFocused;
        final branchPaint = isPathFocused ? emphasizedBranchPaint : normalBranchPaint;

        // Horizontal bar from parent stem X to child X
        canvas.drawLine(
          Offset(parentAnchor.dx, crossbarY),
          Offset(toPos.dx, crossbarY),
          branchPaint,
        );

        // Vertical drop from crossbar down to top of child card
        canvas.drawLine(
          Offset(toPos.dx, crossbarY),
          Offset(toPos.dx, toPos.dy - cardHalfHeight),
          branchPaint,
        );

        // Junction dot at child card entry
        canvas.drawCircle(
          Offset(toPos.dx, toPos.dy - cardHalfHeight),
          3.0,
          isPathFocused ? emphasizedDotPaint : junctionDotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LivingHeritageTreePainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.focusPersonId != focusPersonId;
  }
}
