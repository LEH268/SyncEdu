import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:uuid/uuid.dart';

class ExamPaperOffline implements Exception {
  const ExamPaperOffline();
  @override
  String toString() =>
      'The paper file has to be uploaded while connected. Try again online.';
}

/// One uploaded exam paper as the roster view needs it.
class ExamPaperRecord {
  const ExamPaperRecord({
    required this.id,
    required this.chapterId,
    required this.analysisStatus,
    required this.note,
  });

  final String id;
  final String chapterId;
  final String analysisStatus;
  final String? note;
}

/// Uploads a marked exam paper and inserts the `exam_papers` row that the
/// `pg_cron` sweep picks up. The file itself needs a connection (spec §4.4
/// names queued PDFs as the one large payload and an accepted risk); the row
/// is a tier-1 append like every other console write.
class ExamPaperRepository {
  ExamPaperRepository({
    required SyncEduDatabase db,
    required this.uploadedBy,
    required this.supabase,
  })  : _db = db,
        _outbox = OutboxWriter(db);

  final SyncEduDatabase _db;
  final SupabaseClient? supabase;
  final OutboxWriter _outbox;
  final String uploadedBy;
  static const Uuid _uuid = Uuid();

  Stream<List<ExamPaperRecord>> watchFor(String studentId) {
    return (_db.select(_db.examPapers)
          ..where(($ExamPapersTable t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ExamPapersTable>>[
            ($ExamPapersTable t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch()
        .map((List<ExamPaper> rows) => <ExamPaperRecord>[
              for (final ExamPaper r in rows)
                ExamPaperRecord(
                  id: r.id,
                  chapterId: r.chapterId,
                  analysisStatus: r.analysisStatus,
                  note: r.analysisNote,
                ),
            ]);
  }

  Future<String> upload({
    required String schoolId,
    required String studentId,
    required String chapterId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final SupabaseClient? client = supabase;
    if (client == null) throw const ExamPaperOffline();

    final String id = _uuid.v4();
    final String ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'pdf';
    final String path = '$schoolId/$id.$ext';
    final String contentType =
        ext == 'png' ? 'image/png' : ext == 'jpg' || ext == 'jpeg'
            ? 'image/jpeg'
            : 'application/pdf';

    await client.storage.from('exam-papers').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    final DateTime now = DateTime.now().toUtc();
    await _db.into(_db.examPapers).insert(
          ExamPapersCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            chapterId: chapterId,
            storagePath: path,
            uploadedBy: uploadedBy,
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _outbox.queueInsert(
      table: 'exam_papers',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'chapter_id': chapterId,
        'storage_path': path,
        'uploaded_by': uploadedBy,
      },
    );
    return id;
  }

  /// (chapterId, title) for every chapter in the school, ordered by ordinal —
  /// the dropdown source for the upload form.
  Future<List<(String, String)>> chapterOptions(String schoolId) async {
    final List<Chapter> rows = await (_db.select(_db.chapters)
          ..where(($ChaptersTable t) =>
              t.schoolId.equals(schoolId) & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ChaptersTable>>[
            ($ChaptersTable t) => OrderingTerm.asc(t.ordinal),
          ]))
        .get();
    return <(String, String)>[for (final Chapter c in rows) (c.id, c.title)];
  }
}
