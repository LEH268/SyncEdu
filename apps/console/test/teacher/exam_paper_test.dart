import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/teacher/roster/exam_paper_repository.dart';
import 'package:syncedu_local/syncedu_local.dart';

final DateTime _now = DateTime.utc(2026, 1, 1);

void main() {
  late SyncEduDatabase db;

  setUp(() async {
    db = SyncEduDatabase.forTesting();
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
          id: 'sub', schoolId: 's', name: 'Maths',
          createdAt: _now, updatedAt: _now,
        ));
    for (int i = 3; i >= 1; i--) {
      await db.into(db.chapters).insert(ChaptersCompanion.insert(
            id: 'c$i', schoolId: 's', subjectId: 'sub', ordinal: i,
            title: 'Chapter $i', createdAt: _now, updatedAt: _now,
          ));
    }
  });
  tearDown(() => db.close());

  test('the file upload needs a connection and says so', () async {
    final ExamPaperRepository repo =
        ExamPaperRepository(db: db, uploadedBy: 't1', supabase: null);
    expect(
      () => repo.upload(
        schoolId: 's',
        studentId: 'stu1',
        chapterId: 'c1',
        fileName: 'paper.pdf',
        bytes: Uint8List(4),
      ),
      throwsA(isA<ExamPaperOffline>()),
    );
  });

  test('chapterOptions are ordered by ordinal', () async {
    final ExamPaperRepository repo =
        ExamPaperRepository(db: db, uploadedBy: 't1', supabase: null);
    final List<(String, String)> options = await repo.chapterOptions('s');
    expect(options.map((o) => o.$1).toList(), <String>['c1', 'c2', 'c3']);
  });
}
