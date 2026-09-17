import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/teacher/schedule/schedule_editor.dart';
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

Future<void> _seedSubject(
  SyncEduDatabase db, {
  required String id,
  required String name,
}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.subjects).insert(
        SubjectsCompanion.insert(
          id: id,
          schoolId: 'school-1',
          name: name,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> _seedClassSubject(
  SyncEduDatabase db, {
  required String id,
  required String classId,
  required String subjectId,
}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.classSubjects).insert(
        ClassSubjectsCompanion.insert(
          id: id,
          schoolId: 'school-1',
          classId: classId,
          subjectId: subjectId,
          teacherId: 'teacher-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<String> _seedChapter(
  SyncEduDatabase db, {
  required String id,
  required String subjectId,
  required int ordinal,
  required String title,
}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.chapters).insert(
        ChaptersCompanion.insert(
          id: id,
          schoolId: 'school-1',
          subjectId: subjectId,
          ordinal: ordinal,
          title: title,
          createdAt: now,
          updatedAt: now,
        ),
      );
  return id;
}

/// See the identically-named helper in `curriculum_test.dart` for why this
/// dance is needed: drift schedules a short-lived timer on stream
/// unsubscribe that `db.close()` only catches once the widget tree is gone.
Future<void> _settle(WidgetTester tester, SyncEduDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await db.close();
}

void main() {
  late SyncEduDatabase db;
  late OutboxWriter outbox;
  late InMemoryMaterialBlobStore blobStore;
  late CurriculumRepository repo;

  setUp(() async {
    db = SyncEduDatabase.forTesting();
    outbox = OutboxWriter(db);
    blobStore = InMemoryMaterialBlobStore();
    repo = CurriculumRepository(db, outbox, blobStore);
    await _seedSchool(db);
  });

  testWidgets('shows every chapter of every subject this class takes',
      (tester) async {
    await _seedSubject(db, id: 'subj-math', name: 'Mathematics');
    await _seedSubject(db, id: 'subj-sci', name: 'Science');
    await _seedClassSubject(
      db,
      id: 'cs-1',
      classId: 'class-1',
      subjectId: 'subj-math',
    );
    await _seedClassSubject(
      db,
      id: 'cs-2',
      classId: 'class-1',
      subjectId: 'subj-sci',
    );
    await _seedChapter(db,
        id: 'ch-math-1', subjectId: 'subj-math', ordinal: 1, title: 'Algebra');
    await _seedChapter(db,
        id: 'ch-sci-1', subjectId: 'subj-sci', ordinal: 1, title: 'Cells');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleEditor(
            repository: repo,
            schoolId: 'school-1',
            classId: 'class-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('Cells'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('marking a chapter taught writes a tier-2 delta, not a row insert',
      (tester) async {
    await _seedSubject(db, id: 'subj-math', name: 'Mathematics');
    await _seedClassSubject(
      db,
      id: 'cs-1',
      classId: 'class-1',
      subjectId: 'subj-math',
    );
    await _seedChapter(db,
        id: 'ch-1', subjectId: 'subj-math', ordinal: 1, title: 'Algebra');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleEditor(
            repository: repo,
            schoolId: 'school-1',
            classId: 'class-1',
            today: () => DateTime.utc(2026, 3, 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('schedule-mark-ch-1')));
    await tester.pumpAndSettle();

    final List<OutboxData> queued = await db.select(db.outbox).get();
    expect(queued, hasLength(1));
    expect(queued.single.op, 'delta');
    expect(queued.single.table, 'class_chapter_sched');
    expect(queued.single.field, 'taught_on');

    expect(find.textContaining('Taught 2026-03-01'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('two classes on the same subject keep independent schedules',
      (tester) async {
    // The schedule belongs to a class-chapter, so one class may be several
    // chapters ahead of another.
    await _seedSubject(db, id: 'subj-math', name: 'Mathematics');
    await _seedClassSubject(
      db,
      id: 'cs-1',
      classId: 'class-a',
      subjectId: 'subj-math',
    );
    await _seedClassSubject(
      db,
      id: 'cs-2',
      classId: 'class-b',
      subjectId: 'subj-math',
    );
    await _seedChapter(db,
        id: 'ch-1', subjectId: 'subj-math', ordinal: 1, title: 'Algebra');

    await repo.markChapterTaught(
      schoolId: 'school-1',
      classId: 'class-a',
      chapterId: 'ch-1',
      taughtOn: DateTime.utc(2026, 2, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleEditor(
            repository: repo,
            schoolId: 'school-1',
            classId: 'class-b',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // class-b has never had this chapter marked taught, even though
    // class-a has -- the same chapter, a different class.
    expect(find.text('Not yet taught'), findsNothing);
    expect(find.textContaining('Not yet taught'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('a future date still reads as not yet taught', (tester) async {
    await _seedSubject(db, id: 'subj-math', name: 'Mathematics');
    await _seedClassSubject(
      db,
      id: 'cs-1',
      classId: 'class-1',
      subjectId: 'subj-math',
    );
    await _seedChapter(db,
        id: 'ch-1', subjectId: 'subj-math', ordinal: 1, title: 'Algebra');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleEditor(
            repository: repo,
            schoolId: 'school-1',
            classId: 'class-1',
            today: () => DateTime.utc(2026, 1, 15),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Nothing has been marked taught yet -- "today" being in the future
    // relative to some other reference is irrelevant; taughtOn is simply
    // still null.
    expect(find.textContaining('Not yet taught'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('clearing a date returns the chapter to untaught', (tester) async {
    await _seedSubject(db, id: 'subj-math', name: 'Mathematics');
    await _seedClassSubject(
      db,
      id: 'cs-1',
      classId: 'class-1',
      subjectId: 'subj-math',
    );
    await _seedChapter(db,
        id: 'ch-1', subjectId: 'subj-math', ordinal: 1, title: 'Algebra');
    await repo.markChapterTaught(
      schoolId: 'school-1',
      classId: 'class-1',
      chapterId: 'ch-1',
      taughtOn: DateTime.utc(2026, 2, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleEditor(
            repository: repo,
            schoolId: 'school-1',
            classId: 'class-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Taught 2026-02-01'), findsOneWidget);

    await tester.tap(find.byKey(const Key('schedule-clear-ch-1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Not yet taught'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('the editor works with no connection and shows the pending count',
      (tester) async {
    await _seedSubject(db, id: 'subj-math', name: 'Mathematics');
    await _seedClassSubject(
      db,
      id: 'cs-1',
      classId: 'class-1',
      subjectId: 'subj-math',
    );
    await _seedChapter(db,
        id: 'ch-1', subjectId: 'subj-math', ordinal: 1, title: 'Algebra');

    // No RemoteGateway, no connectivity stream, no SyncEngine at all --
    // this repository never touches the network, so the editor renders
    // and accepts writes exactly the same offline as online.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleEditor(
            repository: repo,
            schoolId: 'school-1',
            classId: 'class-1',
            today: () => DateTime.utc(2026, 3, 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All schedule changes synced'), findsOneWidget);

    await tester.tap(find.byKey(const Key('schedule-mark-ch-1')));
    await tester.pumpAndSettle();

    expect(
      find.text('1 schedule change waiting to sync'),
      findsOneWidget,
    );

    await _settle(tester, db);
  });
}
