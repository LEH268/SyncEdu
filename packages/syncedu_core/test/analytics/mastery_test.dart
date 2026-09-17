import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

const AnalyticsThresholds t = AnalyticsThresholds.standard();

void main() {
  group('masteryHeatmap', () {
    test('accuracy is correct over total for the class', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 2)
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 3, wrong: 1)
          .build();

      final cells = masteryHeatmap(rows: rows, classId: 'c1', thresholds: t);

      expect(cells, hasLength(1));
      expect(cells.single.total, 8);
      expect(cells.single.correct, 6);
      expect(cells.single.accuracy, closeTo(0.75, 0.001));
    });

    test('bands are green at or above 75, amber at or above 50, red below', () {
      MasteryBand bandFor(int correct, int wrong) => masteryHeatmap(
            rows: FixtureBuilder(seed: 1)
                .withClass(id: 'c1', name: '4 Amanah')
                .withStudents(count: 1)
                .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
                .answering(skill: 's1', correct: correct, wrong: wrong)
                .build(),
            classId: 'c1',
            thresholds: t,
          ).single.band;

      expect(bandFor(8, 2), MasteryBand.green);
      expect(bandFor(75, 25), MasteryBand.green);
      expect(bandFor(6, 4), MasteryBand.amber);
      expect(bandFor(4, 6), MasteryBand.red);
    });

    test('prep attempts are excluded from a teacher-facing heatmap', () {
      // Requirement 25: a student exploring ahead must not be penalised.
      final rows = <AnalyticRow>[
        ...FixtureBuilder(seed: 1)
            .withClass(id: 'c1', name: '4 Amanah')
            .withStudents(count: 1)
            .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
            .answering(skill: 's1', correct: 4, wrong: 0)
            .build(),
        ...FixtureBuilder(seed: 2)
            .withClass(id: 'c1', name: '4 Amanah')
            .withStudents(count: 1)
            .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
            .answering(skill: 's1', correct: 0, wrong: 20, mode: 'prep')
            .build(),
      ];

      final cells = masteryHeatmap(rows: rows, classId: 'c1', thresholds: t);

      expect(cells.single.total, 4);
      expect(cells.single.band, MasteryBand.green);
    });

    test('another class\'s rows are excluded', () {
      final rows = <AnalyticRow>[
        ...FixtureBuilder(seed: 1)
            .withClass(id: 'c1', name: '4 Amanah')
            .withStudents(count: 1)
            .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
            .answering(skill: 's1', correct: 4, wrong: 0)
            .build(),
        ...FixtureBuilder(seed: 2)
            .withClass(id: 'c2', name: '4 Bestari')
            .withStudents(count: 1)
            .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
            .answering(skill: 's1', correct: 0, wrong: 4)
            .build(),
      ];

      final cells = masteryHeatmap(rows: rows, classId: 'c1', thresholds: t);
      expect(cells.single.accuracy, 1.0);
    });

    test('a chapter with too few items is marked insufficient, not red', () {
      // Reporting 0% off two answers would be a lie a teacher would act on.
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1)
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 0, wrong: 2)
          .build();

      expect(
        masteryHeatmap(rows: rows, classId: 'c1', thresholds: t).single.band,
        MasteryBand.insufficient,
      );
    });

    test('each cell carries its per-skill breakdown', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 2)
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2'])
          .answering(skill: 's1', correct: 4, wrong: 0)
          .answering(skill: 's2', correct: 0, wrong: 4)
          .build();

      final cell = masteryHeatmap(rows: rows, classId: 'c1', thresholds: t).single;

      expect(cell.skills, hasLength(2));
      expect(cell.skills.firstWhere((SkillCell s) => s.microSkillId == 's1').accuracy, 1.0);
      expect(cell.skills.firstWhere((SkillCell s) => s.microSkillId == 's2').accuracy, 0.0);
    });

    test('no rows produce no cells rather than an error', () {
      expect(
        masteryHeatmap(rows: const <AnalyticRow>[], classId: 'c1', thresholds: t),
        isEmpty,
      );
    });
  });

  group('mostMissedConcepts', () {
    test('ranks by error rate descending', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 2)
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2', 's3'])
          .answering(skill: 's1', correct: 1, wrong: 4)
          .answering(skill: 's2', correct: 3, wrong: 2)
          .answering(skill: 's3', correct: 5, wrong: 0)
          .build();

      final ranked = mostMissedConcepts(rows: rows, classId: 'c1', limit: 3, thresholds: t);

      expect(ranked.map((ConceptRank r) => r.microSkillId).toList(),
          <String>['s1', 's2', 's3']);
      expect(ranked.first.errorRate, closeTo(0.8, 0.001));
    });

    test('a skill below the minimum sample is excluded entirely', () {
      // The single most common way to produce a confidently wrong chart.
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1)
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1', 's2'])
          .answering(skill: 's1', correct: 0, wrong: 1)
          .answering(skill: 's2', correct: 3, wrong: 3)
          .build();

      final ranked = mostMissedConcepts(rows: rows, classId: 'c1', limit: 5, thresholds: t);

      expect(ranked.map((ConceptRank r) => r.microSkillId), <String>['s2']);
    });

    test('the limit is honoured', () {
      final builder = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 2)
          .withChapter(
            id: 'ch1',
            title: 'Quadratics',
            skills: <String>['s1', 's2', 's3', 's4'],
          );
      for (final String skill in <String>['s1', 's2', 's3', 's4']) {
        builder.answering(skill: skill, correct: 2, wrong: 3);
      }

      expect(
        mostMissedConcepts(rows: builder.build(), classId: 'c1', limit: 2, thresholds: t),
        hasLength(2),
      );
    });
  });

  group('topStruggleTags', () {
    test('returns the three weakest skills for one student', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(
            id: 'ch1', title: 'Quadratics',
            skills: <String>['s1', 's2', 's3', 's4'],
          )
          .answering(skill: 's1', correct: 0, wrong: 4)
          .answering(skill: 's2', correct: 1, wrong: 3)
          .answering(skill: 's3', correct: 2, wrong: 2)
          .answering(skill: 's4', correct: 4, wrong: 0)
          .build();

      final tags = topStruggleTags(
        rows: rows,
        weaknesses: const <WeaknessRow>[],
        studentId: 'stu-0',
        limit: 3,
      );

      expect(tags.map((ConceptRank r) => r.microSkillId).toList(),
          <String>['s1', 's2', 's3']);
    });

    test('an exam-sourced weakness surfaces with no quiz history at all', () {
      // Requirement: an uploaded exam paper must improve the teacher's picture,
      // not only the student's practice.
      final tags = topStruggleTags(
        rows: const <AnalyticRow>[],
        weaknesses: const <WeaknessRow>[
          WeaknessRow(
            studentId: 'stu-0', microSkillId: 's9',
            weight: 0.9, source: 'exam',
          ),
        ],
        studentId: 'stu-0',
        limit: 3,
      );

      expect(tags, hasLength(1));
      expect(tags.single.microSkillId, 's9');
      expect(tags.single.source, 'exam');
    });

    test('a prep-mode-only mistake does not surface as a struggle tag', () {
      // Requirement 25, applied consistently: a student exploring ahead in
      // prep mode must not be penalised in their own struggle tags either.
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 1, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 0, wrong: 4, mode: 'prep')
          .build();

      final tags = topStruggleTags(
        rows: rows,
        weaknesses: const <WeaknessRow>[
          WeaknessRow(studentId: 'stu-0', microSkillId: 's9', weight: 0.9, source: 'exam'),
        ],
        studentId: 'stu-0',
        limit: 3,
      );

      // The prep-mode quiz mistake is filtered out; the exam-sourced
      // weakness (no mode field) still surfaces.
      expect(tags, hasLength(1));
      expect(tags.single.microSkillId, 's9');
    });

    test('another student\'s rows never appear', () {
      final rows = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withStudents(count: 3, idPrefix: 'stu')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1'])
          .answering(skill: 's1', correct: 0, wrong: 4)
          .build();

      final tags = topStruggleTags(
        rows: rows, weaknesses: const <WeaknessRow>[],
        studentId: 'stu-1', limit: 3,
      );

      expect(tags.single.total, 4, reason: 'only this student\'s four items');
    });
  });
}
