import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

const AnalyticsThresholds t = AnalyticsThresholds.standard();

/// One class's worth of rows on chapter `ch1`, skill `s1`, built with the
/// shared fixture builder. Two of these concatenated give the cross-class
/// shape the teaching review exists to read, which a single builder (one
/// class per instance) cannot express on its own.
List<AnalyticRow> classRows({
  required String classId,
  required String className,
  required int struggling,
  required int fine,
  String skill = 's1',
}) {
  final FixtureBuilder builder = FixtureBuilder(seed: 1)
      .withClass(id: classId, name: className)
      .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>[skill]);
  for (int i = 0; i < struggling; i++) {
    builder.withStudentAnswering(
        studentId: '$classId-w$i', skill: skill, correct: 0, wrong: 6);
  }
  for (int i = 0; i < fine; i++) {
    builder.withStudentAnswering(
        studentId: '$classId-r$i', skill: skill, correct: 6, wrong: 0);
  }
  return builder.build();
}

void main() {
  group('reviewTeaching', () {
    test('flags a skill on exactly the resource-recommendation bar', () {
      // 4 of 10 struggling: 40%, the bar itself.
      final List<AnalyticRow> rows =
          classRows(classId: 'c1', className: '4 Amanah', struggling: 4, fine: 6);

      final TeachingReview review =
          reviewTeaching(rows: rows, classId: 'c1', chapterId: 'ch1', thresholds: t);

      expect(review.signals, hasLength(1));
      final TeachingSignal signal = review.signals.single;
      expect(signal.microSkillId, 's1');
      expect(signal.proportion, closeTo(0.4, 0.001));
      expect(signal.affectedCount, 4);
      expect(signal.studentsAssessed, 10);
      expect(signal.classSize, 10);
      expect(review.hasFindings, isTrue);
    });

    test('does not fire just below the bar', () {
      // 7 of 18 is ~38.9%, the tightest clean-integer miss.
      final List<AnalyticRow> rows = classRows(
          classId: 'c1', className: '4 Amanah', struggling: 7, fine: 11);

      final TeachingReview review =
          reviewTeaching(rows: rows, classId: 'c1', chapterId: 'ch1', thresholds: t);

      expect(review.signals, isEmpty);
      expect(review.ruleHeadline, contains('Nothing here suggests'));
    });

    test('a handful of assessed students is not a class-wide signal', () {
      // 4 assessed, all struggling: 100%, but below the minimum class size,
      // so it says something about those four students, not the material.
      final List<AnalyticRow> rows =
          classRows(classId: 'c1', className: '4 Amanah', struggling: 4, fine: 0);

      final TeachingReview review =
          reviewTeaching(rows: rows, classId: 'c1', chapterId: 'ch1', thresholds: t);

      expect(review.signals, isEmpty);
    });

    test('a student below the per-student item floor is not counted at all',
        () {
      final FixtureBuilder builder = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);
      for (int i = 0; i < 5; i++) {
        builder.withStudentAnswering(
            studentId: 'w$i', skill: 's1', correct: 0, wrong: 6);
      }
      for (int i = 0; i < 5; i++) {
        builder.withStudentAnswering(
            studentId: 'r$i', skill: 's1', correct: 6, wrong: 0);
      }
      // Two students with a single wrong answer each: below the 3-item floor,
      // so they must move neither the numerator nor the denominator.
      builder.withStudentAnswering(
          studentId: 'thin1', skill: 's1', correct: 0, wrong: 1);
      builder.withStudentAnswering(
          studentId: 'thin2', skill: 's1', correct: 0, wrong: 1);

      final TeachingReview review = reviewTeaching(
          rows: builder.build(), classId: 'c1', chapterId: 'ch1', thresholds: t);

      expect(review.signals.single.studentsAssessed, 10);
      expect(review.signals.single.affectedCount, 5);
      // classSize counts everyone in the class, assessed or not.
      expect(review.signals.single.classSize, 12);
    });

    test('prep-mode practice is invisible to the teacher-facing review', () {
      final FixtureBuilder builder = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch1', title: 'Quadratics', skills: <String>['s1']);
      for (int i = 0; i < 10; i++) {
        builder.withStudentAnswering(
            studentId: 'p$i', skill: 's1', correct: 0, wrong: 6, mode: 'prep');
      }

      final TeachingReview review = reviewTeaching(
          rows: builder.build(), classId: 'c1', chapterId: 'ch1', thresholds: t);

      expect(review.signals, isEmpty);
      expect(review.chapterAccuracy, isNull);
    });

    test('rows from another chapter never leak into the review', () {
      final List<AnalyticRow> mine =
          classRows(classId: 'c1', className: '4 Amanah', struggling: 4, fine: 6);
      final FixtureBuilder other = FixtureBuilder(seed: 1)
          .withClass(id: 'c1', name: '4 Amanah')
          .withChapter(id: 'ch2', title: 'Trigonometry', skills: <String>['s9']);
      for (int i = 0; i < 10; i++) {
        other.withStudentAnswering(
            studentId: 'x$i', skill: 's9', correct: 0, wrong: 6);
      }

      final TeachingReview review = reviewTeaching(
        rows: <AnalyticRow>[...mine, ...other.build()],
        classId: 'c1',
        chapterId: 'ch1',
        thresholds: t,
      );

      expect(review.signals.map((TeachingSignal s) => s.microSkillId), <String>['s1']);
      expect(review.chapterTitle, 'Quadratics');
    });
  });

  group('the cross-class comparison', () {
    test('a skill failing in the other classes too is material-wide', () {
      final List<AnalyticRow> rows = <AnalyticRow>[
        ...classRows(classId: 'c1', className: '4 Amanah', struggling: 6, fine: 4),
        ...classRows(classId: 'c2', className: '4 Bestari', struggling: 5, fine: 5),
      ];

      final TeachingSignal signal = reviewTeaching(
              rows: rows, classId: 'c1', chapterId: 'ch1', thresholds: t)
          .signals
          .single;

      expect(signal.scope, TeachingScope.materialWide);
      expect(signal.cohortProportion, closeTo(0.5, 0.001));
      expect(signal.cohortStudentsAssessed, 10);
      expect(signal.cohortClassCount, 1);
      expect(signal.sentence, contains('fails wherever it is taught'));
    });

    test('a skill the other classes handle is specific to this class', () {
      final List<AnalyticRow> rows = <AnalyticRow>[
        ...classRows(classId: 'c1', className: '4 Amanah', struggling: 6, fine: 4),
        ...classRows(classId: 'c2', className: '4 Bestari', struggling: 1, fine: 9),
        ...classRows(classId: 'c3', className: '4 Cekap', struggling: 0, fine: 10),
      ];

      final TeachingSignal signal = reviewTeaching(
              rows: rows, classId: 'c1', chapterId: 'ch1', thresholds: t)
          .signals
          .single;

      expect(signal.scope, TeachingScope.classSpecific);
      expect(signal.cohortProportion, closeTo(0.05, 0.001));
      expect(signal.cohortClassCount, 2);
      expect(signal.sentence, contains('specific to this class'));
    });

    test('too few assessed students elsewhere refuses to claim either way',
        () {
      final List<AnalyticRow> rows = <AnalyticRow>[
        ...classRows(classId: 'c1', className: '4 Amanah', struggling: 6, fine: 4),
        // Only 3 assessed in the comparison pool: below the minimum, so the
        // review must not read "the other class is fine" into it.
        ...classRows(classId: 'c2', className: '4 Bestari', struggling: 0, fine: 3),
      ];

      final TeachingSignal signal = reviewTeaching(
              rows: rows, classId: 'c1', chapterId: 'ch1', thresholds: t)
          .signals
          .single;

      expect(signal.scope, TeachingScope.insufficientComparison);
      expect(signal.cohortProportion, isNull);
      expect(signal.sentence, contains('No other class of yours'));
    });

    test('material-wide findings sort ahead of class-specific ones', () {
      final List<AnalyticRow> rows = <AnalyticRow>[
        // s1 fails here and elsewhere; s2 fails harder, but only here.
        ...classRows(
            classId: 'c1', className: '4 Amanah', struggling: 5, fine: 5, skill: 's1'),
        ...classRows(
            classId: 'c1', className: '4 Amanah', struggling: 9, fine: 1, skill: 's2'),
        ...classRows(
            classId: 'c2', className: '4 Bestari', struggling: 6, fine: 4, skill: 's1'),
        ...classRows(
            classId: 'c2', className: '4 Bestari', struggling: 0, fine: 10, skill: 's2'),
      ];

      final TeachingReview review =
          reviewTeaching(rows: rows, classId: 'c1', chapterId: 'ch1', thresholds: t);

      expect(review.signals.map((TeachingSignal s) => s.microSkillId),
          <String>['s1', 's2']);
      expect(review.materialWideCount, 1);
      expect(review.ruleHeadline, contains('1 of 2 flagged'));
      expect(review.ruleHeadline, contains('presentation problem'));
    });

    test('a classless student is excluded from the comparison pool', () {
      final List<AnalyticRow> rows = <AnalyticRow>[
        ...classRows(classId: 'c1', className: '4 Amanah', struggling: 6, fine: 4),
        // classId '' is how the repository renders a student with no class.
        ...classRows(classId: '', className: '', struggling: 6, fine: 4),
      ];

      final TeachingSignal signal = reviewTeaching(
              rows: rows, classId: 'c1', chapterId: 'ch1', thresholds: t)
          .signals
          .single;

      expect(signal.scope, TeachingScope.insufficientComparison);
      expect(signal.cohortStudentsAssessed, 0);
    });
  });

  group('misconceptions', () {
    const Map<String, QuestionText> questions = <String, QuestionText>{
      'q1': QuestionText(
        stem: 'Solve x^2 - 5x + 6 = 0',
        options: <String>['x = 2 or 3', 'x = -2 or -3', 'x = 5', 'x = 6'],
        correctIndex: 0,
      ),
    };

    test('counts distinct students per wrong option, not answers', () {
      final List<WrongAnswerRow> answers = <WrongAnswerRow>[
        // One student picking the same distractor three times is one student.
        const WrongAnswerRow(
            studentId: 'a', questionId: 'q1', microSkillId: 's1', selectedIndex: 1),
        const WrongAnswerRow(
            studentId: 'a', questionId: 'q1', microSkillId: 's1', selectedIndex: 1),
        const WrongAnswerRow(
            studentId: 'a', questionId: 'q1', microSkillId: 's1', selectedIndex: 1),
        const WrongAnswerRow(
            studentId: 'b', questionId: 'q1', microSkillId: 's1', selectedIndex: 1),
        const WrongAnswerRow(
            studentId: 'c', questionId: 'q1', microSkillId: 's1', selectedIndex: 2),
      ];

      final List<Misconception> found = misconceptionsFor(
          microSkillId: 's1', answers: answers, questions: questions);

      expect(found, hasLength(2));
      expect(found.first.optionIndex, 1);
      expect(found.first.optionText, 'x = -2 or -3');
      expect(found.first.studentCount, 2);
      expect(found.last.studentCount, 1);
    });

    test('a blank answer and an unknown question are both dropped', () {
      final List<WrongAnswerRow> answers = <WrongAnswerRow>[
        const WrongAnswerRow(
            studentId: 'a', questionId: 'q1', microSkillId: 's1', selectedIndex: null),
        const WrongAnswerRow(
            studentId: 'b', questionId: 'gone', microSkillId: 's1', selectedIndex: 1),
        const WrongAnswerRow(
            studentId: 'c', questionId: 'q1', microSkillId: 's2', selectedIndex: 1),
      ];

      expect(
        misconceptionsFor(
            microSkillId: 's1', answers: answers, questions: questions),
        isEmpty,
      );
    });

    test('an out-of-range option index is dropped rather than rendered', () {
      final List<WrongAnswerRow> answers = <WrongAnswerRow>[
        const WrongAnswerRow(
            studentId: 'a', questionId: 'q1', microSkillId: 's1', selectedIndex: 9),
      ];

      expect(
        misconceptionsFor(
            microSkillId: 's1', answers: answers, questions: questions),
        isEmpty,
      );
    });

    test('the review attaches them to the signal they explain', () {
      final List<AnalyticRow> rows =
          classRows(classId: 'c1', className: '4 Amanah', struggling: 6, fine: 4);
      final List<WrongAnswerRow> answers = <WrongAnswerRow>[
        for (int i = 0; i < 4; i++)
          WrongAnswerRow(
              studentId: 'c1-w$i',
              questionId: 'q1',
              microSkillId: 's1',
              selectedIndex: 1),
      ];

      final TeachingSignal signal = reviewTeaching(
        rows: rows,
        classId: 'c1',
        chapterId: 'ch1',
        wrongAnswers: answers,
        questions: questions,
        thresholds: t,
      ).signals.single;

      expect(signal.misconceptions.single.studentCount, 4);
      expect(signal.misconceptions.single.optionText, 'x = -2 or -3');
    });
  });
}
