import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/router.dart';
import 'package:syncedu_console/shells/admin_shell.dart';
import 'package:syncedu_console/shells/no_access_screen.dart';
import 'package:syncedu_console/shells/teacher_shell.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

SessionClaims claimsFor(UserRole role) =>
    SessionClaims(userId: 'user', schoolId: 'school', role: role);

/// Drift schedules a short-lived timer on stream unsubscribe that
/// `db.close()` only catches once the widget tree is gone (see
/// `test/admin/management_test.dart` and `test/teacher/curriculum_test.dart`
/// for the same dance). Landing on either shell now mounts a tab with a live
/// repository stream (e.g. `SubjectList`), so every test here needs this
/// settle before it ends -- and it must be awaited directly at the end of
/// the test body, not registered via `addTearDown`, so it completes before
/// the framework's pending-timer check runs.
Future<void> _settle(WidgetTester tester, SyncEduDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await db.close();
}

class Console {
  Console(this.gateway, this.db);

  final FakeAuthGateway gateway;
  final SyncEduDatabase db;
}

Future<Console> pumpConsole(
  WidgetTester tester,
  SessionClaims? session,
) async {
  final gateway = FakeAuthGateway(initial: session);
  final db = SyncEduDatabase.forTesting();
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: buildConsoleRouter(gateway: gateway, db: db),
    ),
  );
  await tester.pumpAndSettle();
  return Console(gateway, db);
}

void main() {
  testWidgets('a signed-out visitor lands on sign-in', (tester) async {
    final Console console = await pumpConsole(tester, null);
    expect(find.byType(SignInScreen), findsOneWidget);
    console.gateway.dispose();
    await _settle(tester, console.db);
  });

  testWidgets('a teacher lands on the teacher shell', (tester) async {
    final Console console =
        await pumpConsole(tester, claimsFor(UserRole.teacher));
    expect(find.byType(TeacherShell), findsOneWidget);
    expect(find.byType(AdminShell), findsNothing);
    console.gateway.dispose();
    await _settle(tester, console.db);
  });

  testWidgets('an admin lands on the admin shell', (tester) async {
    final Console console =
        await pumpConsole(tester, claimsFor(UserRole.admin));
    expect(find.byType(AdminShell), findsOneWidget);
    expect(find.byType(TeacherShell), findsNothing);
    console.gateway.dispose();
    await _settle(tester, console.db);
  });

  testWidgets('a student is refused the console entirely', (tester) async {
    // The console is staff-only. A student reaching either shell would be
    // able to read the whole school's analytics.
    final Console console =
        await pumpConsole(tester, claimsFor(UserRole.student));
    expect(find.byType(NoAccessScreen), findsOneWidget);
    expect(find.byType(TeacherShell), findsNothing);
    expect(find.byType(AdminShell), findsNothing);
    console.gateway.dispose();
    await _settle(tester, console.db);
  });

  testWidgets('a session change redirects without the user navigating',
      (tester) async {
    final gateway = FakeAuthGateway();
    final db = SyncEduDatabase.forTesting();
    gateway.accepts['head@test.syncedu.invalid:secret'] =
        claimsFor(UserRole.admin);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: buildConsoleRouter(gateway: gateway, db: db),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);

    await gateway.signIn(
      email: 'head@test.syncedu.invalid',
      password: 'secret',
    );
    await tester.pumpAndSettle();

    expect(find.byType(AdminShell), findsOneWidget);

    gateway.dispose();
    await _settle(tester, db);
  });
}
