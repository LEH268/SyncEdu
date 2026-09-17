import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

const AnalyticsThresholds t = AnalyticsThresholds.standard();
final DateTime now = DateTime.utc(2026, 9, 5, 12);

AttemptRow recentAttempt(String studentId, DateTime at, {int attemptNumber = 1, int score = 8, int questionCount = 10}) {
  return AttemptRow(
    id: '$studentId-attempt-$attemptNumber-${at.microsecondsSinceEpoch}',
    studentId: studentId,
    attemptNumber: attemptNumber,
    score: score,
    questionCount: questionCount,
    submittedAt: at,
    mode: 'revise',
  );
}

void main() {
  group('schoolDifficultyRanking', () {
    test('the proportion counts STUDENTS struggling, not answers wrong', () {
      final builder = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);

      builder.withStudentAnswering(studentId: 'a', skill: 's1', correct: 0, wrong: 8);
      builder.withStudentAnswering(studentId: 'b', skill: 's1', correct: 3, wrong: 5);
      builder.withStudentAnswering(studentId: 'c', skill: 's1', correct: 8, wrong: 0);
      builder.withStudentAnswering(studentId: 'd', skill: 's1', correct: 8, wrong: 0);

      final ranked = schoolDifficultyRanking(
        rows: builder.build(), limit: 5, thresholds: t,
      );

      expect(ranked.single.studentsAttempted, 4);
      expect(ranked.single.studentsStruggling, 2);
      expect(ranked.single.proportion, closeTo(0.5, 0.001));
      expect(ranked.single.proportion, isNot(closeTo(0.406, 0.01)));
    });

    test('a student below the per-student item floor is not counted at all', () {
      final builder = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);

      builder.withStudentAnswering(studentId: 'a', skill: 's1', correct: 0, wrong: 2);
      builder.withStudentAnswering(studentId: 'b', skill: 's1', correct: 0, wrong: 6);
      builder.withStudentAnswering(studentId: 'c', skill: 's1', correct: 6, wrong: 0);

      final ranked = schoolDifficultyRanking(
        rows: builder.build(), limit: 5, thresholds: t,
      );

      expect(ranked.single.studentsAttempted, 2);
      expect(ranked.single.studentsStruggling, 1);
    });

    test('ranks across every class in the school', () {
      final rowsA = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .withStudentAnswering(studentId: 'a', skill: 's1', correct: 0, wrong: 6)
          .withStudentAnswering(studentId: 'b', skill: 's1', correct: 6, wrong: 0)
          .build();
      final rowsB = FixtureBuilder(seed: 2)
          .withClass(id: 'c2', name: '4 Bestari')
          .withChapter(id: 'ch2', title: 'Trigonometry', skills: <String>['s2'])
          .withStudentAnswering(studentId: 'c', skill: 's2', correct: 0, wrong: 6)
          .withStudentAnswering(studentId: 'd', skill: 's2', correct: 6, wrong: 0)
          .build();

      final ranked = schoolDifficultyRanking(
        rows: <AnalyticRow>[...rowsA, ...rowsB], limit: 5, thresholds: t,
      );

      expect(ranked.length, 2);
      expect(ranked.map((r) => r.microSkillId), containsAll(<String>['s1', 's2']));
    });

    test('prep attempts are excluded', () {
      final builder = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);

      builder.withStudentAnswering(studentId: 'a', skill: 's1', correct: 0, wrong: 6, mode: 'prep');
      builder.withStudentAnswering(studentId: 'b', skill: 's1', correct: 0, wrong: 6);
      builder.withStudentAnswering(studentId: 'c', skill: 's1', correct: 6, wrong: 0);

      final ranked = schoolDifficultyRanking(
        rows: builder.build(), limit: 5, thresholds: t,
      );

      expect(ranked.single.studentsAttempted, 2);
      expect(ranked.single.studentsStruggling, 1);
    });

    test('the limit is honoured and ordering is by proportion', () {
      final rowsA = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .withStudentAnswering(studentId: 'a', skill: 's1', correct: 0, wrong: 6)
          .withStudentAnswering(studentId: 'b', skill: 's1', correct: 0, wrong: 6)
          .build();
      final rowsB = FixtureBuilder(seed: 2)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch2', title: 'Trigonometry', skills: <String>['s2'])
          .withStudentAnswering(studentId: 'c', skill: 's2', correct: 0, wrong: 6)
          .withStudentAnswering(studentId: 'd', skill: 's2', correct: 6, wrong: 0)
          .build();
      final rowsC = FixtureBuilder(seed: 3)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch3', title: 'Geometry', skills: <String>['s3'])
          .withStudentAnswering(studentId: 'e', skill: 's3', correct: 6, wrong: 0)
          .withStudentAnswering(studentId: 'f', skill: 's3', correct: 6, wrong: 0)
          .build();

      final ranked = schoolDifficultyRanking(
        rows: <AnalyticRow>[...rowsA, ...rowsB, ...rowsC], limit: 2, thresholds: t,
      );

      expect(ranked.length, 2);
      expect(ranked[0].microSkillId, 's1');
      expect(ranked[0].proportion, closeTo(1.0, 0.001));
      expect(ranked[1].microSkillId, 's2');
      expect(ranked[1].proportion, closeTo(0.5, 0.001));
      expect(ranked[0].proportion, greaterThanOrEqualTo(ranked[1].proportion));
    });
  });

  group('atRiskStudents', () {
    test('overall accuracy below 50% is high risk with a stated reason', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2'])
          .answering(skill: 's1', correct: 2, wrong: 8)
          .answering(skill: 's2', correct: 2, wrong: 8)
          .build();

      final risk = atRiskStudents(
        rows: rows,
        attempts: <AttemptRow>[recentAttempt('stu-0', now)],
        now: now,
        thresholds: t,
      );

      expect(risk.single.level, RiskLevel.high);
      expect(risk.single.reasons.first, contains('mastery'));
    });

    test('three or more failed skills is high risk', () {
      // Three skills each individually below the struggling bar (1/6 = 17%),
      // plus a fourth skill the student aces, so overall accuracy is
      // (3 + 24) / (18 + 24) = 27/42 = 64%, comfortably above the 50% bar.
      // This isolates the "three failed skills" rule as the only possible
      // source of the `high` result -- the overall-mastery rule cannot fire.
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2', 's3', 's4'])
          .answering(skill: 's1', correct: 1, wrong: 5)
          .answering(skill: 's2', correct: 1, wrong: 5)
          .answering(skill: 's3', correct: 1, wrong: 5)
          .answering(skill: 's4', correct: 24, wrong: 0)
          .build();

      final risk = atRiskStudents(
        rows: rows,
        attempts: <AttemptRow>[recentAttempt('stu-0', now)],
        now: now,
        thresholds: t,
      );

      expect(risk.single.level, RiskLevel.high);
      expect(risk.single.reasons.any((r) => r.contains('failing 3 skills')), isTrue);
    });

    test('no attempt in seven days is medium risk naming the gap', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 6, wrong: 0)
          .build();

      final staleAttempt = recentAttempt('stu-0', now.subtract(const Duration(days: 10)));

      final risk = atRiskStudents(
        rows: rows,
        attempts: <AttemptRow>[staleAttempt],
        now: now,
        thresholds: t,
      );

      expect(risk.single.level, RiskLevel.medium);
      expect(risk.single.reasons.any((r) => r.contains('days')), isTrue);
    });

    test('three consecutive attempts falling fifteen points is medium risk', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 6, wrong: 0)
          .build();

      final attempts = <AttemptRow>[
        recentAttempt('stu-0', now.subtract(const Duration(days: 3)), attemptNumber: 1, score: 9, questionCount: 10),
        recentAttempt('stu-0', now.subtract(const Duration(days: 2)), attemptNumber: 2, score: 7, questionCount: 10),
        recentAttempt('stu-0', now.subtract(const Duration(days: 1)), attemptNumber: 3, score: 5, questionCount: 10),
      ];

      final risk = atRiskStudents(
        rows: rows,
        attempts: attempts,
        now: now,
        thresholds: t,
      );

      expect(risk.single.level, RiskLevel.medium);
      expect(risk.single.reasons.any((r) => r.contains('declining')), isTrue);
    });

    test('two consecutive falling attempts is NOT declining', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 6, wrong: 0)
          .build();

      final attempts = <AttemptRow>[
        recentAttempt('stu-0', now.subtract(const Duration(days: 2)), attemptNumber: 1, score: 9, questionCount: 10),
        recentAttempt('stu-0', now.subtract(const Duration(days: 1)), attemptNumber: 2, score: 7, questionCount: 10),
      ];

      final risk = atRiskStudents(
        rows: rows,
        attempts: attempts,
        now: now,
        thresholds: t,
      );

      expect(risk, isEmpty);
    });

    test('a student who declined long ago but has since recovered is not flagged declining', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 6, wrong: 0)
          .build();

      final attempts = <AttemptRow>[
        // Declining trio, long ago.
        recentAttempt('stu-0', now.subtract(const Duration(days: 30)), attemptNumber: 1, score: 9, questionCount: 10),
        recentAttempt('stu-0', now.subtract(const Duration(days: 29)), attemptNumber: 2, score: 7, questionCount: 10),
        recentAttempt('stu-0', now.subtract(const Duration(days: 28)), attemptNumber: 3, score: 5, questionCount: 10),
        // Since recovered: the most recent three attempts are flat/improving.
        recentAttempt('stu-0', now.subtract(const Duration(days: 3)), attemptNumber: 4, score: 8, questionCount: 10),
        recentAttempt('stu-0', now.subtract(const Duration(days: 2)), attemptNumber: 5, score: 9, questionCount: 10),
        recentAttempt('stu-0', now.subtract(const Duration(days: 1)), attemptNumber: 6, score: 10, questionCount: 10),
      ];

      final risk = atRiskStudents(
        rows: rows,
        attempts: attempts,
        now: now,
        thresholds: t,
      );

      expect(risk.any((r) => r.reasons.any((reason) => reason.contains('declining'))), isFalse);
    });

    test('a student meeting several rules reports all reasons but one level', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2'])
          .answering(skill: 's1', correct: 2, wrong: 8)
          .answering(skill: 's2', correct: 2, wrong: 8)
          .build();

      final staleAttempt = recentAttempt('stu-0', now.subtract(const Duration(days: 10)));

      final risk = atRiskStudents(
        rows: rows,
        attempts: <AttemptRow>[staleAttempt],
        now: now,
        thresholds: t,
      );

      expect(risk.single.level, RiskLevel.high);
      expect(risk.single.reasons.length, greaterThanOrEqualTo(2));
      expect(risk.single.reasons.any((r) => r.contains('mastery')), isTrue);
      expect(risk.single.reasons.any((r) => r.contains('days')), isTrue);
    });

    test('the highest level wins when rules disagree', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 1, wrong: 9)
          .build();

      final staleAttempt = recentAttempt('stu-0', now.subtract(const Duration(days: 10)));

      final risk = atRiskStudents(
        rows: rows,
        attempts: <AttemptRow>[staleAttempt],
        now: now,
        thresholds: t,
      );

      expect(risk.single.level, RiskLevel.high);
      expect(risk.single.reasons.any((r) => r.contains('mastery')), isTrue);
      expect(risk.single.reasons.any((r) => r.contains('days')), isTrue);
    });

    test('prep-mode attempts are excluded from the inactivity and decline rules', () {
      // Only prep-mode attempts exist, all recent -- if they weren't filtered
      // out, the student's last (prep) attempt would suppress the inactivity
      // rule. With prep excluded, there are no revise attempts at all, so the
      // inactivity rule cannot fire either way here; instead we prove a
      // prep-mode declining trio does NOT trigger the declining reason.
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 1, wrong: 9)
          .build();

      final prepAttempts = <AttemptRow>[
        AttemptRow(
          id: 'p1',
          studentId: 'stu-0',
          attemptNumber: 1,
          score: 9,
          questionCount: 10,
          submittedAt: now.subtract(const Duration(days: 3)),
          mode: 'prep',
        ),
        AttemptRow(
          id: 'p2',
          studentId: 'stu-0',
          attemptNumber: 2,
          score: 7,
          questionCount: 10,
          submittedAt: now.subtract(const Duration(days: 2)),
          mode: 'prep',
        ),
        AttemptRow(
          id: 'p3',
          studentId: 'stu-0',
          attemptNumber: 3,
          score: 5,
          questionCount: 10,
          submittedAt: now.subtract(const Duration(days: 1)),
          mode: 'prep',
        ),
      ];

      final risk = atRiskStudents(
        rows: rows,
        attempts: prepAttempts,
        now: now,
        thresholds: t,
      );

      expect(risk.single.level, RiskLevel.high);
      expect(risk.single.reasons.any((r) => r.contains('declining')), isFalse);
      // No revise attempts survive filtering, so there is nothing to measure
      // an inactivity gap against either.
      expect(risk.single.reasons.any((r) => r.contains('days')), isFalse);
    });

    test('a student with too little total data is not flagged by overall mastery, even at 0%', () {
      // Only 2 total answered items, both wrong (0% accuracy), which is
      // below minimumItemsForStudentSkillJudgement (3). Without a floor,
      // one bad guess would swing a student straight to high risk.
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 0, wrong: 2)
          .build();

      final risk = atRiskStudents(
        rows: rows,
        attempts: <AttemptRow>[recentAttempt('stu-0', now)],
        now: now,
        thresholds: t,
      );

      expect(risk, isEmpty);
    });

    test('a healthy student is absent from the list entirely', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 9, wrong: 1)
          .build();

      final risk = atRiskStudents(
        rows: rows,
        attempts: <AttemptRow>[recentAttempt('stu-0', now)],
        now: now,
        thresholds: t,
      );

      expect(risk, isEmpty);
    });

    test('a student with too few attempts to judge decline is not reported as declining', () {
      // Low overall mastery so the student DOES appear in the risk list (via
      // the mastery rule), with fewer than 3 attempts so the declining rule
      // has nothing to judge. Pins that the declining reason never appears
      // in that case, even while the row exists for another reason.
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 1, wrong: 9)
          .build();

      final risk = atRiskStudents(
        rows: rows,
        attempts: <AttemptRow>[],
        now: now,
        thresholds: t,
      );

      expect(risk.single.level, RiskLevel.high);
      expect(risk.single.reasons.any((reason) => reason.contains('declining')), isFalse);
    });
  });

  group('schoolKpis', () {
    test('counts distinct students and the supplied teacher count', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 3, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 5, wrong: 5)
          .build();

      final kpis = schoolKpis(rows: rows, risk: <RiskRow>[], teacherCount: 4);

      expect(kpis.totalStudents, 3);
      expect(kpis.totalTeachers, 4);
    });

    test('average mastery is the mean of per-student accuracies, not of items', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .withStudentAnswering(studentId: 'a', skill: 's1', correct: 90, wrong: 10)
          .withStudentAnswering(studentId: 'b', skill: 's1', correct: 0, wrong: 10)
          .build();

      final kpis = schoolKpis(rows: rows, risk: <RiskRow>[], teacherCount: 1);

      // Per-student accuracies: a = 0.9, b = 0.0 -> mean = 0.45, NOT 90/110.
      expect(kpis.averageMastery, closeTo(0.45, 0.001));
    });

    test('prep-mode rows are excluded from the mastery figure', () {
      // Student 'a' has only revise rows (accuracy 0.9). Student 'b' has only
      // prep rows that, if not filtered, would drag the mean down to 0.45.
      // With prep excluded, 'b' contributes nothing and 'a' is the only
      // counted student.
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .withStudentAnswering(studentId: 'a', skill: 's1', correct: 9, wrong: 1)
          .withStudentAnswering(studentId: 'b', skill: 's1', correct: 0, wrong: 10, mode: 'prep')
          .build();

      final kpis = schoolKpis(rows: rows, risk: <RiskRow>[], teacherCount: 1);

      expect(kpis.totalStudents, 1);
      expect(kpis.averageMastery, closeTo(0.9, 0.001));
    });

    test('at-risk count matches the risk list length', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 2, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 5, wrong: 5)
          .build();

      final risk = <RiskRow>[
        const RiskRow(
          studentId: 'stu-0',
          studentName: 'Student for stu-0',
          classId: 'c1',
          className: '4 Amanah',
          level: RiskLevel.high,
          reasons: <String>['low mastery'],
        ),
      ];

      final kpis = schoolKpis(rows: rows, risk: risk, teacherCount: 2);

      expect(kpis.studentsAtRisk, risk.length);
    });

    test('no rows give zero counts and zero mastery rather than NaN', () {
      final kpis = schoolKpis(rows: <AnalyticRow>[], risk: <RiskRow>[], teacherCount: 0);

      expect(kpis.totalStudents, 0);
      expect(kpis.averageMastery, 0.0);
      expect(kpis.averageMastery.isNaN, isFalse);
      expect(kpis.studentsAtRisk, 0);
    });
  });
}
