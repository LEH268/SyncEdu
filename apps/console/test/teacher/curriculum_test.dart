import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/teacher/curriculum/chapter_editor.dart';
import 'package:syncedu_console/teacher/curriculum/material_upload.dart';
import 'package:syncedu_console/teacher/curriculum/subject_list.dart';
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

Future<String> _seedSubject(
  SyncEduDatabase db, {
  required String id,
  required String name,
  String schoolId = 'school-1',
}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.subjects).insert(
        SubjectsCompanion.insert(
          id: id,
          schoolId: schoolId,
          name: name,
          createdAt: now,
          updatedAt: now,
        ),
      );
  return id;
}

Future<void> _seedClassSubject(
  SyncEduDatabase db, {
  required String id,
  required String subjectId,
  required String teacherId,
  String classId = 'class-1',
  String schoolId = 'school-1',
}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.classSubjects).insert(
        ClassSubjectsCompanion.insert(
          id: id,
          schoolId: schoolId,
          classId: classId,
          subjectId: subjectId,
          teacherId: teacherId,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

/// Tears down the widget tree and closes the database before the test
/// returns. Drift schedules a short-lived internal timer when a
/// `StreamBuilder` unsubscribes; `SyncEduDatabase.close()` awaits that timer,
/// but only catches it if the widget has already been unmounted -- which
/// flutter_test otherwise defers until after the test body (and any
/// `tearDown`) has returned, tripping its "no pending timers" invariant.
Future<void> _settle(WidgetTester tester, SyncEduDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Advance the fake clock so the zero-duration `Timer.run` drift schedules
  // on unsubscribe actually fires -- otherwise `db.close()` below awaits a
  // completer nothing ever completes, and the test hangs forever.
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

  testWidgets('a teacher sees only subjects they teach', (tester) async {
    await _seedSubject(db, id: 'subj-mine', name: 'Mathematics');
    await _seedSubject(db, id: 'subj-theirs', name: 'History');
    await _seedClassSubject(
      db,
      id: 'cs-1',
      subjectId: 'subj-mine',
      teacherId: 'teacher-1',
    );
    await _seedClassSubject(
      db,
      id: 'cs-2',
      subjectId: 'subj-theirs',
      teacherId: 'teacher-2',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubjectList(
            repository: repo,
            schoolId: 'school-1',
            teacherId: 'teacher-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('History'), findsNothing);

    await _settle(tester, db);
  });

  testWidgets('setting the chapter count creates the missing chapters',
      (tester) async {
    await _seedSubject(db, id: 'subj-1', name: 'Mathematics');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChapterEditor(
            repository: repo,
            schoolId: 'school-1',
            subjectId: 'subj-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chapter-count')), '3');
    await tester.tap(find.byKey(const Key('chapter-count-save')));
    await tester.pumpAndSettle();

    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('Chapter 2'), findsOneWidget);
    expect(find.text('Chapter 3'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets(
      'reducing the chapter count does not delete chapters holding material',
      (tester) async {
    await _seedSubject(db, id: 'subj-1', name: 'Mathematics');
    await repo.setChapterCount(
      schoolId: 'school-1',
      subjectId: 'subj-1',
      count: 3,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChapterEditor(
            repository: repo,
            schoolId: 'school-1',
            subjectId: 'subj-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('chapter-count')), '1');
    await tester.tap(find.byKey(const Key('chapter-count-save')));
    await tester.pumpAndSettle();

    // Deleting a chapter would orphan its micro-skills, its question pool
    // and every attempt_item citing them. The count is a target, not a
    // truncation.
    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('Chapter 2'), findsOneWidget);
    expect(find.text('Chapter 3'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('a PDF chosen offline is listed as pending ingestion',
      (tester) async {
    await _seedSubject(db, id: 'subj-1', name: 'Mathematics');
    await repo.createChapter(
      schoolId: 'school-1',
      subjectId: 'subj-1',
      ordinal: 1,
      title: 'Chapter 1',
    );
    final String chapterId = (await (db.select(db.chapters)
              ..where(($ChaptersTable t) => t.subjectId.equals('subj-1')))
            .getSingle())
        .id;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaterialUpload(
            repository: repo,
            schoolId: 'school-1',
            chapterId: chapterId,
            filePicker: () async => PickedMaterialFile(
              name: 'notes.pdf',
              bytes: Uint8List.fromList(utf8.encode('pdf bytes')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('material-pick')));
    await tester.pumpAndSettle();

    expect(find.text('pending'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('a rejected format explains how to fix it', (tester) async {
    await _seedSubject(db, id: 'subj-1', name: 'Mathematics');
    await repo.createChapter(
      schoolId: 'school-1',
      subjectId: 'subj-1',
      ordinal: 1,
      title: 'Chapter 1',
    );
    final String chapterId = (await (db.select(db.chapters)
              ..where(($ChaptersTable t) => t.subjectId.equals('subj-1')))
            .getSingle())
        .id;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaterialUpload(
            repository: repo,
            schoolId: 'school-1',
            chapterId: chapterId,
            filePicker: () async => PickedMaterialFile(
              name: 'notes.docx',
              bytes: Uint8List.fromList(utf8.encode('docx bytes')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('material-pick')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Export'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('an uploaded file over the size cap is refused before queueing',
      (tester) async {
    await _seedSubject(db, id: 'subj-1', name: 'Mathematics');
    await repo.createChapter(
      schoolId: 'school-1',
      subjectId: 'subj-1',
      ordinal: 1,
      title: 'Chapter 1',
    );
    final String chapterId = (await (db.select(db.chapters)
              ..where(($ChaptersTable t) => t.subjectId.equals('subj-1')))
            .getSingle())
        .id;

    final Uint8List oversized =
        Uint8List(CurriculumRepository.maxMaterialBytes + 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaterialUpload(
            repository: repo,
            schoolId: 'school-1',
            chapterId: chapterId,
            filePicker: () async => PickedMaterialFile(
              name: 'huge.pdf',
              bytes: oversized,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('material-pick')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('material-list')), findsOneWidget);
    expect(find.text('pending'), findsNothing);
    final List<MaterialRecord> materials = await db.select(db.materials).get();
    expect(materials, isEmpty);

    await _settle(tester, db);
  });

  testWidgets('a queued upload survives a reload', (tester) async {
    await _seedSubject(db, id: 'subj-1', name: 'Mathematics');
    await repo.createChapter(
      schoolId: 'school-1',
      subjectId: 'subj-1',
      ordinal: 1,
      title: 'Chapter 1',
    );
    final String chapterId = (await (db.select(db.chapters)
              ..where(($ChaptersTable t) => t.subjectId.equals('subj-1')))
            .getSingle())
        .id;

    await repo.queueMaterialUpload(
      schoolId: 'school-1',
      chapterId: chapterId,
      fileName: 'notes.pdf',
      bytes: Uint8List.fromList(utf8.encode('pdf bytes')),
    );

    // Simulate a reload by mounting a brand new widget tree against the
    // same (in-memory, for this test) database -- the row must already be
    // there, not re-derived from anything the widget itself remembered.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaterialUpload(
            repository: repo,
            schoolId: 'school-1',
            chapterId: chapterId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('pending'), findsOneWidget);

    await _settle(tester, db);
  });

  testWidgets('ingestion status is shown per material', (tester) async {
    await _seedSubject(db, id: 'subj-1', name: 'Mathematics');
    await repo.createChapter(
      schoolId: 'school-1',
      subjectId: 'subj-1',
      ordinal: 1,
      title: 'Chapter 1',
    );
    final String chapterId = (await (db.select(db.chapters)
              ..where(($ChaptersTable t) => t.subjectId.equals('subj-1')))
            .getSingle())
        .id;

    final String materialId = await repo.queueMaterialUpload(
      schoolId: 'school-1',
      chapterId: chapterId,
      fileName: 'notes.pdf',
      bytes: Uint8List.fromList(utf8.encode('pdf bytes')),
    );

    await (db.update(db.materials)
          ..where(($MaterialsTable t) => t.id.equals(materialId)))
        .write(const MaterialsCompanion(ingestionStatus: Value('pool_ready')));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaterialUpload(
            repository: repo,
            schoolId: 'school-1',
            chapterId: chapterId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(Key('material-status-$materialId')),
      findsOneWidget,
    );
    expect(find.text('pool_ready'), findsOneWidget);

    await _settle(tester, db);
  });
}
