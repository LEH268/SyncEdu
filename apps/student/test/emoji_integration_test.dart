import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:syncedu_student/quiz/quiz_controller.dart';
import 'package:syncedu_student/quiz/quiz_runner.dart';
import 'package:syncedu_student/shells/home_shell.dart';
import 'package:syncedu_student/widgets/emoji_app_bar.dart';
import 'package:syncedu_student/widgets/emoji_scope.dart';

PoolQuestion _q(String id, {int correct = 0}) => PoolQuestion(
      id: id,
      chapterId: 'ch1',
      microSkillId: 's1',
      difficulty: 2,
      stem: 'Stem $id',
      options: const <String>['a', 'b', 'c', 'd'],
      correctIndex: correct,
      provenance: 'pool',
    );

Widget _scoped(Widget child) => MaterialApp(home: EmojiScope(child: child));

void main() {
  testWidgets('the home shell shows the character full size', (tester) async {
    final gateway = FakeAuthGateway(
      initial: const SessionClaims(
          userId: 'u', schoolId: 's', role: UserRole.student),
    );
    addTearDown(gateway.dispose);

    await tester.pumpWidget(_scoped(HomeShell(gateway: gateway)));
    await tester.pump();

    final AiEmoji emoji = tester.widget<AiEmoji>(find.byType(AiEmoji));
    expect(emoji.size, 200);
  });

  testWidgets('during a quiz the character shrinks into the app bar',
      (tester) async {
    final controller =
        QuizController.forTesting(questions: <PoolQuestion>[_q('q1')]);

    await tester.pumpWidget(_scoped(QuizRunner(controller: controller)));
    await tester.pump();

    expect(find.byType(EmojiAppBar), findsOneWidget);
    final AiEmoji emoji = tester.widget<AiEmoji>(
      find.descendant(of: find.byType(EmojiAppBar), matching: find.byType(AiEmoji)),
    );
    expect(emoji.size, 28);
  });

  testWidgets('a correct answer drives happy, a wrong answer drives confused',
      (tester) async {
    final controller = QuizController.forTesting(
      questions: <PoolQuestion>[_q('q1', correct: 0), _q('q2', correct: 1)],
    );
    late EmojiController emoji;

    await tester.pumpWidget(
      MaterialApp(
        home: EmojiScope(
          child: Builder(builder: (BuildContext context) {
            emoji = EmojiScope.of(context);
            return QuizRunner(controller: controller);
          }),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('a')); // correct for q1
    await tester.pump();
    expect(emoji.state, EmojiState.happy);

    await tester.tap(find.text('a')); // wrong for q2 (correct is 'b')
    await tester.pump();
    expect(emoji.state, EmojiState.confused);
  });

  testWidgets('one controller is shared across surfaces', (tester) async {
    final List<EmojiController> seen = <EmojiController>[];

    await tester.pumpWidget(
      MaterialApp(
        home: EmojiScope(
          child: Column(
            children: <Widget>[
              Builder(builder: (BuildContext c) {
                seen.add(EmojiScope.of(c));
                return const SizedBox();
              }),
              Builder(builder: (BuildContext c) {
                seen.add(EmojiScope.of(c));
                return const SizedBox();
              }),
            ],
          ),
        ),
      ),
    );

    expect(identical(seen[0], seen[1]), isTrue);
  });

  testWidgets('the app bar degrades to a plain bar with no EmojiScope',
      (tester) async {
    final controller =
        QuizController.forTesting(questions: <PoolQuestion>[_q('q1')]);
    await tester.pumpWidget(MaterialApp(home: QuizRunner(controller: controller)));
    await tester.pump();

    expect(find.byType(AiEmoji), findsNothing);
    expect(find.text('1 of 1'), findsOneWidget);
  });
}
