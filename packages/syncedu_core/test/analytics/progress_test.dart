import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

AttemptRow _attempt({
  required String id,
  required String studentId,
  String? parentAttemptId,
  required int attemptNumber,
  required int score,
  required int questionCount,
  required DateTime submittedAt,
  String mode = 'revise',
}) {
  return AttemptRow(
    id: id,
    studentId: studentId,
    parentAttemptId: parentAttemptId,
    attemptNumber: attemptNumber,
    score: score,
    questionCount: questionCount,
    submittedAt: submittedAt,
    mode: mode,
  );
}

void main() {
  final DateTime base = DateTime.utc(2024, 1, 1);

  group('progressCurve', () {
    test('points are ordered oldest first', () {
      final List<AttemptRow> attempts = <AttemptRow>[
        _attempt(
          id: 'a2',
          studentId: 's1',
          attemptNumber: 2,
          score: 5,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 2)),
        ),
        _attempt(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 3,
          questionCount: 10,
          submittedAt: base,
        ),
        _attempt(
          id: 'a3',
          studentId: 's1',
          attemptNumber: 3,
          score: 8,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 1)),
        ),
      ];

      final List<ProgressPoint> points = progressCurve(attempts: attempts, studentId: 's1');

      expect(points.map((ProgressPoint p) => p.attemptId).toList(), <String>['a1', 'a3', 'a2']);
    });

    test('proportion is score over question count', () {
      final List<AttemptRow> attempts = <AttemptRow>[
        _attempt(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 3,
          questionCount: 4,
          submittedAt: base,
        ),
      ];

      final List<ProgressPoint> points = progressCurve(attempts: attempts, studentId: 's1');

      expect(points, hasLength(1));
      expect(points.single.proportion, closeTo(0.75, 1e-9));
    });

    test('the student view includes prep attempts', () {
      final List<AttemptRow> attempts = <AttemptRow>[
        _attempt(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 3,
          questionCount: 10,
          submittedAt: base,
          mode: 'revise',
        ),
        _attempt(
          id: 'a2',
          studentId: 's1',
          attemptNumber: 1,
          score: 7,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 1)),
          mode: 'prep',
        ),
      ];

      final List<ProgressPoint> points = progressCurve(
        attempts: attempts,
        studentId: 's1',
        revisionOnly: false,
      );

      expect(points.map((ProgressPoint p) => p.attemptId).toSet(), <String>{'a1', 'a2'});
    });

    test('revisionOnly excludes prep attempts', () {
      final List<AttemptRow> attempts = <AttemptRow>[
        _attempt(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 3,
          questionCount: 10,
          submittedAt: base,
          mode: 'revise',
        ),
        _attempt(
          id: 'a2',
          studentId: 's1',
          attemptNumber: 1,
          score: 7,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 1)),
          mode: 'prep',
        ),
      ];

      final List<ProgressPoint> points = progressCurve(
        attempts: attempts,
        studentId: 's1',
        revisionOnly: true,
      );

      expect(points.map((ProgressPoint p) => p.attemptId).toList(), <String>['a1']);
    });

  });

  group('retryChains', () {
    test('a chain links a retry to its parent', () {
      final List<AttemptRow> attempts = <AttemptRow>[
        _attempt(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 3,
          questionCount: 10,
          submittedAt: base,
        ),
        _attempt(
          id: 'a2',
          studentId: 's1',
          parentAttemptId: 'a1',
          attemptNumber: 2,
          score: 8,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 1)),
        ),
      ];

      final List<RetryChain> chains = retryChains(attempts: attempts, studentId: 's1');

      expect(chains, hasLength(1));
      expect(chains.single.points.map((ProgressPoint p) => p.attemptId).toList(), <String>['a1', 'a2']);
    });

    test('a chain reports whether the student improved', () {
      final List<AttemptRow> improvingAttempts = <AttemptRow>[
        _attempt(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 3,
          questionCount: 10,
          submittedAt: base,
        ),
        _attempt(
          id: 'a2',
          studentId: 's1',
          parentAttemptId: 'a1',
          attemptNumber: 2,
          score: 8,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 1)),
        ),
      ];

      final RetryChain improvingChain =
          retryChains(attempts: improvingAttempts, studentId: 's1').single;

      expect(improvingChain.improved, isTrue);
      expect(improvingChain.delta, closeTo(0.5, 1e-9));

      final List<AttemptRow> worseningAttempts = <AttemptRow>[
        _attempt(
          id: 'b1',
          studentId: 's1',
          attemptNumber: 1,
          score: 8,
          questionCount: 10,
          submittedAt: base,
        ),
        _attempt(
          id: 'b2',
          studentId: 's1',
          parentAttemptId: 'b1',
          attemptNumber: 2,
          score: 3,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 1)),
        ),
      ];

      final RetryChain worseningChain =
          retryChains(attempts: worseningAttempts, studentId: 's1').single;

      expect(worseningChain.improved, isFalse);
      expect(worseningChain.delta, closeTo(-0.5, 1e-9));
    });

    test('unrelated attempts form single-point chains, not one long chain', () {
      final List<AttemptRow> attempts = <AttemptRow>[
        _attempt(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 3,
          questionCount: 10,
          submittedAt: base,
        ),
        _attempt(
          id: 'a2',
          studentId: 's1',
          attemptNumber: 1,
          score: 5,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 1)),
        ),
        _attempt(
          id: 'a3',
          studentId: 's1',
          attemptNumber: 1,
          score: 9,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 2)),
        ),
      ];

      final List<RetryChain> chains = retryChains(attempts: attempts, studentId: 's1');

      expect(chains, hasLength(3));
      for (final RetryChain chain in chains) {
        expect(chain.points, hasLength(1));
      }
    });

    test('a chain of three retries stays one chain', () {
      final List<AttemptRow> attempts = <AttemptRow>[
        _attempt(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 2,
          questionCount: 10,
          submittedAt: base,
        ),
        _attempt(
          id: 'a2',
          studentId: 's1',
          parentAttemptId: 'a1',
          attemptNumber: 2,
          score: 5,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 1)),
        ),
        _attempt(
          id: 'a3',
          studentId: 's1',
          parentAttemptId: 'a2',
          attemptNumber: 3,
          score: 9,
          questionCount: 10,
          submittedAt: base.add(const Duration(days: 2)),
        ),
      ];

      final List<RetryChain> chains = retryChains(attempts: attempts, studentId: 's1');

      expect(chains, hasLength(1));
      expect(
        chains.single.points.map((ProgressPoint p) => p.attemptId).toList(),
        <String>['a1', 'a2', 'a3'],
      );
    });

    test('an orphaned parent reference does not lose the attempt', () {
      final List<AttemptRow> attempts = <AttemptRow>[
        _attempt(
          id: 'a2',
          studentId: 's1',
          parentAttemptId: 'missing-parent',
          attemptNumber: 2,
          score: 6,
          questionCount: 10,
          submittedAt: base,
        ),
      ];

      final List<RetryChain> chains = retryChains(attempts: attempts, studentId: 's1');

      expect(chains, hasLength(1));
      expect(chains.single.points.map((ProgressPoint p) => p.attemptId).toList(), <String>['a2']);
    });
  });
}
