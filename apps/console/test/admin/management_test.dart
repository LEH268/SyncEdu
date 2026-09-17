import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/admin/management/class_editor.dart';
import 'package:syncedu_console/admin/management/csv_import.dart';
import 'package:syncedu_console/admin/management/special_needs_editor.dart';
import 'package:syncedu_console/admin/management/teacher_editor.dart';
import 'package:syncedu_local/syncedu_local.dart';

Future<void> _seedSchool(SyncEduDatabase db) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.schools).insert(
        SchoolsCompanion.insert(
          id: 'school-1',
          name: 'Test School',
          educationLevel: 'secondary',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> _seedTeacher(SyncEduDatabase db, {required String id}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          id: id,
          schoolId: 'school-1',
          role: 'teacher',
          fullName: 'Teacher $id',
          email: '$id@school.test',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> _seedClass(
  SyncEduDatabase db, {
  required String id,
  String name = 'Class A',
}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.classes).insert(
        ClassesCompanion.insert(
          id: id,
          schoolId: 'school-1',
          name: name,
          yearLevel: 7,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> _seedStudent(
  SyncEduDatabase db, {
  required String id,
  String? classId,
  List<String> specialNeeds = const <String>[],
  DateTime? deletedAt,
}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          id: 'profile-$id',
          schoolId: 'school-1',
          role: 'student',
          fullName: 'Student $id',
          email: '$id@school.test',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db.into(db.students).insert(
        StudentsCompanion.insert(
          id: id,
          schoolId: 'school-1',
          profileId: 'profile-$id',
          classId: Value(classId),
          specialNeeds: Value(jsonEncode(specialNeeds)),
          createdAt: now,
          updatedAt: now,
          deletedAt: Value(deletedAt),
        ),
      );
}

/// See `curriculum_test.dart` for why this dance is needed: drift schedules
/// a short-lived timer on stream unsubscribe that `db.close()` only catches
/// once the widget tree is gone.
Future<void> _settle(WidgetTester tester, SyncEduDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await db.close();
}

void main() {
  late SyncEduDatabase db;
  late OutboxWriter outbox;
  late ManagementRepository repo;

  setUp(() async {
    db = SyncEduDatabase.forTesting();
    outbox = OutboxWriter(db);
    repo = ManagementRepository(db, outbox);
    await _seedSchool(db);
  });

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('class and teacher management', () {
    testWidgets('creating a class captures its target learning style',
        (tester) async {
      await tester.pumpWidget(
        wrap(ClassEditor(repository: repo, schoolId: 'school-1')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('class-name')), 'Form 7A');
      await tester.enterText(find.byKey(const Key('class-year-level')), '7');
      await tester.tap(find.byKey(const Key('class-learning-style')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('visual').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('class-create')));
      await tester.pumpAndSettle();

      final List<ClassesData> classes = await db.select(db.classes).get();
      expect(classes, hasLength(1));
      expect(classes.single.name, 'Form 7A');
      expect(classes.single.targetLearningStyle, 'visual');

      await _settle(tester, db);
    });

    testWidgets(
        'creating a teacher queues a provisioning intent when offline',
        (tester) async {
      await tester.pumpWidget(
        wrap(TeacherEditor(repository: repo, schoolId: 'school-1')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('teacher-email')), 'newteacher@school.test');
      await tester.enterText(
          find.byKey(const Key('teacher-name')), 'New Teacher');
      await tester.tap(find.byKey(const Key('teacher-create')));
      await tester.pumpAndSettle();

      final List<PendingIntent> intents =
          await db.select(db.pendingIntents).get();
      expect(intents, hasLength(1));
      expect(intents.single.functionName, 'provision-users');
      expect(intents.single.status, 'pending');

      final Map<String, dynamic> payload =
          jsonDecode(intents.single.payload) as Map<String, dynamic>;
      final List<dynamic> users = payload['users'] as List<dynamic>;
      expect(users, hasLength(1));
      expect((users.single as Map<String, dynamic>)['email'],
          'newteacher@school.test');

      expect(find.byKey(const Key('teacher-queued-message')), findsOneWidget);

      await _settle(tester, db);
    });

    testWidgets(
        'the returned temporary password is shown once, with a copy action',
        (tester) async {
      String? copied;
      await tester.pumpWidget(
        wrap(TeacherEditor(
          repository: repo,
          schoolId: 'school-1',
          provisioningResult: 'Abc123!xyz',
          copyToClipboard: (String text) async => copied = text,
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('Abc123!xyz'), findsOneWidget);

      await tester.tap(find.byKey(const Key('teacher-password-copy')));
      await tester.pumpAndSettle();

      expect(copied, 'Abc123!xyz');
      // Shown once: after being copied, it disappears from the tree.
      expect(find.text('Abc123!xyz'), findsNothing);

      await _settle(tester, db);
    });

    testWidgets('assigning a teacher to a class writes class_subjects',
        (tester) async {
      await _seedTeacher(db, id: 'teacher-1');

      await tester.pumpWidget(
        wrap(TeacherEditor(repository: repo, schoolId: 'school-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('assign-teacher')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Teacher teacher-1').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('assign-class-id')), 'class-1');
      await tester.enterText(find.byKey(const Key('assign-subject-id')), 'subject-1');
      await tester.tap(find.byKey(const Key('assign-submit')));
      await tester.pumpAndSettle();

      final List<ClassSubject> rows = await db.select(db.classSubjects).get();
      expect(rows, hasLength(1));
      expect(rows.single.classId, 'class-1');
      expect(rows.single.subjectId, 'subject-1');
      expect(rows.single.teacherId, 'teacher-1');

      await _settle(tester, db);
    });

    testWidgets(
        'special-needs labels come from the fixed vocabulary plus free text',
        (tester) async {
      await _seedStudent(db, id: 'student-1');

      await tester.pumpWidget(
        wrap(SpecialNeedsEditor(repository: repo, studentId: 'student-1')),
      );
      await tester.pumpAndSettle();

      for (final String label in kSpecialNeedsVocabulary) {
        expect(find.byKey(Key('need-$label')), findsOneWidget);
      }
      expect(find.byKey(const Key('need-other-text')), findsOneWidget);

      await tester.tap(find.byKey(const Key('need-dyslexia')));
      await tester.enterText(
          find.byKey(const Key('need-other-text')), 'peanut_allergy');
      await tester.tap(find.byKey(const Key('special-needs-save')));
      await tester.pumpAndSettle();

      final Student student = await (db.select(db.students)
            ..where(($StudentsTable t) => t.id.equals('student-1')))
          .getSingle();
      final List<dynamic> saved = jsonDecode(student.specialNeeds) as List<dynamic>;
      expect(saved, containsAll(<String>['dyslexia', 'peanut_allergy']));

      await _settle(tester, db);
    });

    testWidgets(
        'a special-needs change is a tier-3 delta carrying its observed value',
        (tester) async {
      await _seedStudent(db, id: 'student-1', specialNeeds: <String>['adhd']);

      await tester.pumpWidget(
        wrap(SpecialNeedsEditor(repository: repo, studentId: 'student-1')),
      );
      await tester.pumpAndSettle();

      // adhd starts checked, reflecting the seeded row.
      final CheckboxListTile adhdTile = tester.widget<CheckboxListTile>(
        find.byKey(const Key('need-adhd')),
      );
      expect(adhdTile.value, isTrue);

      await tester.tap(find.byKey(const Key('need-dyslexia')));
      await tester.tap(find.byKey(const Key('special-needs-save')));
      await tester.pumpAndSettle();

      final List<OutboxData> queued = await db.select(db.outbox).get();
      expect(queued, hasLength(1));
      expect(queued.single.op, 'delta');
      expect(queued.single.table, 'students');
      expect(queued.single.field, 'special_needs');
      expect(jsonDecode(queued.single.observedValue!), <String>['adhd']);
      expect(
        jsonDecode(queued.single.newValue!),
        containsAll(<String>['adhd', 'dyslexia']),
      );

      await _settle(tester, db);
    });

    testWidgets('moving a student between classes is a tier-3 delta',
        (tester) async {
      await _seedClass(db, id: 'class-a', name: 'Class A');
      await _seedClass(db, id: 'class-b', name: 'Class B');
      await _seedStudent(db, id: 'student-1', classId: 'class-a');

      await tester.pumpWidget(
        wrap(StudentClassAssignment(
          repository: repo,
          schoolId: 'school-1',
          studentId: 'student-1',
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('move-student-class')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Class B').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('move-student-submit')));
      await tester.pumpAndSettle();

      final List<OutboxData> queued = await db.select(db.outbox).get();
      expect(queued, hasLength(1));
      expect(queued.single.op, 'delta');
      expect(queued.single.table, 'students');
      expect(queued.single.field, 'class_id');
      expect(jsonDecode(queued.single.observedValue!), 'class-a');
      expect(jsonDecode(queued.single.newValue!), 'class-b');

      await _settle(tester, db);
    });

    test('a soft-deleted student is excluded from watchStudent', () async {
      await _seedStudent(
        db,
        id: 'student-1',
        specialNeeds: <String>['adhd'],
        deletedAt: DateTime.utc(2026, 2, 1),
      );

      final Student? found = await repo.watchStudent('student-1').first;
      expect(found, isNull);

      await db.close();
    });

    test(
        'special-needs and class-move writes reject a soft-deleted student',
        () async {
      await _seedClass(db, id: 'class-a', name: 'Class A');
      await _seedStudent(
        db,
        id: 'student-1',
        classId: 'class-a',
        specialNeeds: <String>['adhd'],
        deletedAt: DateTime.utc(2026, 2, 1),
      );

      await expectLater(
        repo.updateStudentSpecialNeeds(
          studentId: 'student-1',
          newSpecialNeeds: <String>['dyslexia'],
        ),
        throwsA(isA<StateError>()),
      );

      await expectLater(
        repo.moveStudentToClass(studentId: 'student-1', newClassId: 'class-a'),
        throwsA(isA<StateError>()),
      );

      // Neither rejected write should have queued an outbox delta.
      final List<OutboxData> queued = await db.select(db.outbox).get();
      expect(queued, isEmpty);

      await db.close();
    });
  });

  group('csv import', () {
    const String validCsv = 'email,full_name\n'
        'a@school.test,Alice A\n'
        'b@school.test,Bob B\n';

    testWidgets('a well-formed CSV previews every row before importing',
        (tester) async {
      await tester.pumpWidget(
        wrap(CsvImport(repository: repo, schoolId: 'school-1')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('csv-input')), validCsv);
      await tester.tap(find.byKey(const Key('csv-preview')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('csv-preview-row-a@school.test')),
          findsOneWidget);
      expect(find.byKey(const Key('csv-preview-row-b@school.test')),
          findsOneWidget);

      final List<PendingIntent> intents =
          await db.select(db.pendingIntents).get();
      expect(intents, isEmpty);

      await _settle(tester, db);
    });

    testWidgets(
        'a malformed row is reported with its line number, not silently skipped',
        (tester) async {
      const String badCsv = 'email,full_name\n'
          'a@school.test,Alice A\n'
          'not-an-email,Bob B\n';

      await tester.pumpWidget(
        wrap(CsvImport(repository: repo, schoolId: 'school-1')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('csv-input')), badCsv);
      await tester.tap(find.byKey(const Key('csv-preview')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('csv-error-3')), findsOneWidget);
      expect(find.textContaining('Line 3'), findsOneWidget);

      await _settle(tester, db);
    });

    testWidgets('a duplicate email within the file is caught before submission',
        (tester) async {
      const String dupeCsv = 'email,full_name\n'
          'a@school.test,Alice A\n'
          'a@school.test,Alice Again\n';

      await tester.pumpWidget(
        wrap(CsvImport(repository: repo, schoolId: 'school-1')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('csv-input')), dupeCsv);
      await tester.tap(find.byKey(const Key('csv-preview')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('csv-error-3')), findsOneWidget);
      expect(find.textContaining('duplicates'), findsOneWidget);

      await _settle(tester, db);
    });

    testWidgets('import is refused entirely if any row is invalid',
        (tester) async {
      const String mixedCsv = 'email,full_name\n'
          'a@school.test,Alice A\n'
          'not-an-email,Bob B\n';

      await tester.pumpWidget(
        wrap(CsvImport(repository: repo, schoolId: 'school-1')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('csv-input')), mixedCsv);
      await tester.tap(find.byKey(const Key('csv-preview')));
      await tester.pumpAndSettle();

      // No import button is offered at all while any row is invalid.
      expect(find.byKey(const Key('csv-import')), findsNothing);

      final List<PendingIntent> intents =
          await db.select(db.pendingIntents).get();
      expect(intents, isEmpty);

      await _settle(tester, db);
    });

    testWidgets('a CSV import made offline is queued and reported as pending',
        (tester) async {
      // No RemoteGateway, no connectivity stream, no SyncEngine at all --
      // this repository never touches the network, so the import behaves
      // identically online or off.
      await tester.pumpWidget(
        wrap(CsvImport(repository: repo, schoolId: 'school-1')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('csv-input')), validCsv);
      await tester.tap(find.byKey(const Key('csv-preview')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('csv-import')));
      await tester.pumpAndSettle();

      final List<PendingIntent> intents =
          await db.select(db.pendingIntents).get();
      expect(intents, hasLength(1));
      expect(intents.single.functionName, 'provision-users');
      expect(intents.single.status, 'pending');

      expect(find.byKey(const Key('csv-import-status')), findsOneWidget);
      expect(find.textContaining('pending'), findsWidgets);

      await _settle(tester, db);
    });
  });
}
