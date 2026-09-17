import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_student/quiz/quiz_controller.dart';
import 'package:syncedu_student/quiz/quiz_result.dart';
import 'package:syncedu_student/quiz/quiz_runner.dart';
import 'package:syncedu_student/quiz/targeted_notes.dart';

PoolQuestion q(String id, String skill, {int correct = 0}) => PoolQuestion(
      id: id,
      chapterId: 'ch1',
      microSkillId: skill,
      difficulty: 2,
      stem: 'Stem $id',
      options: const <String>['a', 'b', 'c', 'd'],
      correctIndex: correct,
      provenance: 'pool',
    );

void main() {
  group('QuizRunner', () {
    testWidgets('shows one question at a time and advances on answer',
        (tester) async {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1'), q('q2', 's2')],
      );

      await tester.pumpWidget(
        MaterialApp(home: QuizRunner(controller: controller)),
      );

      expect(find.text('Stem q1'), findsOneWidget);
      expect(find.text('Stem q2'), findsNothing);

      await tester.tap(find.text('a'));
      await tester.pumpAndSettle();

      expect(find.text('Stem q2'), findsOneWidget);
    });

    testWidgets('onComplete fires once even when the controller notifies again',
        (tester) async {
      // `onComplete` is scheduled from build(); a notify in that window used
      // to re-enter submit() and record the same answers as a "retry".
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1')],
      )..answer(3);

      int completions = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: QuizRunner(
            controller: controller,
            onComplete: () async {
              completions++;
              await controller.submit();
            },
          ),
        ),
      );
      await tester.pump();
      expect(completions, 1);
      expect(controller.isSubmitted, isTrue);

      await controller.generateNotes(); // notifies -> rebuild
      await tester.pumpAndSettle();

      expect(completions, 1,
          reason: 'a rebuild must not schedule a second submit');
    });

    testWidgets('an empty quiz says so instead of scoring 0 of 0',
        (tester) async {
      // question_count > 0 server-side, so an empty attempt could never sync.
      final controller =
          QuizController.forTesting(questions: <PoolQuestion>[]);

      int completions = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: QuizRunner(
            controller: controller,
            onComplete: () => completions++,
            onNewRange: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nothing to practise'), findsOneWidget);
      expect(find.byKey(const Key('empty-new-range')), findsOneWidget);
      expect(completions, 0, reason: 'nothing was answered, so nothing scores');
    });

    testWidgets('progress reflects position', (tester) async {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1'), q('q2', 's2'), q('q3', 's3')],
      );
      await tester.pumpWidget(
        MaterialApp(home: QuizRunner(controller: controller)),
      );
      expect(find.text('1 of 3'), findsOneWidget);
    });
  });

  group('QuizResult', () {
    testWidgets('shows the score and which concept each question tested',
        (tester) async {
      // Requirement 15: a student should know *what* to work on, not merely
      // that they were wrong.
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1'), q('q2', 's2')],
        labels: <String, String>{'s1': 'Factorising', 's2': 'The formula'},
      )
        ..answer(0)
        ..answer(3);

      await tester.pumpWidget(
        MaterialApp(home: QuizResult(controller: controller)),
      );

      expect(find.textContaining('1'), findsWidgets);
      expect(find.text('Factorising'), findsOneWidget);
      expect(find.text('The formula'), findsOneWidget);
    });

    testWidgets('offers all four follow-ups', (tester) async {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1')],
      )..answer(3);

      await tester.pumpWidget(
        MaterialApp(home: QuizResult(controller: controller)),
      );

      expect(find.byKey(const Key('option-regenerate')), findsOneWidget);
      expect(find.byKey(const Key('option-practise-mistakes')), findsOneWidget);
      expect(find.byKey(const Key('option-new-range')), findsOneWidget);
      expect(find.byKey(const Key('option-notes')), findsOneWidget);
    });

    testWidgets('on a perfect score option 2 becomes harder questions',
        (tester) async {
      // Requirement 19: the option is never a dead end.
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1'), q('q2', 's2')],
      )
        ..answer(0)
        ..answer(0);

      await tester.pumpWidget(
        MaterialApp(home: QuizResult(controller: controller)),
      );

      expect(find.text('Harder questions'), findsOneWidget);
      expect(find.text('Practise what I got wrong'), findsNothing);
    });

    testWidgets('below a perfect score option 2 is the mistakes option',
        (tester) async {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1'), q('q2', 's2')],
      )
        ..answer(0)
        ..answer(3);

      await tester.pumpWidget(
        MaterialApp(home: QuizResult(controller: controller)),
      );

      expect(find.text('Practise what I got wrong'), findsOneWidget);
    });

    testWidgets('a relaxed seen set is disclosed rather than hidden',
        (tester) async {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1')],
        relaxedSeenSet: true,
      )..answer(0);

      await tester.pumpWidget(
        MaterialApp(home: QuizResult(controller: controller)),
      );

      expect(find.textContaining('seen before'), findsOneWidget);
    });

    testWidgets('every follow-up reports its tap to the router',
        (tester) async {
      // Two of the four used to call the controller and then a null callback,
      // leaving the student on the results screen looking at a silently
      // reassembled quiz with no answers.
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1'), q('q2', 's2')],
      )
        ..answer(3)
        ..answer(3);

      final List<String> taps = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResult(
            controller: controller,
            onRegenerate: () => taps.add('regenerate'),
            onPractiseMistakes: () => taps.add('practise'),
            onNewRange: () => taps.add('range'),
            onNotes: () => taps.add('notes'),
          ),
        ),
      );

      for (final String key in <String>[
        'option-regenerate',
        'option-practise-mistakes',
        'option-new-range',
        'option-notes',
      ]) {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
      }

      expect(taps, <String>['regenerate', 'practise', 'range', 'notes']);
    });
  });

  group('TargetedNotes', () {
    testWidgets('each explanation sits under its own micro-skill',
        (tester) async {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1'), q('q2', 's2')],
        labels: <String, String>{'s1': 'Factorising', 's2': 'The formula'},
      )
        ..answer(3)
        ..answer(3);
      await controller.generateNotes();

      await tester.pumpWidget(
        MaterialApp(home: TargetedNotes(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('## Factorising'), findsOneWidget);
      expect(find.text('## The formula'), findsOneWidget);
      expect(find.text('Notes on Factorising.'), findsOneWidget);
      expect(find.text('Notes on The formula.'), findsOneWidget);
    });

    testWidgets('a skill with nothing on file says so rather than borrowing',
        (tester) async {
      // Keyed lookup, not a positional zip: a skill with no explanation must
      // not display the next skill's body.
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1')],
        labels: <String, String>{'s1': 'Factorising'},
      )..answer(3);

      await tester.pumpWidget(
        MaterialApp(home: TargetedNotes(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('## Factorising'), findsOneWidget);
      expect(find.textContaining('No notes on file'), findsOneWidget);
    });

    testWidgets('a perfect score has nothing to explain', (tester) async {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1')],
      )..answer(0);

      await tester.pumpWidget(
        MaterialApp(home: TargetedNotes(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notes for a perfect score.'), findsOneWidget);
    });
  });

  group('QuizController', () {
    test('missed micro-skills are exactly those answered incorrectly', () {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[
          q('q1', 's1'),
          q('q2', 's2'),
          q('q3', 's1'),
        ],
      )
        ..answer(3)
        ..answer(0)
        ..answer(3);

      expect(controller.missedMicroSkills, <String>{'s1'});
    });

    test('a perfect score yields no missed skills', () {
      final controller = QuizController.forTesting(
        questions: <PoolQuestion>[q('q1', 's1'), q('q2', 's2')],
      )
        ..answer(0)
        ..answer(0);

      expect(controller.missedMicroSkills, isEmpty);
      expect(controller.isPerfect, isTrue);
    });
  });
}
