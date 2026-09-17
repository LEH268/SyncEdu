import 'package:flutter/painting.dart';

import 'emoji_state.dart';

/// The target body deformation for a state: a radial offset per body control
/// point, an overall squash factor, and a translation the whole silhouette
/// drifts towards.
class Pose {
  const Pose({
    required this.radialOffsets,
    required this.squash,
    required this.drift,
  });

  /// One per body control point. Added to the base radius profile, in units of
  /// the base radius (so 0.05 is a 5% bulge). Length is always
  /// [kBodyPointCount].
  final List<double> radialOffsets;

  /// Horizontal scale multiplier. The painter derives the vertical scale as
  /// `1 / squash`, so `sx * sy == 1` and the character deforms rather than
  /// changing area (spec 8.4: "volume preserved").
  final double squash;

  /// Where the silhouette's centre eases to, as a fraction of its size.
  final Offset drift;
}

/// The body is a closed path of fourteen control points (spec 8.4).
const int kBodyPointCount = 14;

List<double> _offsets(double Function(int i) f) =>
    <double>[for (int i = 0; i < kBodyPointCount; i++) f(i)];

/// A gentle asymmetric lean: points on one side pushed out, the other pulled
/// in. `i` runs clockwise from the crown.
List<double> _lean(double amount) => _offsets((int i) {
      final double phase = i / kBodyPointCount;
      return amount * (phase < 0.5 ? 1 : -1) * 0.6;
    });

final Map<EmojiState, Pose> _poses = <EmojiState, Pose>{
  EmojiState.idle: Pose(
    radialOffsets: _offsets((_) => 0.0),
    squash: 1.0,
    drift: Offset.zero,
  ),
  EmojiState.listening: Pose(
    radialOffsets: _offsets((int i) => i < kBodyPointCount ~/ 2 ? 0.03 : 0.0),
    squash: 0.97,
    drift: const Offset(0.0, -0.03),
  ),
  EmojiState.thinking: Pose(
    radialOffsets: _lean(0.04),
    squash: 1.0,
    drift: const Offset(-0.03, 0.0),
  ),
  EmojiState.speaking: Pose(
    radialOffsets: _offsets((_) => 0.0),
    squash: 1.0,
    drift: const Offset(0.0, 0.02),
  ),
  EmojiState.loading: Pose(
    radialOffsets: _offsets((_) => 0.0),
    squash: 1.0,
    drift: Offset.zero,
  ),
  EmojiState.happy: Pose(
    radialOffsets: _offsets((int i) => i.isEven ? 0.06 : 0.02),
    squash: 0.9,
    drift: const Offset(0.0, -0.02),
  ),
  EmojiState.confused: Pose(
    radialOffsets: _lean(0.05),
    squash: 1.05,
    drift: const Offset(0.04, 0.02),
  ),
  EmojiState.celebrate: Pose(
    radialOffsets: _offsets((int i) => i.isEven ? 0.09 : -0.03),
    squash: 0.82,
    drift: const Offset(0.0, -0.06),
  ),
  EmojiState.sad: Pose(
    radialOffsets: _offsets((int i) => i > kBodyPointCount ~/ 2 ? 0.05 : -0.02),
    squash: 1.2,
    drift: const Offset(0.0, 0.06),
  ),
  EmojiState.sleeping: Pose(
    radialOffsets: _offsets((_) => 0.0),
    squash: 1.08,
    drift: const Offset(0.0, 0.03),
  ),
};

/// The target pose for [state]. Total, so a missing entry is a compile-time
/// impossibility rather than a runtime null.
Pose poseFor(EmojiState state) => _poses[state]!;
