import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

void main() {
  test('a fixture produces exactly the rows it was asked for', () {
    final rows = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withStudents(count: 3)
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2'])
        .answering(skill: 's1', correct: 2, wrong: 1)
        .build();

    // 3 students x 3 items on s1.
    expect(rows.where((AnalyticRow r) => r.microSkillId == 's1'), hasLength(9));
    expect(
      rows.where((AnalyticRow r) => r.microSkillId == 's1' && !r.isCorrect),
      hasLength(3),
    );
  });

  test('every row defaults to revise mode', () {
    final rows = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withStudents(count: 1)
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
        .answering(skill: 's1', correct: 1, wrong: 0)
        .build();

    expect(rows.every((AnalyticRow r) => r.mode == 'revise'), isTrue);
  });

  test('prep rows can be requested explicitly', () {
    final rows = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withStudents(count: 1)
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
        .answering(skill: 's1', correct: 1, wrong: 1, mode: 'prep')
        .build();

    expect(rows.every((AnalyticRow r) => r.mode == 'prep'), isTrue);
  });

  test('the same seed produces identical rows', () {
    List<AnalyticRow> make() => FixtureBuilder(seed: 9)
        .withClass(id: 'c1', name: '4 Amanah')
        .withStudents(count: 4)
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
        .answering(skill: 's1', correct: 3, wrong: 2)
        .build();

    expect(
      make().map((AnalyticRow r) => '${r.studentId}:${r.isCorrect}').toList(),
      make().map((AnalyticRow r) => '${r.studentId}:${r.isCorrect}').toList(),
    );
  });

  test('thresholds are stated, not implied', () {
    const t = AnalyticsThresholds.standard();
    expect(t.minimumItemsForConceptRanking, 5);
    expect(t.minimumItemsForStudentSkillJudgement, 3);
    expect(t.strugglingAccuracyBar, 0.5);
    expect(t.recommendationProportion, 0.40);
    expect(t.recommendationMinimumClassSize, 5);
    expect(t.masteryGreenFloor, 0.75);
    expect(t.masteryAmberFloor, 0.50);
    expect(t.inactivityDays, 7);
    expect(t.decliningPointDrop, 15);
    expect(t.failedSkillsForHighRisk, 3);
    expect(t.decliningAttemptWindow, 3);
  });
}
