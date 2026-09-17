import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/teacher/analytics/ai_summary_panel.dart';

void main() {
  testWidgets('shows the cached summary when offline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSummaryPanel(
            cachedSummary: 'Last week: strong on Fractions, weak on Algebra.',
            generate: () async => throw Exception('offline'),
          ),
        ),
      ),
    );

    // Cached summary shows immediately, before the (failing) refresh settles.
    expect(
      find.text('Last week: strong on Fractions, weak on Algebra.'),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    // Still shows the cached text after the failed refresh completes, plus a
    // notice that it could not be refreshed.
    expect(
      find.text('Last week: strong on Fractions, weak on Algebra.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ai-summary-stale-notice')), findsOneWidget);
    expect(find.byKey(const Key('ai-summary-unavailable')), findsNothing);
  });

  testWidgets(
    'a failed call leaves the chart usable and says the summary is unavailable',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                const Text('Mastery Heatmap'), // stands in for the real chart
                AiSummaryPanel(
                  generate: () async => throw Exception('boom'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The chart above keeps rendering; no exception propagated up.
      expect(find.text('Mastery Heatmap'), findsOneWidget);
      expect(tester.takeException(), isNull);

      expect(find.byKey(const Key('ai-summary-unavailable')), findsOneWidget);
    },
  );

  testWidgets('the summary is labelled as generated', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiSummaryPanel(
            generate: () async =>
                'This class is strongest on Fractions and weakest on Algebra.',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-summary-label')), findsOneWidget);
    expect(find.text('AI-generated summary'), findsOneWidget);
    expect(
      find.text('This class is strongest on Fractions and weakest on Algebra.'),
      findsOneWidget,
    );
  });
}
