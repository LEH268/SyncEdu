import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/teacher/analytics/mastery_heatmap.dart';
import 'package:syncedu_console/teacher/analytics/most_missed_panel.dart';
import 'package:syncedu_core/syncedu_core.dart';

MasteryCell _cell({
  required String chapterId,
  required String chapterTitle,
  required int correct,
  required int total,
  required double accuracy,
  required MasteryBand band,
  List<SkillCell> skills = const <SkillCell>[],
}) {
  return MasteryCell(
    chapterId: chapterId,
    chapterTitle: chapterTitle,
    correct: correct,
    total: total,
    accuracy: accuracy,
    band: band,
    skills: skills,
  );
}

void main() {
  testWidgets('renders one row per chapter with its band colour',
      (tester) async {
    final cells = <MasteryCell>[
      _cell(
        chapterId: 'c1',
        chapterTitle: 'Fractions',
        correct: 8,
        total: 10,
        accuracy: 0.8,
        band: MasteryBand.green,
      ),
      _cell(
        chapterId: 'c2',
        chapterTitle: 'Algebra',
        correct: 3,
        total: 10,
        accuracy: 0.3,
        band: MasteryBand.red,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MasteryHeatmap(cells: cells))),
    );

    expect(find.text('Fractions'), findsOneWidget);
    expect(find.text('Algebra'), findsOneWidget);

    final BuildContext context = tester.element(find.text('Fractions'));
    final ThemeData theme = Theme.of(context);

    final Container greenContainer = tester.widget<Container>(
      find.byKey(const Key('mastery-band-c1')),
    );
    final Container redContainer = tester.widget<Container>(
      find.byKey(const Key('mastery-band-c2')),
    );
    expect(greenContainer.color, isNot(redContainer.color));
    expect(redContainer.color, theme.colorScheme.error);
  });

  testWidgets('an insufficient-sample cell reads as "not enough data", not as red',
      (tester) async {
    final cells = <MasteryCell>[
      _cell(
        chapterId: 'c1',
        chapterTitle: 'Geometry',
        correct: 1,
        total: 2,
        accuracy: 0.5,
        band: MasteryBand.insufficient,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MasteryHeatmap(cells: cells))),
    );

    final BuildContext context = tester.element(find.text('Geometry'));
    final ThemeData theme = Theme.of(context);

    expect(find.text('Not enough data'), findsOneWidget);
    final Container container = tester.widget<Container>(
      find.byKey(const Key('mastery-band-c1')),
    );
    expect(container.color, isNot(theme.colorScheme.error));
  });

  testWidgets('expanding a chapter reveals its micro-skills', (tester) async {
    final cells = <MasteryCell>[
      _cell(
        chapterId: 'c1',
        chapterTitle: 'Fractions',
        correct: 8,
        total: 10,
        accuracy: 0.8,
        band: MasteryBand.green,
        skills: const <SkillCell>[
          SkillCell(
            microSkillId: 's1',
            microSkillLabel: 'Adding fractions',
            correct: 4,
            total: 5,
            accuracy: 0.8,
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MasteryHeatmap(cells: cells))),
    );

    expect(find.text('Adding fractions'), findsNothing);

    await tester.tap(find.text('Fractions'));
    await tester.pumpAndSettle();

    expect(find.text('Adding fractions'), findsOneWidget);
  });

  testWidgets('the band legend states the thresholds numerically',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MasteryHeatmap(cells: <MasteryCell>[])),
      ),
    );

    expect(find.textContaining('75%'), findsOneWidget);
    expect(find.textContaining('50%'), findsOneWidget);
  });

  testWidgets('most-missed shows the sample size beside each rate',
      (tester) async {
    final ranked = <ConceptRank>[
      const ConceptRank(
        microSkillId: 's1',
        microSkillLabel: 'Long division',
        errorRate: 0.6,
        total: 12,
        source: 'quiz',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MostMissedPanel(ranked: ranked))),
    );

    expect(find.text('Long division'), findsOneWidget);
    expect(find.textContaining('60%'), findsOneWidget);
    expect(find.textContaining('12'), findsOneWidget);
  });

  testWidgets('an empty class shows guidance rather than an empty grid',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MasteryHeatmap(cells: <MasteryCell>[])),
      ),
    );

    expect(find.textContaining('No mastery data'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MostMissedPanel(ranked: <ConceptRank>[])),
      ),
    );

    expect(find.textContaining('No missed concepts'), findsOneWidget);
  });

  testWidgets('the heatmap is horizontally scrollable rather than overflowing',
      (tester) async {
    final cells = List<MasteryCell>.generate(
      20,
      (int i) => _cell(
        chapterId: 'c$i',
        chapterTitle: 'Chapter number $i with a very long title indeed',
        correct: 5,
        total: 10,
        accuracy: 0.5,
        band: MasteryBand.amber,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MasteryHeatmap(cells: cells))),
    );

    final Finder scrollable = find.byWidgetPredicate(
      (Widget widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    expect(scrollable, findsOneWidget);
  });
}
