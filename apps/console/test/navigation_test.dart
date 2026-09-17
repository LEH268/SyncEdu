import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_console/admin/management/class_editor.dart';
import 'package:syncedu_console/admin/management/csv_import.dart';
import 'package:syncedu_console/admin/management/teacher_editor.dart';
import 'package:syncedu_console/admin/overview/difficulty_ranking.dart';
import 'package:syncedu_console/admin/overview/kpi_cards.dart';
import 'package:syncedu_console/admin/risk/at_risk_table.dart';
import 'package:syncedu_console/admin/risk/recommendation_panel.dart';
import 'package:syncedu_console/router.dart';
import 'package:syncedu_console/shells/admin_shell.dart';
import 'package:syncedu_console/shells/teacher_shell.dart';
import 'package:syncedu_console/teacher/analytics/ai_summary_panel.dart';
import 'package:syncedu_console/teacher/analytics/mastery_heatmap.dart';
import 'package:syncedu_console/teacher/analytics/most_missed_panel.dart';
import 'package:syncedu_console/teacher/curriculum/subject_list.dart';
import 'package:syncedu_console/teacher/roster/class_roster.dart';
import 'package:syncedu_console/teacher/roster/student_detail.dart';
import 'package:syncedu_console/teacher/schedule/schedule_editor.dart';
import 'package:syncedu_console/teacher/teaching/teaching_screen.dart';
import 'package:syncedu_console/widgets/sync_banner.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

SessionClaims claimsFor(UserRole role) =>
    SessionClaims(userId: 'user', schoolId: 'school', role: role);

const SyncStatus _idleStatus = SyncStatus(
  online: true,
  syncing: false,
  pendingWrites: 0,
  unresolvedConflicts: 0,
);

/// Drift schedules a short-lived timer on stream unsubscribe that
/// `db.close()` only catches once the widget tree is gone (see
/// `test/admin/management_test.dart` and `test/teacher/curriculum_test.dart`
/// for the same dance).
Future<void> _settle(WidgetTester tester, SyncEduDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await db.close();
}

/// A test harness bundling the router, its backing in-memory database and
/// the fake gateway, all torn down together via [dispose].
class Harness {
  Harness(this.tester, this.gateway, this.db, this.router);

  final WidgetTester tester;
  final FakeAuthGateway gateway;
  final SyncEduDatabase db;
  final GoRouter router;

  Future<void> dispose() async {
    gateway.dispose();
    await _settle(tester, db);
  }
}

Future<Harness> pumpConsole(
  WidgetTester tester,
  SessionClaims? session, {
  bool wrapWithBanner = false,
}) async {
  final gateway = FakeAuthGateway(initial: session);
  final db = SyncEduDatabase.forTesting();
  final router = buildConsoleRouter(gateway: gateway, db: db);
  final harness = Harness(tester, gateway, db, router);

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: wrapWithBanner
          ? (BuildContext context, Widget? child) {
              return Column(
                children: <Widget>[
                  const SyncBanner(status: _idleStatus),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              );
            }
          : null,
    ),
  );
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  testWidgets(
    'the teacher shell exposes curriculum, schedule, analytics, teaching and '
    'roster',
    (tester) async {
      final Harness harness =
          await pumpConsole(tester, claimsFor(UserRole.teacher));
      final GoRouter router = harness.router;

      expect(find.byType(TeacherShell), findsOneWidget);
      expect(find.byType(SubjectList), findsOneWidget);

      router.go('/teacher/schedule');
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleEditor), findsOneWidget);

      router.go('/teacher/analytics');
      await tester.pumpAndSettle();
      expect(find.byType(MasteryHeatmap), findsOneWidget);
      expect(find.byType(MostMissedPanel), findsOneWidget);
      expect(find.byType(AiSummaryPanel), findsOneWidget);

      router.go('/teacher/teaching');
      await tester.pumpAndSettle();
      expect(find.byType(TeachingScreen), findsOneWidget);

      router.go('/teacher/roster');
      await tester.pumpAndSettle();
      expect(find.byType(ClassRoster), findsOneWidget);

      await harness.dispose();
    },
  );

  testWidgets('the admin shell exposes overview, risk and management',
      (tester) async {
    final Harness harness =
        await pumpConsole(tester, claimsFor(UserRole.admin));
    final GoRouter router = harness.router;

    expect(find.byType(AdminShell), findsOneWidget);
    expect(find.byType(KpiCards), findsOneWidget);
    expect(find.byType(DifficultyRanking), findsOneWidget);

    router.go('/admin/risk');
    await tester.pumpAndSettle();
    expect(find.byType(AtRiskTable), findsOneWidget);
    expect(find.byType(RecommendationPanel), findsOneWidget);

    router.go('/admin/management');
    await tester.pumpAndSettle();
    expect(find.byType(ClassEditor), findsOneWidget);

    await tester.tap(find.text('Teachers'));
    await tester.pumpAndSettle();
    expect(find.byType(TeacherEditor), findsOneWidget);

    await tester.tap(find.text('Roster import'));
    await tester.pumpAndSettle();
    expect(find.byType(CsvImport), findsOneWidget);

    await harness.dispose();
  });

  testWidgets('a teacher cannot reach an admin route by typing its URL',
      (tester) async {
    // Route-level enforcement, not menu-level: hiding a link is not access
    // control.
    final Harness harness =
        await pumpConsole(tester, claimsFor(UserRole.teacher));
    final GoRouter router = harness.router;

    router.go('/admin/management');
    await tester.pumpAndSettle();

    expect(find.byType(AdminShell), findsNothing);
    expect(find.byType(TeacherShell), findsOneWidget);

    await harness.dispose();
  });

  testWidgets('an admin can reach every teacher route', (tester) async {
    final Harness harness =
        await pumpConsole(tester, claimsFor(UserRole.admin));
    final GoRouter router = harness.router;

    for (final String path in <String>[
      '/teacher/curriculum',
      '/teacher/schedule',
      '/teacher/analytics',
      '/teacher/teaching',
      '/teacher/roster',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.byType(TeacherShell), findsOneWidget, reason: path);
      expect(find.byType(AdminShell), findsNothing, reason: path);
    }

    await harness.dispose();
  });

  testWidgets('the sync banner is visible from every screen', (tester) async {
    final Harness harness = await pumpConsole(
      tester,
      claimsFor(UserRole.admin),
      wrapWithBanner: true,
    );
    final GoRouter router = harness.router;

    expect(find.byType(SyncBanner), findsOneWidget);

    router.go('/admin/management');
    await tester.pumpAndSettle();
    expect(find.byType(SyncBanner), findsOneWidget);

    router.go('/admin/risk');
    await tester.pumpAndSettle();
    expect(find.byType(SyncBanner), findsOneWidget);

    await harness.dispose();
  });

  testWidgets(
    'deep-linking to a student opens their detail with the roster behind',
    (tester) async {
      final Harness harness =
          await pumpConsole(tester, claimsFor(UserRole.teacher));
      final GoRouter router = harness.router;

      router.go('/teacher/roster/students/student-1');
      await tester.pumpAndSettle();

      expect(find.byType(StudentDetail), findsOneWidget);
      expect(find.byType(ClassRoster), findsNothing);

      final NavigatorState navigator =
          tester.state(find.byType(Navigator).last);
      expect(navigator.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(ClassRoster), findsOneWidget);
      expect(find.byType(StudentDetail), findsNothing);

      await harness.dispose();
    },
  );
}
