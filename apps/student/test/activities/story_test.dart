import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_student/activities/content_models.dart';
import 'package:syncedu_student/activities/story/story_screen.dart';

Story _story({String mode = 'revise'}) => Story(
      title: 'The Cell',
      concepts: const <String>['Nucleus', 'Mitochondria'],
      mode: mode,
      scenes: const <StoryScene>[
        StoryScene(caption: 'Scene one', description: 'A long description one.'),
        StoryScene(caption: 'Scene two', description: 'A long description two.'),
        StoryScene(caption: 'Scene three', description: 'A long description three.'),
      ],
    );

Widget _host(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('a story renders as scenes with a caption each', (tester) async {
    await tester.pumpWidget(_host(StoryScreen(story: _story())));
    expect(find.text('Scene one'), findsOneWidget);
    expect(find.text('A long description one.'), findsOneWidget);
    expect(find.text('Scene 1 of 3'), findsOneWidget);
  });

  testWidgets('scenes are navigable forwards and backwards', (tester) async {
    await tester.pumpWidget(_host(StoryScreen(story: _story())));
    await tester.tap(find.byKey(const Key('story-next')));
    await tester.pump();
    expect(find.text('Scene two'), findsOneWidget);

    await tester.tap(find.byKey(const Key('story-back')));
    await tester.pump();
    expect(find.text('Scene one'), findsOneWidget);
  });

  testWidgets('the story names the chapter concepts it teaches', (tester) async {
    await tester.pumpWidget(_host(StoryScreen(story: _story())));
    expect(find.widgetWithText(Chip, 'Nucleus'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Mitochondria'), findsOneWidget);
  });

  testWidgets('prep-mode stories are framed more gently than revision ones',
      (tester) async {
    await tester.pumpWidget(_host(StoryScreen(story: _story(mode: 'prep'))));
    expect(find.textContaining('no need to know this yet'), findsOneWidget);

    await tester.pumpWidget(_host(StoryScreen(story: _story())));
    expect(find.textContaining('revision retelling'), findsOneWidget);
  });

  testWidgets('the UI says it is words, not pictures', (tester) async {
    await tester.pumpWidget(_host(StoryScreen(story: _story())));
    expect(find.textContaining('not pictures'), findsOneWidget);
  });
}
