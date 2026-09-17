import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:syncedu_student/quiz/chapter_picker.dart';
import 'package:syncedu_student/quiz/quiz_runner.dart';
import 'package:syncedu_student/onboarding/pre_admission_screen.dart';
import 'package:syncedu_student/router.dart';
import 'package:syncedu_student/shells/home_shell.dart';
import 'package:syncedu_student/shells/staff_redirect_screen.dart';

SessionClaims claimsFor(UserRole role) =>
    SessionClaims(userId: 'user', schoolId: 'school', role: role);

Future<SyncEduDatabase> pumpStudentApp(
  WidgetTester tester,
  SessionClaims? session, {
  bool seed = false,
  bool preAdmissionDone = true,
}) async {
  final gateway = FakeAuthGateway(initial: session);
  addTearDown(gateway.dispose);
  final database = SyncEduDatabase.forTesting();
  addTearDown(database.close);
  if (seed) {
    // The signed-in profile has to resolve to a students row, or the quiz
    // scope legitimately refuses to build a controller. Pre-admission is
    // marked complete by default so the mandatory-test gate does not fire.
    await database.into(database.students).insert(
          StudentsCompanion.insert(
            id: 'student-signed-in',
            schoolId: 'school',
            profileId: 'user',
            preAdmissionCompletedAt: preAdmissionDone
                ? Value(DateTime.utc(2026, 1, 1))
                : const Value<DateTime?>(null),
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
  }
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: buildStudentRouter(gateway: gateway, database: database),
    ),
  );
  await tester.pumpAndSettle();
  return database;
}

void main() {
  testWidgets('a signed-out visitor lands on sign-in', (tester) async {
    await pumpStudentApp(tester, null);
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('a student lands on the home shell', (tester) async {
    await pumpStudentApp(tester, claimsFor(UserRole.student));
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('a teacher is sent to the console instead', (tester) async {
    await pumpStudentApp(tester, claimsFor(UserRole.teacher));
    expect(find.byType(StaffRedirectScreen), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
  });

  testWidgets('an admin is sent to the console instead', (tester) async {
    await pumpStudentApp(tester, claimsFor(UserRole.admin));
    expect(find.byType(StaffRedirectScreen), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
  });

  testWidgets('the home shell offers a way into the quiz flow', (tester) async {
    await pumpStudentApp(tester, claimsFor(UserRole.student), seed: true);

    expect(find.byKey(const Key('home-start-quiz')), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-start-quiz')));
    await tester.pumpAndSettle();

    // The redirect used to bounce every non-/home location straight back, so
    // the whole quiz flow was unreachable from the running app.
    expect(find.byType(ChapterPicker), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
  });

  testWidgets('a student is not bounced off a quiz route they navigate to',
      (tester) async {
    final gateway = FakeAuthGateway(initial: claimsFor(UserRole.student));
    addTearDown(gateway.dispose);
    final database = SyncEduDatabase.forTesting();
    addTearDown(database.close);
    await database.into(database.students).insert(
          StudentsCompanion.insert(
            id: 'student-signed-in',
            schoolId: 'school',
            profileId: 'user',
            preAdmissionCompletedAt: Value(DateTime.utc(2026, 1, 1)),
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );

    final router = buildStudentRouter(gateway: gateway, database: database);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/quiz/pick');
    await tester.pumpAndSettle();
    expect(find.byType(ChapterPicker), findsOneWidget);
  });

  testWidgets('a quiz route waits rather than crashing on an unsynced student',
      (tester) async {
    // No students row for this profile yet: the auth user id is profiles.id,
    // and substituting it for students.id is exactly the bug being guarded.
    final gateway = FakeAuthGateway(initial: claimsFor(UserRole.student));
    addTearDown(gateway.dispose);
    final database = SyncEduDatabase.forTesting();
    addTearDown(database.close);

    final router = buildStudentRouter(gateway: gateway, database: database);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/quiz/pick');
    await tester.pumpAndSettle();

    expect(find.byType(ChapterPicker), findsNothing);
    expect(find.byKey(const Key('quiz-unready-home')), findsOneWidget);
  });

  testWidgets(
      'the cached quiz controller is discarded when the signed-in student '
      'changes', (tester) async {
    // Student A signs in and a controller gets cached for `student-a`.
    final gateway = FakeAuthGateway(
      initial: const SessionClaims(
        userId: 'user-a',
        schoolId: 'school',
        role: UserRole.student,
      ),
    );
    addTearDown(gateway.dispose);
    final database = SyncEduDatabase.forTesting();
    addTearDown(database.close);
    await database.into(database.students).insert(
          StudentsCompanion.insert(
            id: 'student-a',
            schoolId: 'school',
            profileId: 'user-a',
            preAdmissionCompletedAt: Value(DateTime.utc(2026, 1, 1)),
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    await database.into(database.students).insert(
          StudentsCompanion.insert(
            id: 'student-b',
            schoolId: 'school',
            profileId: 'user-b',
            preAdmissionCompletedAt: Value(DateTime.utc(2026, 1, 1)),
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );

    final router = buildStudentRouter(gateway: gateway, database: database);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/quiz/run');
    await tester.pumpAndSettle();
    final QuizRunner runnerA =
        tester.widget<QuizRunner>(find.byType(QuizRunner));
    expect(runnerA.controller.studentId, 'student-a');

    // Student A signs out; student B signs in on the same device/router.
    await gateway.signOut();
    await tester.pumpAndSettle();
    gateway.accepts['b@example.com:password'] = const SessionClaims(
      userId: 'user-b',
      schoolId: 'school',
      role: UserRole.student,
    );
    await gateway.signIn(email: 'b@example.com', password: 'password');
    await tester.pumpAndSettle();

    router.go('/quiz/run');
    await tester.pumpAndSettle();
    final QuizRunner runnerB =
        tester.widget<QuizRunner>(find.byType(QuizRunner));

    // Before the fix, the session-cached controller kept student A's id, so
    // student B's answers/attempts/weakness writes would be filed under A.
    expect(runnerB.controller.studentId, 'student-b');
  });

  testWidgets(
    'a new student is forced through the Pre-admission Test before anything else',
    (tester) async {
      await pumpStudentApp(
        tester,
        claimsFor(UserRole.student),
        seed: true,
        preAdmissionDone: false,
      );
      expect(find.byType(PreAdmissionScreen), findsOneWidget);
      expect(find.byType(HomeShell), findsNothing);
    },
  );

  testWidgets('the gate does not fire once the instrument is complete',
      (tester) async {
    await pumpStudentApp(tester, claimsFor(UserRole.student), seed: true);
    expect(find.byType(PreAdmissionScreen), findsNothing);
    expect(find.byType(HomeShell), findsOneWidget);
  });
}
