import 'dart:math' as math;
import 'dart:ui';

import '../model/pose.dart';

/// Below this size the per-point deformation is dropped -- only overall scale
/// and colour remain, since the wobble is invisible and the frames matter on
/// low-end hardware (spec 8.4).
const double kDeformationCutoff = 40.0;

/// The base silhouette: a rounded *seed*, taller than wide, with a flattened
/// base. Half-extents as a fraction of the shortest side.
const double _baseHalfWidth = 0.46;
const double _baseHalfHeight = 0.44;

/// The base is clamped to a horizontal line at this fraction of the base
/// half-height below centre, which is what flattens it against the rounder
/// crown.
const double _baseFlatten = 0.90;

/// Builds the closed body path for one frame.
///
/// [radialOffsets] is one bulge per control point (length [kBodyPointCount]),
/// in units of the base radius. [squash] scales width by `squash` and height
/// by `1 / squash`, so area is preserved.
Path buildBodyPath({
  required Size size,
  required List<double> radialOffsets,
  required double squash,
}) {
  final double s = size.shortestSide;
  final double cx = size.width / 2;
  final double cy = size.height / 2;
  final double rx = _baseHalfWidth * s;
  final double ry = _baseHalfHeight * s;
  final bool deform = s >= kDeformationCutoff;
  final double flattenAt = cy + (ry / squash) * _baseFlatten;

  final List<Offset> points = <Offset>[];
  for (int i = 0; i < kBodyPointCount; i++) {
    // Angle 0 at the crown, running clockwise.
    final double a = -math.pi / 2 + (2 * math.pi * i / kBodyPointCount);
    final double bulge =
        deform ? (1.0 + radialOffsets[i % radialOffsets.length]) : 1.0;
    // A seed/teardrop taper: the crown is pinched narrow, the base is full
    // width, which is what stops the silhouette reading as a plain circle.
    final double taper = 0.52 + 0.48 * ((math.sin(a) + 1) / 2);
    double px = cx + math.cos(a) * rx * taper * bulge * squash;
    double py = cy + math.sin(a) * ry * bulge / squash;
    if (py > flattenAt) py = flattenAt;
    points.add(Offset(
      px.clamp(0.0, size.width),
      py.clamp(0.0, size.height),
    ));
  }

  // Catmull-Rom through the points, emitted as cubic beziers. Every control
  // point is clamped into the box, so the curve -- which lives inside the
  // convex hull of its control points -- can never leave the bounds.
  Offset clampIn(Offset o) => Offset(
        o.dx.clamp(0.0, size.width),
        o.dy.clamp(0.0, size.height),
      );

  final Path path = Path()..moveTo(points[0].dx, points[0].dy);
  for (int i = 0; i < kBodyPointCount; i++) {
    final Offset p0 = points[(i - 1 + kBodyPointCount) % kBodyPointCount];
    final Offset p1 = points[i];
    final Offset p2 = points[(i + 1) % kBodyPointCount];
    final Offset p3 = points[(i + 2) % kBodyPointCount];
    final Offset c1 = clampIn(p1 + (p2 - p0) * (1 / 6));
    final Offset c2 = clampIn(p2 - (p3 - p1) * (1 / 6));
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  path.close();
  return path;
}
