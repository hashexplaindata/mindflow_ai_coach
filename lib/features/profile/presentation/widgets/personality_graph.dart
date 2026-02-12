import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../features/identity/domain/models/personality_vector.dart';

/// Vector Graph Widget (Required for Shipyard Demo)
/// Visualizes the 4-dimensional PersonalityVector as a radar/spider chart
class PersonalityGraph extends StatelessWidget {
  final PersonalityVector vector;
  final bool showLabels;
  final double size;

  const PersonalityGraph({
    super.key,
    required this.vector,
    this.showLabels = true,
    this.size = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RadarChartPainter(
              vector: vector,
              primaryColor: colorScheme.primary,
              surfaceColor: colorScheme.surface,
              textColor: colorScheme.onSurface,
            ),
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem('D', vector.discipline, Colors.blue, textTheme),
        _legendItem('N', vector.novelty, Colors.green, textTheme),
        _legendItem('V', vector.volatility, Colors.orange, textTheme),
        _legendItem('S', vector.structure, Colors.purple, textTheme),
      ],
    );
  }

  Widget _legendItem(
      String label, double value, Color color, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          (value * 100).toStringAsFixed(0),
          style: textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final PersonalityVector vector;
  final Color primaryColor;
  final Color surfaceColor;
  final Color textColor;

  _RadarChartPainter({
    required this.vector,
    required this.primaryColor,
    required this.surfaceColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.8;

    // Draw background grid (5 concentric circles)
    _drawGrid(canvas, center, radius);

    // Draw axis lines
    _drawAxes(canvas, center, radius);

    // Draw data polygon
    _drawDataPolygon(canvas, center, radius);

    // Draw labels
    _drawLabels(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = textColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * i / 5, gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final axisPaint = Paint()
      ..color = textColor.withOpacity(0.2)
      ..strokeWidth = 1;

    final dimensions = 4;
    for (int i = 0; i < dimensions; i++) {
      final angle = (i * 2 * pi / dimensions) - pi / 2;
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, end, axisPaint);
    }
  }

  void _drawDataPolygon(Canvas canvas, Offset center, double radius) {
    final values = [
      vector.discipline,
      vector.novelty,
      vector.volatility,
      vector.structure,
    ];

    final path = Path();
    final dimensions = values.length;

    for (int i = 0; i < dimensions; i++) {
      final angle = (i * 2 * pi / dimensions) - pi / 2;
      final distance = radius * values[i];
      final point = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Fill
    final fillPaint = Paint()
      ..color = primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, strokePaint);

    // Draw points
    for (int i = 0; i < dimensions; i++) {
      final angle = (i * 2 * pi / dimensions) - pi / 2;
      final distance = radius * values[i];
      final point = Offset(
        center.dx + distance * cos(angle),
        center.dy + distance * sin(angle),
      );

      canvas.drawCircle(point, 4, Paint()..color = primaryColor);
      canvas.drawCircle(point, 2, Paint()..color = surfaceColor);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final labels = ['D', 'N', 'V', 'S'];
    final dimensions = labels.length;
    final labelOffset = radius + 20;

    for (int i = 0; i < dimensions; i++) {
      final angle = (i * 2 * pi / dimensions) - pi / 2;
      final position = Offset(
        center.dx + labelOffset * cos(angle),
        center.dy + labelOffset * sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.vector != vector ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.textColor != textColor;
  }
}
