import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../model/eye_shapes.dart';
import 'body_path.dart';

/// Paints one frame of the character: a single flat-filled body path and two
/// eye polygons. No mouth (spec 8.4) -- expression lives entirely in the eyes.
class EmojiPainter extends CustomPainter {
  const EmojiPainter({
    required this.bodyOffsets,
    required this.squash,
    required this.eyes,
    required this.colour,
  });

  final List<double> bodyOffsets;
  final double squash;
  final EyePair eyes;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final Path body = buildBodyPath(
      size: size,
      radialOffsets: bodyOffsets,
      squash: squash,
    );
    canvas.drawPath(body, Paint()..color = colour);

    final double s = size.shortestSide;
    final double eyeRadius = s * 0.13;
    final double eyeDx = s * 0.17;
    final double eyeCy = size.height / 2 - s * 0.05;
    final double cx = size.width / 2;

    final Paint eyePaint = Paint()..color = const Color(0xF2FFFFFF);
    _drawEye(canvas, eyes.left, Offset(cx - eyeDx, eyeCy), eyeRadius, eyePaint);
    _drawEye(canvas, eyes.right, Offset(cx + eyeDx, eyeCy), eyeRadius, eyePaint);
  }

  void _drawEye(
    Canvas canvas,
    List<Offset> polygon,
    Offset centre,
    double radius,
    Paint paint,
  ) {
    if (polygon.isEmpty) return;
    final Path path = Path();
    for (int i = 0; i < polygon.length; i++) {
      final double x = centre.dx + polygon[i].dx * radius;
      final double y = centre.dy + polygon[i].dy * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EmojiPainter old) {
    return old.colour != colour ||
        old.squash != squash ||
        !listEquals(old.bodyOffsets, bodyOffsets) ||
        !listEquals(old.eyes.left, eyes.left) ||
        !listEquals(old.eyes.right, eyes.right);
  }
}
