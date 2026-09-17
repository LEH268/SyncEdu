import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

const AnalyticsThresholds t = AnalyticsThresholds.standard();

void main() {
  test('fires when 40% or more of a class struggles on one skill', () {
    final builder = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withChapter(
          id: 'ch1', title: 'Quadratics',
          skills: <String>['s1'],
        );
    for (int i = 0; i < 4; i++) {
      builder.withStudentAnswering(studentId: 'w$i', skill: 's1', correct: 0, wrong: 6);
    }
    for (int i = 0; i < 6; i++) {
      builder.withStudentAnswering(studentId: 'r$i', skill: 's1', correct: 6, wrong: 0);
    }

    final recommendations =
        resourceRecommendations(rows: builder.build(), thresholds: t);

    expect(recommendations, hasLength(1));
    expect(recommendations.single.classId, 'c1');
    expect(recommendations.single.proportion, closeTo(0.4, 0.001));
    expect(recommendations.single.affectedCount, 4);
    expect(recommendations.single.studentsAssessed, 10);
    expect(recommendations.single.classSize, 10);
  });

  test('does not fire just below the threshold', () {
    // 18 students, 7 struggling -> ~38.9%, the tightest boundary check below
    // the 40% bar achievable with clean integers.
    final builder = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);
    for (int i = 0; i < 7; i++) {
      builder.withStudentAnswering(studentId: 'w$i', skill: 's1', correct: 0, wrong: 6);
    }
    for (int i = 0; i < 11; i++) {
      builder.withStudentAnswering(studentId: 'r$i', skill: 's1', correct: 6, wrong: 0);
    }

    final recommendations =
        resourceRecommendations(rows: builder.build(), thresholds: t);

    expect(recommendations, isEmpty);
  });

  test('does not fire for a class below the minimum size', () {
    // 4 students all struggling is 100%, but four students is not a signal
    // about resourcing -- it is a signal about four students.
    final builder = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);
    for (int i = 0; i < 4; i++) {
      builder.withStudentAnswering(studentId: 'w$i', skill: 's1', correct: 0, wrong: 6);
    }

    final recommendations =
        resourceRecommendations(rows: builder.build(), thresholds: t);

    expect(recommendations, isEmpty);
  });

  test('the sentence is rendered from the structure and quotes its own numbers', () {
    final builder = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);
    for (int i = 0; i < 4; i++) {
      builder.withStudentAnswering(studentId: 'w$i', skill: 's1', correct: 0, wrong: 6);
    }
    for (int i = 0; i < 6; i++) {
      builder.withStudentAnswering(studentId: 'r$i', skill: 's1', correct: 6, wrong: 0);
    }

    final recommendation =
        resourceRecommendations(rows: builder.build(), thresholds: t).single;

    expect(recommendation.sentence, contains('4 Amanah'));
    expect(recommendation.sentence, contains('Mathematics'));
    expect(recommendation.sentence, contains('40%'));
    expect(recommendation.sentence, contains(recommendation.microSkillLabel));
  });

  test('ranks by proportion times affected count', () {
    // big-class: 30 students, 15 struggling -> 50% -> rank 7.5.
    // small-class: 6 students, 4 struggling -> ~66.7% -> rank ~2.67.
    // The small class has a higher proportion but the big class has the
    // higher rank, because it reaches more students who need help.
    final builder = FixtureBuilder(seed: 1)
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);

    builder.withClass(id: 'big-class', name: 'Big Class');
    for (int i = 0; i < 15; i++) {
      builder.withStudentAnswering(studentId: 'big-w$i', skill: 's1', correct: 0, wrong: 6);
    }
    for (int i = 0; i < 15; i++) {
      builder.withStudentAnswering(studentId: 'big-r$i', skill: 's1', correct: 6, wrong: 0);
    }
    final rowsBig = builder.build();

    final builder2 = FixtureBuilder(seed: 1)
        .withClass(id: 'small-class', name: 'Small Class')
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);
    for (int i = 0; i < 4; i++) {
      builder2.withStudentAnswering(studentId: 'small-w$i', skill: 's1', correct: 0, wrong: 6);
    }
    for (int i = 0; i < 2; i++) {
      builder2.withStudentAnswering(studentId: 'small-r$i', skill: 's1', correct: 6, wrong: 0);
    }
    final rowsSmall = builder2.build();

    final ranked = resourceRecommendations(
      rows: <AnalyticRow>[...rowsBig, ...rowsSmall],
      thresholds: t,
    );

    expect(ranked, hasLength(2));
    final ResourceRecommendation big = ranked.firstWhere((r) => r.classId == 'big-class');
    final ResourceRecommendation small = ranked.firstWhere((r) => r.classId == 'small-class');
    expect(small.proportion, greaterThan(big.proportion));
    expect(big.rank, greaterThan(small.rank));
    expect(ranked.first.classId, 'big-class');
  });

  test('several skills in one class each produce their own recommendation', () {
    final builder = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2']);
    for (int i = 0; i < 4; i++) {
      builder.withStudentAnswering(studentId: 'w$i', skill: 's1', correct: 0, wrong: 6);
    }
    for (int i = 0; i < 6; i++) {
      builder.withStudentAnswering(studentId: 'r$i', skill: 's1', correct: 6, wrong: 0);
    }
    for (int i = 0; i < 4; i++) {
      builder.withStudentAnswering(studentId: 'ws2-$i', skill: 's2', correct: 0, wrong: 6);
    }
    for (int i = 0; i < 6; i++) {
      builder.withStudentAnswering(studentId: 'rs2-$i', skill: 's2', correct: 6, wrong: 0);
    }

    final recommendations =
        resourceRecommendations(rows: builder.build(), thresholds: t);

    expect(recommendations, hasLength(2));
    expect(
      recommendations.map((r) => r.microSkillId).toSet(),
      <String>{'s1', 's2'},
    );
  });

  test('prep attempts never contribute', () {
    // Without filtering prep, this class of 10 with 4 struggling in prep
    // mode (and no revise attempts at all) would incorrectly fire.
    final builder = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);
    for (int i = 0; i < 4; i++) {
      builder.withStudentAnswering(
        studentId: 'w$i', skill: 's1', correct: 0, wrong: 6, mode: 'prep',
      );
    }
    for (int i = 0; i < 6; i++) {
      builder.withStudentAnswering(
        studentId: 'r$i', skill: 's1', correct: 6, wrong: 0, mode: 'prep',
      );
    }

    final recommendations =
        resourceRecommendations(rows: builder.build(), thresholds: t);

    expect(recommendations, isEmpty);
  });

  test('no rows produce no recommendations rather than an error', () {
    final recommendations =
        resourceRecommendations(rows: const <AnalyticRow>[], thresholds: t);

    expect(recommendations, isEmpty);
  });

  test('classSize is the true class size, distinct from studentsAssessed', () {
    // 10 students in the class total, but only 6 answer enough of s1 to be
    // judged; of those 6, 3 are struggling -> proportion is 3/6 = 50%, not
    // 3/10. classSize must still report the true class size of 10.
    final builder = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2']);
    for (int i = 0; i < 3; i++) {
      builder.withStudentAnswering(studentId: 'w$i', skill: 's1', correct: 0, wrong: 6);
    }
    for (int i = 0; i < 3; i++) {
      builder.withStudentAnswering(studentId: 'r$i', skill: 's1', correct: 6, wrong: 0);
    }
    // Four more students in the class, but only on a different skill, so
    // they don't count toward studentsAssessed for s1.
    for (int i = 0; i < 4; i++) {
      builder.withStudentAnswering(studentId: 'other$i', skill: 's2', correct: 6, wrong: 0);
    }

    final recommendations =
        resourceRecommendations(rows: builder.build(), thresholds: t);

    final ResourceRecommendation s1 = recommendations.firstWhere((r) => r.microSkillId == 's1');
    expect(s1.studentsAssessed, 6);
    expect(s1.affectedCount, 3);
    expect(s1.proportion, closeTo(0.5, 0.001));
    expect(s1.classSize, 10);
  });

  test('a class where nobody struggles produces nothing', () {
    final builder = FixtureBuilder(seed: 1)
        .withClass(id: 'c1', name: '4 Amanah')
        .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);
    for (int i = 0; i < 10; i++) {
      builder.withStudentAnswering(studentId: 'r$i', skill: 's1', correct: 6, wrong: 0);
    }

    final recommendations =
        resourceRecommendations(rows: builder.build(), thresholds: t);

    expect(recommendations, isEmpty);
  });
}
