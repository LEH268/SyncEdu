import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_student/activities/activity_loader.dart';
import 'package:syncedu_student/activities/content_models.dart';
import 'package:syncedu_student/activities/flashcards/flashcard_deck_screen.dart';
import 'package:syncedu_student/activities/readable.dart';

FlashcardDeck _deck() => FlashcardDeck(<Flashcard>[
      for (int i = 0; i < 18; i++)
        Flashcard(front: 'Front $i', back: 'Back $i', concept: 'Concept $i'),
    ]);

Widget _host(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('a card flips to reveal its back', (tester) async {
    await tester.pumpWidget(_host(FlashcardDeckScreen(deck: _deck())));
    expect(find.text('Front 0'), findsOneWidget);
    expect(find.text('Back 0'), findsNothing);

    await tester.tap(find.byKey(const Key('flashcard-0')));
    await tester.pump();
    expect(find.text('Back 0'), findsOneWidget);
  });

  testWidgets('swiping advances through the deck and position is reported',
      (tester) async {
    await tester.pumpWidget(_host(FlashcardDeckScreen(deck: _deck())));
    expect(find.text('Card 1 of 18'), findsOneWidget);

    await tester.fling(find.byKey(const Key('flashcard-0')), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Card 2 of 18'), findsOneWidget);
  });

  testWidgets('each card names the concept it covers', (tester) async {
    await tester.pumpWidget(_host(FlashcardDeckScreen(deck: _deck())));
    expect(find.byKey(const Key('flashcard-concept-0')), findsOneWidget);
    expect(find.text('Concept 0'), findsOneWidget);
  });

  testWidgets('a dyslexia label substitutes the readable typeface',
      (tester) async {
    await tester.pumpWidget(_host(FlashcardDeckScreen(
      deck: _deck(),
      specialNeeds: const <String>['Dyslexia'],
    )));
    final BuildContext ctx = tester.element(find.text('Front 0'));
    expect(Theme.of(ctx).textTheme.bodyLarge?.fontFamily, kReadableFontFamily);
  });

  testWidgets('with no repository, the loader explains rather than spinning',
      (tester) async {
    await tester.pumpWidget(_host(ActivityLoader(
      repository: null,
      chapterOrdinal: 1,
      kind: ContentKind.flashcards,
      builder: (_, _, _) => const SizedBox.shrink(),
    )));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('online'), findsOneWidget);
  });
}
