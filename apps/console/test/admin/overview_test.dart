import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/admin/overview/difficulty_ranking.dart';
import 'package:syncedu_console/admin/overview/kpi_cards.dart';
import 'package:syncedu_console/admin/risk/at_risk_table.dart';
import 'package:syncedu_core/syncedu_core.dart';

RiskRow _risk({
  required String studentId,
  required String studentName,
  required String classId,
  required String className,
  required RiskLevel level,
  List<String> reasons = const <String>['overall mastery is 40%, below the 60% bar'],
}) {
  return RiskRow(
    studentId: studentId,
    studentName: studentName,
    classId: classId,
    className: className,
    level: level,
    reasons: reasons,
  );
}

void main() {
  testWidgets('KPI cards show the four figures', (tester) async {
    const kpis = SchoolKpis(
      totalStudents: 120,
      totalTeachers: 8,
      studentsAtRisk: 15,
      averageMastery: 0.72,
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: KpiCards(kpis: kpis))),
    );

    expect(find.text('120'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
  });

  testWidgets('the difficulty ranking labels its percentage as students, not answers',
      (tester) async {
    final ranked = <DifficultyRank>[
      const DifficultyRank(
        microSkillId: 's1',
        microSkillLabel: 'Long division',
        chapterTitle: 'Division',
        subjectName: 'Maths',
        studentsStruggling: 12,
        studentsAttempted: 30,
        proportion: 0.4,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DifficultyRanking(ranked: ranked))),
    );

    expect(find.textContaining('of students'), findsWidgets);
  });

  testWidgets('each ranked row shows how many students it is based on',
      (tester) async {
    final ranked = <DifficultyRank>[
      const DifficultyRank(
        microSkillId: 's1',
        microSkillLabel: 'Long division',
        chapterTitle: 'Division',
        subjectName: 'Maths',
        studentsStruggling: 12,
        studentsAttempted: 30,
        proportion: 0.4,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DifficultyRanking(ranked: ranked))),
    );

    expect(find.textContaining('12 of 30 students'), findsOneWidget);
  });

  testWidgets('the at-risk table shows a reason for every row', (tester) async {
    final rows = <RiskRow>[
      _risk(
        studentId: '1',
        studentName: 'Amir',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.high,
        reasons: const ['failing 3 skills'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AtRiskTable(rows: rows))),
    );

    expect(find.textContaining('failing 3 skills'), findsOneWidget);
  });

  testWidgets('high risk is visually distinct from medium', (tester) async {
    final rows = <RiskRow>[
      _risk(
        studentId: '1',
        studentName: 'Amir',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.high,
      ),
      _risk(
        studentId: '2',
        studentName: 'Siti',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.medium,
        reasons: const ['no attempt in 20 days'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AtRiskTable(rows: rows))),
    );

    final Container high = tester.widget<Container>(
      find.byKey(const Key('at-risk-level-1')),
    );
    final Container medium = tester.widget<Container>(
      find.byKey(const Key('at-risk-level-2')),
    );
    expect(high.color, isNot(medium.color));
  });

  testWidgets('filtering by class narrows the table', (tester) async {
    final rows = <RiskRow>[
      _risk(
        studentId: '1',
        studentName: 'Amir',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.high,
      ),
      _risk(
        studentId: '2',
        studentName: 'Siti',
        classId: 'c2',
        className: 'Class B',
        level: RiskLevel.medium,
        reasons: const ['no attempt in 20 days'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AtRiskTable(rows: rows))),
    );

    expect(find.text('Amir'), findsOneWidget);
    expect(find.text('Siti'), findsOneWidget);

    await tester.tap(find.byKey(const Key('at-risk-class-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Class A').last);
    await tester.pumpAndSettle();

    expect(find.text('Amir'), findsOneWidget);
    expect(find.text('Siti'), findsNothing);
  });

  testWidgets('filtering by risk level narrows the table', (tester) async {
    final rows = <RiskRow>[
      _risk(
        studentId: '1',
        studentName: 'Amir',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.high,
      ),
      _risk(
        studentId: '2',
        studentName: 'Siti',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.medium,
        reasons: const ['no attempt in 20 days'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AtRiskTable(rows: rows))),
    );

    await tester.tap(find.byKey(const Key('at-risk-level-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();

    expect(find.text('Amir'), findsOneWidget);
    expect(find.text('Siti'), findsNothing);
  });

  testWidgets('both filters compose', (tester) async {
    final rows = <RiskRow>[
      _risk(
        studentId: '1',
        studentName: 'Amir',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.high,
      ),
      _risk(
        studentId: '2',
        studentName: 'Siti',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.medium,
        reasons: const ['no attempt in 20 days'],
      ),
      _risk(
        studentId: '3',
        studentName: 'Ravi',
        classId: 'c2',
        className: 'Class B',
        level: RiskLevel.high,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AtRiskTable(rows: rows))),
    );

    await tester.tap(find.byKey(const Key('at-risk-class-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Class A').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('at-risk-level-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();

    expect(find.text('Amir'), findsOneWidget);
    expect(find.text('Siti'), findsNothing);
    expect(find.text('Ravi'), findsNothing);
  });

  testWidgets('clearing filters restores every row', (tester) async {
    final rows = <RiskRow>[
      _risk(
        studentId: '1',
        studentName: 'Amir',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.high,
      ),
      _risk(
        studentId: '2',
        studentName: 'Siti',
        classId: 'c2',
        className: 'Class B',
        level: RiskLevel.medium,
        reasons: const ['no attempt in 20 days'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AtRiskTable(rows: rows))),
    );

    await tester.tap(find.byKey(const Key('at-risk-class-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Class A').last);
    await tester.pumpAndSettle();

    expect(find.text('Siti'), findsNothing);

    await tester.tap(find.byKey(const Key('at-risk-clear-filters')));
    await tester.pumpAndSettle();

    expect(find.text('Amir'), findsOneWidget);
    expect(find.text('Siti'), findsOneWidget);
  });

  testWidgets('an empty result explains why rather than showing a blank table',
      (tester) async {
    final rows = <RiskRow>[
      _risk(
        studentId: '1',
        studentName: 'Amir',
        classId: 'c1',
        className: 'Class A',
        level: RiskLevel.high,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AtRiskTable(rows: rows))),
    );

    await tester.tap(find.byKey(const Key('at-risk-level-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medium').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('No students match these filters'), findsOneWidget);
  });

  testWidgets('a school with no data shows zeroes, not NaN or a crash',
      (tester) async {
    const kpis = SchoolKpis(
      totalStudents: 0,
      totalTeachers: 0,
      studentsAtRisk: 0,
      averageMastery: 0.0,
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: KpiCards(kpis: kpis))),
    );

    expect(find.text('0%'), findsOneWidget);
    expect(find.textContaining('NaN'), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AtRiskTable(rows: <RiskRow>[])),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DifficultyRanking(ranked: <DifficultyRank>[])),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
