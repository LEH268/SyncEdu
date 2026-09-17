import 'package:flutter/material.dart';

import 'layout.dart';

/// Paints the diagram's edges as gently curved connectors: a wide blurred
/// glow pass first, then a thin solid pass on top. Deterministic — the curve
/// for a pair of points is a fixed function of those points, no animation.
class EdgePainter extends CustomPainter {
  const EdgePainter({
    required this.edges,
    required this.glowColor,
    required this.lineColor,
  });

  final List<DiagramEdge> edges;
  final Color glowColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint glow = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final Paint line = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final DiagramEdge edge in edges) {
      final Path path = _curve(edge.from.center, edge.to.center);
      canvas.drawPath(path, glow);
      canvas.drawPath(path, line);
    }
  }

  Path _curve(Offset a, Offset b) {
    final Offset mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    // Bow the control point perpendicular to the segment by a fixed fraction
    // of its length, so parallel edges do not draw on top of each other.
    final Offset delta = b - a;
    final Offset normal = Offset(-delta.dy, delta.dx);
    final double len = normal.distance == 0 ? 1 : normal.distance;
    final Offset control = mid + normal * (0.12 * delta.distance / len);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);
  }

  @override
  bool shouldRepaint(EdgePainter oldDelegate) =>
      oldDelegate.edges != edges ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.lineColor != lineColor;
}
