import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'emoji_state.dart';

/// A left/right pair of eye polygons. Every polygon in the whole table carries
/// the same vertex count so the painter can morph between any two states by
/// straight vertex interpolation.
class EyePair {
  const EyePair({required this.left, required this.right});

  final List<Offset> left;
  final List<Offset> right;
}

/// Every eye is [_vertexCount] points. Eight is enough to read as a shape at
/// 200 dp and cheap enough to morph every frame at 28 dp.
const int _vertexCount = 8;

/// All artwork here is authored from scratch against spec 8.4 -- no coordinate
/// was transcribed or numerically adapted from `grok-icon-study` or
/// `LaoA-GrokBot`. Each shape is a parametric polygon: an ellipse, a wedge or
/// a line, sampled at eight angles and clamped into the unit square.
List<Offset> _poly({
  required double rx,
  required double ry,
  double cx = 0.0,
  double cy = 0.0,
  double rotation = 0.0,
  double topBias = 0.0,
}) {
  final List<Offset> points = <Offset>[];
  for (int i = 0; i < _vertexCount; i++) {
    final double a = rotation + (math.pi / _vertexCount) + (2 * math.pi * i / _vertexCount);
    double x = math.cos(a) * rx;
    double y = math.sin(a) * ry;
    // A positive topBias pinches the upper half (arcs, droops).
    if (y < 0) y *= (1 - topBias);
    points.add(Offset(
      (cx + x).clamp(-1.0, 1.0),
      (cy + y).clamp(-1.0, 1.0),
    ));
  }
  return points;
}

/// A near-flat line, eight points, for `sleeping` and the slit-eyed states.
List<Offset> _line({double halfWidth = 0.9, double thickness = 0.06, double cy = 0.0}) {
  return <Offset>[
    Offset(-halfWidth, cy - thickness),
    Offset(-halfWidth / 2, cy - thickness),
    Offset(halfWidth / 2, cy - thickness),
    Offset(halfWidth, cy - thickness),
    Offset(halfWidth, cy + thickness),
    Offset(halfWidth / 2, cy + thickness),
    Offset(-halfWidth / 2, cy + thickness),
    Offset(-halfWidth, cy + thickness),
  ];
}

/// An eight-point spiky star for `celebrate`.
List<Offset> _star() {
  final List<Offset> points = <Offset>[];
  for (int i = 0; i < _vertexCount; i++) {
    final double a = -math.pi / 2 + (2 * math.pi * i / _vertexCount);
    final double r = i.isEven ? 1.0 : 0.42;
    points.add(Offset(
      (math.cos(a) * r).clamp(-1.0, 1.0),
      (math.sin(a) * r).clamp(-1.0, 1.0),
    ));
  }
  return points;
}

final Map<EmojiState, EyePair> kEyeShapes = <EmojiState, EyePair>{
  // Rounded hexagon-ish oval, outer corners eased down.
  EmojiState.idle: EyePair(
    left: _poly(rx: 0.78, ry: 0.62, topBias: 0.12),
    right: _poly(rx: 0.78, ry: 0.62, topBias: 0.12),
  ),
  // Tall wide ovals -- alert.
  EmojiState.listening: EyePair(
    left: _poly(rx: 0.92, ry: 0.98),
    right: _poly(rx: 0.92, ry: 0.98),
  ),
  // One narrowed, both leaning up-left.
  EmojiState.thinking: EyePair(
    left: _poly(rx: 0.7, ry: 0.5, cx: -0.12, cy: -0.15),
    right: _poly(rx: 0.7, ry: 0.24, cx: -0.12, cy: -0.15),
  ),
  // Neutral, faintly vertical.
  EmojiState.speaking: EyePair(
    left: _poly(rx: 0.62, ry: 0.72),
    right: _poly(rx: 0.62, ry: 0.72),
  ),
  // Horizontal slits.
  EmojiState.loading: EyePair(
    left: _line(halfWidth: 0.85, thickness: 0.1),
    right: _line(halfWidth: 0.85, thickness: 0.1),
  ),
  // Inverted arcs -- a smile pushed into the eyes.
  EmojiState.happy: EyePair(
    left: _poly(rx: 0.9, ry: 0.7, cy: 0.18, topBias: 0.75),
    right: _poly(rx: 0.9, ry: 0.7, cy: 0.18, topBias: 0.75),
  ),
  // Asymmetric: one wide, one narrow.
  EmojiState.confused: EyePair(
    left: _poly(rx: 0.95, ry: 0.95),
    right: _poly(rx: 0.55, ry: 0.34, cy: 0.1),
  ),
  // Eight-point spiky polygons.
  EmojiState.celebrate: EyePair(left: _star(), right: _star()),
  // Drooped and narrowed.
  EmojiState.sad: EyePair(
    left: _poly(rx: 0.82, ry: 0.5, cy: 0.22, topBias: 0.55),
    right: _poly(rx: 0.82, ry: 0.5, cy: 0.22, topBias: 0.55),
  ),
  // Flat horizontal lines.
  EmojiState.sleeping: EyePair(
    left: _line(halfWidth: 0.9, thickness: 0.05),
    right: _line(halfWidth: 0.9, thickness: 0.05),
  ),
};
