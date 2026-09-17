/// Progress curves and retry-chain grouping for student attempts.
library;

import 'inputs.dart';

/// A single point on a student's progress curve.
class ProgressPoint {
  const ProgressPoint({
    required this.attemptId,
    required this.at,
    required this.proportion,
    required this.attemptNumber,
    required this.parentAttemptId,
  });

  final String attemptId;
  final DateTime at;

  /// Score over question count, as a 0.0-1.0 ratio (0.75 means 75%) --
  /// despite the "percentage" language used when talking about it, this is
  /// never on a 0-100 scale.
  final double proportion;
  final int attemptNumber;
  final String? parentAttemptId;
}

/// A lineage of retries: an attempt and every attempt that retries it,
/// transitively, ordered oldest first.
class RetryChain {
  const RetryChain({required this.points});

  final List<ProgressPoint> points;

  /// True when the most recent attempt in the chain scored higher than the
  /// first (oldest) attempt.
  bool get improved => delta > 0;

  /// The proportion difference (0.0-1.0 scale) between the last and first
  /// points in the chain, chronologically. Positive means improvement.
  double get delta => points.last.proportion - points.first.proportion;
}

ProgressPoint _toPoint(AttemptRow attempt) {
  return ProgressPoint(
    attemptId: attempt.id,
    at: attempt.submittedAt,
    proportion: attempt.questionCount == 0 ? 0 : attempt.score / attempt.questionCount,
    attemptNumber: attempt.attemptNumber,
    parentAttemptId: attempt.parentAttemptId,
  );
}

/// Builds the chronological progress curve for [studentId].
///
/// When [revisionOnly] is true, attempts with `mode == 'prep'` are excluded.
/// Defaults to including every mode, matching the constraint that a
/// student's own progress view does not filter by mode.
List<ProgressPoint> progressCurve({
  required List<AttemptRow> attempts,
  required String studentId,
  bool revisionOnly = false,
}) {
  final Iterable<AttemptRow> scoped = attempts.where(
    (AttemptRow a) => a.studentId == studentId && (!revisionOnly || a.mode != 'prep'),
  );

  final List<ProgressPoint> points = scoped.map(_toPoint).toList()
    ..sort((ProgressPoint a, ProgressPoint b) => a.at.compareTo(b.at));

  return points;
}

/// Groups [studentId]'s attempts into retry chains via `parentAttemptId`
/// lineage. Attempts with no traceable parent (none set, or the parent isn't
/// present in [attempts]) start their own chain.
List<RetryChain> retryChains({
  required List<AttemptRow> attempts,
  required String studentId,
}) {
  final List<AttemptRow> scoped =
      attempts.where((AttemptRow a) => a.studentId == studentId).toList();
  final Map<String, AttemptRow> byId = <String, AttemptRow>{
    for (final AttemptRow a in scoped) a.id: a,
  };

  // Find the root ancestor of each attempt, guarding against cycles.
  String rootOf(AttemptRow attempt) {
    final Set<String> visited = <String>{};
    AttemptRow current = attempt;
    while (true) {
      final String? parentId = current.parentAttemptId;
      final AttemptRow? parent = parentId == null ? null : byId[parentId];
      if (parent == null || !visited.add(current.id)) {
        return current.id;
      }
      current = parent;
    }
  }

  final Map<String, List<AttemptRow>> groups = <String, List<AttemptRow>>{};
  for (final AttemptRow attempt in scoped) {
    final String root = rootOf(attempt);
    groups.putIfAbsent(root, () => <AttemptRow>[]).add(attempt);
  }

  return groups.values.map((List<AttemptRow> group) {
    final List<ProgressPoint> points = group.map(_toPoint).toList()
      ..sort((ProgressPoint a, ProgressPoint b) => a.at.compareTo(b.at));
    return RetryChain(points: points);
  }).toList();
}
