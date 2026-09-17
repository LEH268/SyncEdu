import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_console/admin/risk/recommendation_panel.dart';

void main() {
  const AnalyticsThresholds thresholds = AnalyticsThresholds.standard();

  const ResourceRecommendation top = ResourceRecommendation(
    classId: 'c1',
    className: 'Form 4A',
    subjectName: 'Mathematics',
    microSkillId: 's1',
    microSkillLabel: 'Factorising quadratics',
    proportion: 0.4,
    affectedCount: 4,
    studentsAssessed: 10,
    classSize: 12,
    rank: 1.6,
  );

  const ResourceRecommendation second = ResourceRecommendation(
    classId: 'c2',
    className: 'Form 4B',
    subjectName: 'Mathematics',
    microSkillId: 's2',
    microSkillLabel: 'Simultaneous equations',
    proportion: 0.5,
    affectedCount: 3,
    studentsAssessed: 6,
    classSize: 8,
    rank: 1.5,
  );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the sentence from the structure', (tester) async {
    await tester.pumpWidget(
      wrap(RecommendationPanel(recommendations: [top], thresholds: thresholds)),
    );

    expect(find.text(top.sentence), findsOneWidget);
  });

  testWidgets('shows the rule that fired, in words, beside the recommendation', (tester) async {
    await tester.pumpWidget(
      wrap(RecommendationPanel(recommendations: [top], thresholds: thresholds)),
    );

    expect(find.textContaining('40%'), findsWidgets);
    expect(find.textContaining('at least 5'), findsOneWidget);
  });

  testWidgets('shows the counts the rule fired on', (tester) async {
    await tester.pumpWidget(
      wrap(RecommendationPanel(recommendations: [top], thresholds: thresholds)),
    );

    expect(find.textContaining('4 of 10'), findsOneWidget);
  });

  testWidgets('nothing to recommend says so explicitly and states the rule', (tester) async {
    await tester.pumpWidget(
      wrap(RecommendationPanel(recommendations: const [], thresholds: thresholds)),
    );

    expect(find.textContaining('No class currently'), findsOneWidget);
    expect(find.textContaining('40%'), findsWidgets);
    expect(find.textContaining('at least 5'), findsOneWidget);
  });

  testWidgets('recommendations are ordered as the engine ordered them', (tester) async {
    await tester.pumpWidget(
      wrap(RecommendationPanel(recommendations: [top, second], thresholds: thresholds)),
    );

    final Finder titles = find.byType(Text);
    final int topIndex = tester.widgetList<Text>(titles).toList().indexWhere(
          (t) => t.data == top.sentence,
        );
    final int secondIndex = tester.widgetList<Text>(titles).toList().indexWhere(
          (t) => t.data == second.sentence,
        );

    expect(topIndex, greaterThanOrEqualTo(0));
    expect(secondIndex, greaterThan(topIndex));
  });

  testWidgets('no sentence is generated text', (tester) async {
    // The widget only formats ResourceRecommendation fields and
    // AnalyticsThresholds values -- there is no model call, no free text
    // beyond the deterministic sentence getter and the rule description.
    await tester.pumpWidget(
      wrap(RecommendationPanel(recommendations: [top], thresholds: thresholds)),
    );

    expect(find.text(top.sentence), findsOneWidget);
  });
}
