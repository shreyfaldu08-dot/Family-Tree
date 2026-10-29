import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../data/models/person.dart';

class FanChartView extends StatefulWidget {
  final List<Person> persons;
  final void Function(Person person) onSelectPerson;

  const FanChartView({
    super.key,
    required this.persons,
    required this.onSelectPerson,
  });

  @override
  State<FanChartView> createState() => _FanChartViewState();
}

class _FanChartViewState extends State<FanChartView> {
  int _maxGenerations = 5;

  @override
  Widget build(BuildContext context) {
    if (widget.persons.isEmpty) {
      return Center(
        child: Text('No family members to display.', style: HeritageTypography.bodyMedium),
      );
    }

    // Group by generation
    final Map<int, List<Person>> genMap = {};
    for (final p in widget.persons) {
      final gen = p.generationHint ?? 1;
      genMap.putIfAbsent(gen, () => []).add(p);
    }

    return Column(
      children: [
        // Controls / Info Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Radial Fan Chart', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                  Text('Concentric multi-generation view', style: HeritageTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: HeritageCurves.pill,
                  boxShadow: HeritageShadows.card,
                ),
                child: Row(
                  children: [
                    Text('Rings: ', style: HeritageTypography.bodySmall.copyWith(fontSize: 11)),
                    DropdownButton<int>(
                      value: _maxGenerations,
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      items: const [
                        DropdownMenuItem(value: 3, child: Text('3 Gens')),
                        DropdownMenuItem(value: 4, child: Text('4 Gens')),
                        DropdownMenuItem(value: 5, child: Text('5 Gens')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _maxGenerations = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Interactive Fan Chart Canvas
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final center = Offset(constraints.maxWidth / 2, constraints.maxHeight * 0.85);
              final maxRadius = math.min(constraints.maxWidth * 0.46, constraints.maxHeight * 0.75);

              return Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _FanChartPainter(
                      persons: widget.persons,
                      genMap: genMap,
                      maxGens: _maxGenerations,
                      center: center,
                      maxRadius: maxRadius,
                    ),
                  ),

                  // Interactive overlay chips for central ancestors
                  Positioned(
                    left: center.dx - 55,
                    top: center.dy - 35,
                    child: InkWell(
                      onTap: () {
                        final root = widget.persons.where((p) => p.generationHint == 1).firstOrNull ?? widget.persons.first;
                        widget.onSelectPerson(root);
                      },
                      borderRadius: HeritageCurves.pill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: HeritageCurves.pill,
                          boxShadow: HeritageShadows.card,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Root Ancestor',
                              style: HeritageTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FanChartPainter extends CustomPainter {
  final List<Person> persons;
  final Map<int, List<Person>> genMap;
  final int maxGens;
  final Offset center;
  final double maxRadius;

  _FanChartPainter({
    required this.persons,
    required this.genMap,
    required this.maxGens,
    required this.center,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ringWidth = maxRadius / maxGens;

    // Draw concentric arcs for each generation from 1 to maxGens
    for (int gen = 1; gen <= maxGens; gen++) {
      final innerRadius = (gen - 1) * ringWidth;
      final outerRadius = gen * ringWidth;
      final members = genMap[gen] ?? [];

      if (members.isEmpty) continue;

      final sweepPerPerson = math.pi / members.length;

      for (int i = 0; i < members.length; i++) {
        final p = members[i];
        final startAngle = math.pi + (i * sweepPerPerson);

        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = (p.gender == Gender.male
                  ? AppColors.primary
                  : p.gender == Gender.female
                      ? AppColors.softMint
                      : AppColors.paleSage)
              .withOpacity(0.25 + (0.12 * (gen % 3)));

        final path = Path()
          ..arcTo(
            Rect.fromCircle(center: center, radius: outerRadius),
            startAngle,
            sweepPerPerson,
            false,
          )
          ..arcTo(
            Rect.fromCircle(center: center, radius: innerRadius),
            startAngle + sweepPerPerson,
            -sweepPerPerson,
            false,
          )
          ..close();

        canvas.drawPath(path, paint);

        // Divider stroke
        final strokePaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.surface
          ..strokeWidth = 1.5;
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FanChartPainter oldDelegate) => true;
}
