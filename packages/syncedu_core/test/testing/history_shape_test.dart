import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

const AnalyticsThresholds t = AnalyticsThresholds.standard();

void main() {
  const HistoryShape shape = HistoryShape.demonstration();

  test('the shape names three at-risk students with three distinct rules', () {
    final Set<String> rules =
        shape.atRiskStudents.map((AtRiskPlan p) => p.ruleId).toSet();
    expect(rules, hasLength(3));
    expect(
      rules,
      containsAll(<String>['low_mastery', 'inactive', 'declining']),
    );
  });

  test('the deficit class sits above the recommendation threshold', () {
    expect(
      shape.deficit.strugglingProportion,
      greaterThanOrEqualTo(t.recommendationProportion),
    );
  });

  test('the deficit proportion stays in the 45-55% band, not manufactured', () {
    expect(shape.deficit.strugglingProportion, inInclusiveRange(0.45, 0.55));
  });

  test('the deficit class is large enough for the rule to fire', () {
    expect(
      shape.deficit.assessedStudents,
      greaterThanOrEqualTo(t.recommendationMinimumClassSize),
    );
    expect(shape.deficit.firesRecommendation(t), isTrue);
  });

  test("the improving student's arc rises by at least twenty points", () {
    expect(shape.improvingStudent.riseInPoints, greaterThanOrEqualTo(20));
  });

  test("the improving student's attempts form one chain, not three", () {
    // Modelled as a single parent-linked lineage: build the AttemptRows the
    // way the seed generator will and confirm retryChains groups them into
    // exactly one chain that reads as improved.
    final List<int> scores = shape.improvingStudent.attemptScores;
    final DateTime base = DateTime.utc(2026, 8, 1);
    final List<AttemptRow> attempts = <AttemptRow>[
      for (int i = 0; i < scores.length; i++)
        AttemptRow(
          id: 'imp-$i',
          studentId: 'imp',
          parentAttemptId: i == 0 ? null : 'imp-${i - 1}',
          attemptNumber: i + 1,
          score: scores[i],
          questionCount: 100,
          submittedAt: base.add(Duration(days: i * 2)),
          mode: 'revise',
        ),
    ];

    final List<RetryChain> chains =
        retryChains(attempts: attempts, studentId: 'imp');
    expect(chains, hasLength(1));
    expect(chains.single.points, hasLength(scores.length));
    expect(chains.single.improved, isTrue);
    expect(chains.single.delta, greaterThanOrEqualTo(0.20));
  });

  test("the inactive student's last attempt is more than seven days old", () {
    final AtRiskPlan inactive = shape.atRiskStudents
        .firstWhere((AtRiskPlan p) => p.rule == AtRiskRule.inactive);
    expect(inactive.lastAttemptDaysAgo, greaterThan(t.inactivityDays));
  });

  test('the declining student has at least three consecutive falling attempts',
      () {
    final AtRiskPlan declining = shape.atRiskStudents
        .firstWhere((AtRiskPlan p) => p.rule == AtRiskRule.declining);
    final List<int> scores = declining.decliningScores!;
    expect(scores.length, greaterThanOrEqualTo(t.decliningAttemptWindow));
    for (int i = 1; i < scores.length; i++) {
      expect(scores[i - 1] - scores[i], greaterThanOrEqualTo(t.decliningPointDrop));
    }
  });

  test("the low-mastery student's overall accuracy is below the bar", () {
    final AtRiskPlan low = shape.atRiskStudents
        .firstWhere((AtRiskPlan p) => p.rule == AtRiskRule.lowMastery);
    expect(low.overallAccuracy, lessThan(t.strugglingAccuracyBar));
  });

  test('healthy students exist so the at-risk list is not everyone', () {
    // A seed where every student is at risk demonstrates nothing.
    expect(shape.healthyStudentCount, greaterThan(shape.atRiskStudents.length));
    expect(shape.healthyStudentCount, greaterThan(shape.totalStudents ~/ 2));
  });

  test('one class is scheduled several chapters ahead of another', () {
    expect(
      shape.schedule.aheadChaptersTaught,
      greaterThan(shape.schedule.behindChaptersTaught + 1),
    );
    expect(shape.schedule.aheadClassSlot,
        isNot(equals(shape.schedule.behindClassSlot)));
  });

  test('the configuration matches the spec target', () {
    expect(shape.weeks, 4);
    expect(shape.classCount, 3);
    expect(shape.studentsPerClass, inInclusiveRange(10, 14));
    expect(shape.teacherCount, 2);
    expect(shape.totalStudents, 36);
  });

  test('generation is deterministic for a given seed', () {
    const HistoryShape a = HistoryShape.demonstration();
    const HistoryShape b = HistoryShape.demonstration();
    expect(a.atRiskRuleIds, equals(b.atRiskRuleIds));
    expect(a.deficit.strugglingProportion, equals(b.deficit.strugglingProportion));
    expect(a.improvingStudent.attemptScores,
        equals(b.improvingStudent.attemptScores));
    expect(a.healthyStudentCount, equals(b.healthyStudentCount));
  });
}
