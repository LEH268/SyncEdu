import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../sync/outbox_writer.dart';

/// Alias for the generated `materials` row class. Flutter's own `Material`
/// widget shares the bare name, so any file importing both `package:flutter/
/// material.dart` and this package hides `Material` from this package's
/// export and refers to the row type as [MaterialRecord] instead.
typedef MaterialRecord = Material;

/// A place to put the bytes of a queued material upload while the device is
/// offline. On the web, a real implementation would write into OPFS; wiring
/// that up is a separate task, so this seam exists purely so
/// [CurriculumRepository] does not need to know how or where bytes are
/// persisted, and so tests can supply a fake that never touches a real
/// filesystem.
abstract class MaterialBlobStore {
  Future<void> write(String id, Uint8List bytes);
}

/// Keeps every queued file in memory for the lifetime of the app. This is a
/// deliberately minimal placeholder -- durable, browser-refresh-surviving
/// storage (OPFS) is future work; the important local-first behavior (a
/// `materials` row appears at `pending` immediately and is not lost while
/// offline) does not depend on where the bytes physically live.
class InMemoryMaterialBlobStore implements MaterialBlobStore {
  final Map<String, Uint8List> _blobs = <String, Uint8List>{};

  @override
  Future<void> write(String id, Uint8List bytes) async {
    _blobs[id] = bytes;
  }

  Uint8List? read(String id) => _blobs[id];
}

/// Thrown by [CurriculumRepository.queueMaterialUpload] when a file cannot be
/// queued. [message] is written for the teacher to read, so it always names
/// the fix rather than the problem.
class MaterialRejected implements Exception {
  const MaterialRejected(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One row of a class's teaching schedule: a chapter the class's subject
/// includes, and whether (and when) this particular class has been taught
/// it. [taughtOn] is null until a teacher marks the chapter taught, so "not
/// yet taught" and "taught in the future" are both represented honestly
/// rather than collapsed into a boolean.
class ScheduleEntry {
  const ScheduleEntry({
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterOrdinal,
    required this.subjectId,
    required this.subjectName,
    required this.taughtOn,
  });

  final String chapterId;
  final String chapterTitle;
  final int chapterOrdinal;
  final String subjectId;
  final String subjectName;
  final DateTime? taughtOn;
}

/// Local-first reads and writes for subjects, chapters and their materials.
/// Nothing here touches the network: writes land in the mirror and the
/// outbox, and the sync engine drains them whenever it can.
class CurriculumRepository {
  CurriculumRepository(this._db, this._outbox, this._blobStore);

  final SyncEduDatabase _db;
  final OutboxWriter _outbox;
  final MaterialBlobStore _blobStore;

  static const Uuid _uuid = Uuid();

  /// Bounds a queued upload so a single file cannot exhaust local storage
  /// before the sync engine ever gets a chance to drain it. The spec does not
  /// state a cap, so 20 MB is a judgment call: comfortably above a scanned
  /// chapter's worth of pages, comfortably below what risks stalling a weak
  /// connection once the device reconnects.
  static const int maxMaterialBytes = 20 * 1024 * 1024;

  static const Set<String> _acceptedExtensions = <String>{
    'pdf',
    'png',
    'jpg',
    'jpeg',
  };

  /// A teacher's own subjects, joined through `class_subjects.teacher_id` --
  /// the same table Postgres uses to decide who teaches what, so the console
  /// never diverges from the server's notion of ownership.
  Stream<List<Subject>> watchSubjectsForTeacher(String teacherId) {
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.subjects).join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        _db.classSubjects,
        _db.classSubjects.subjectId.equalsExp(_db.subjects.id),
      ),
    ])
          ..where(_db.classSubjects.teacherId.equals(teacherId) &
              _db.subjects.deletedAt.isNull() &
              _db.classSubjects.deletedAt.isNull());

    return query.watch().map((List<TypedResult> rows) {
      final Set<String> seen = <String>{};
      final List<Subject> result = <Subject>[];
      for (final TypedResult row in rows) {
        final Subject subject = row.readTable(_db.subjects);
        if (seen.add(subject.id)) result.add(subject);
      }
      return result;
    });
  }

  Stream<List<Chapter>> watchChaptersFor(String subjectId) {
    final SimpleSelectStatement<$ChaptersTable, Chapter> query =
        _db.select(_db.chapters)
          ..where(($ChaptersTable t) =>
              t.subjectId.equals(subjectId) & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ChaptersTable>>[
            ($ChaptersTable t) => OrderingTerm.asc(t.ordinal),
          ]);
    return query.watch();
  }

  Stream<List<MaterialRecord>> watchMaterialsFor(String chapterId) {
    final SimpleSelectStatement<$MaterialsTable, MaterialRecord> query =
        _db.select(_db.materials)
          ..where(($MaterialsTable t) =>
              t.chapterId.equals(chapterId) & t.deletedAt.isNull());
    return query.watch();
  }

  Future<String> createSubject({
    required String schoolId,
    required String name,
  }) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();

    await _db.into(_db.subjects).insert(
          SubjectsCompanion.insert(
            id: id,
            schoolId: schoolId,
            name: name,
            chapterCount: const Value(0),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _outbox.queueInsert(
      table: 'subjects',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'name': name,
        'chapter_count': 0,
      },
    );

    return id;
  }

  Future<String> createChapter({
    required String schoolId,
    required String subjectId,
    required int ordinal,
    required String title,
  }) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();

    await _db.into(_db.chapters).insert(
          ChaptersCompanion.insert(
            id: id,
            schoolId: schoolId,
            subjectId: subjectId,
            ordinal: ordinal,
            title: title,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _outbox.queueInsert(
      table: 'chapters',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'subject_id': subjectId,
        'ordinal': ordinal,
        'title': title,
      },
    );

    return id;
  }

  /// Moves `subjects.chapterCount` toward [count]. The count is a target, not
  /// a truncation: any chapter missing to reach it is created, but a chapter
  /// already at ordinals beyond the new count is left alone, because deleting
  /// it would orphan its micro-skills, its question pool and every
  /// `attempt_item` citing them.
  Future<void> setChapterCount({
    required String schoolId,
    required String subjectId,
    required int count,
  }) async {
    final Subject subject = await (_db.select(_db.subjects)
          ..where(($SubjectsTable t) => t.id.equals(subjectId)))
        .getSingle();

    await _outbox.queueDelta(
      table: 'subjects',
      rowId: subjectId,
      field: 'chapter_count',
      observedValue: subject.chapterCount,
      newValue: count,
    );

    await (_db.update(_db.subjects)
          ..where(($SubjectsTable t) => t.id.equals(subjectId)))
        .write(SubjectsCompanion(chapterCount: Value(count)));

    final List<Chapter> existing = await (_db.select(_db.chapters)
          ..where(($ChaptersTable t) =>
              t.subjectId.equals(subjectId) & t.deletedAt.isNull()))
        .get();

    final Set<int> existingOrdinals =
        existing.map((Chapter c) => c.ordinal).toSet();

    for (int ordinal = 1; ordinal <= count; ordinal++) {
      if (existingOrdinals.contains(ordinal)) continue;
      await createChapter(
        schoolId: schoolId,
        subjectId: subjectId,
        ordinal: ordinal,
        title: 'Chapter $ordinal',
      );
    }
  }

  /// Queues a material for upload. The bytes are handed to the blob store and
  /// a local `materials` row is inserted at `pending` immediately -- the
  /// teacher never waits for a connection. On reconnect, the sync engine
  /// drains the queued insert, uploads the bytes to Storage, and `pg_cron`
  /// walks the row through `pack_ready` -> `pool_ready` -> `ready`.
  ///
  /// This is a tier-1 append (`queueInsert` on `materials`), not a
  /// `PendingIntents` entry -- that table is for network-shaped work such as
  /// a Gemini call, and a file upload has no such call to make locally.
  Future<String> queueMaterialUpload({
    required String schoolId,
    required String chapterId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final String extension = _extensionOf(fileName);
    if (!_acceptedExtensions.contains(extension)) {
      throw const MaterialRejected(
        "This file format isn't supported for materials. "
        'Export to PDF, or save it as a PNG or JPG image, then upload that instead.',
      );
    }

    if (bytes.length > maxMaterialBytes) {
      throw const MaterialRejected(
        'This file is larger than the 20 MB upload limit. '
        'Split it into smaller files or compress it, then try again.',
      );
    }

    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();
    final String mime = _mimeFor(extension);

    await _blobStore.write(id, bytes);

    await _db.into(_db.materials).insert(
          MaterialsCompanion.insert(
            id: id,
            schoolId: schoolId,
            chapterId: chapterId,
            mime: mime,
            ingestionStatus: const Value('pending'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _outbox.queueInsert(
      table: 'materials',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'chapter_id': chapterId,
        'storage_path': null,
        'mime': mime,
        'ingestion_status': 'pending',
      },
    );

    return id;
  }

  /// Every chapter of every subject [classId] takes, alongside whether (and
  /// when) this class has been taught it. Two classes on the same subject
  /// never share a row here -- the left join keys off `class_chapter_sched`'s
  /// `(class_id, chapter_id)` pair, not just `chapter_id` -- so one class can
  /// sit several chapters ahead of another on an identical syllabus.
  Stream<List<ScheduleEntry>> watchScheduleForClass(String classId) {
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.classSubjects).join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        _db.subjects,
        _db.subjects.id.equalsExp(_db.classSubjects.subjectId),
      ),
      innerJoin(
        _db.chapters,
        _db.chapters.subjectId.equalsExp(_db.subjects.id),
      ),
      leftOuterJoin(
        _db.classChapterSched,
        _db.classChapterSched.chapterId.equalsExp(_db.chapters.id) &
            _db.classChapterSched.classId.equalsExp(_db.classSubjects.classId) &
            _db.classChapterSched.deletedAt.isNull(),
      ),
    ])
          ..where(_db.classSubjects.classId.equals(classId) &
              _db.classSubjects.deletedAt.isNull() &
              _db.subjects.deletedAt.isNull() &
              _db.chapters.deletedAt.isNull())
          ..orderBy(<OrderingTerm>[
            OrderingTerm.asc(_db.subjects.name),
            OrderingTerm.asc(_db.chapters.ordinal),
          ]);

    return query.watch().map((List<TypedResult> rows) {
      return rows.map((TypedResult row) {
        final Subject subject = row.readTable(_db.subjects);
        final Chapter chapter = row.readTable(_db.chapters);
        final ClassChapterSchedData? sched =
            row.readTableOrNull(_db.classChapterSched);
        return ScheduleEntry(
          chapterId: chapter.id,
          chapterTitle: chapter.title,
          chapterOrdinal: chapter.ordinal,
          subjectId: subject.id,
          subjectName: subject.name,
          taughtOn: sched?.taughtOn,
        );
      }).toList();
    });
  }

  /// The number of not-yet-synced schedule writes -- i.e. outbox rows for
  /// `class_chapter_sched` -- so the editor can show a pending count while
  /// offline without depending on [SyncEngine] being wired up.
  Stream<int> watchPendingScheduleWrites() {
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.selectOnly(_db.outbox)
          ..addColumns(<Expression<Object>>[_db.outbox.id.count()])
          ..where(_db.outbox.table.equals('class_chapter_sched'));
    return query
        .watchSingle()
        .map((TypedResult row) => row.read(_db.outbox.id.count()) ?? 0);
  }

  /// Finds the `class_chapter_sched` row for (classId, chapterId), creating
  /// it first if this is the class's first ever schedule write for that
  /// chapter. Rows are not seeded up front for every (class, chapter) pair
  /// -- a class-subject can be assigned long before any chapter is ever
  /// marked taught, and seeding would mean writing thousands of rows most
  /// schools would never touch. Creating the row is purely local
  /// bookkeeping (it mirrors a row the server already has for every
  /// class-subject-chapter combination), so it is never queued as an
  /// outbox insert -- only the `taught_on` field write below goes through
  /// the outbox, and only ever as a delta.
  Future<ClassChapterSchedData> _ensureScheduleRow({
    required String schoolId,
    required String classId,
    required String chapterId,
  }) async {
    final ClassChapterSchedData? existing = await (_db.select(
      _db.classChapterSched,
    )..where(($ClassChapterSchedTable t) =>
            t.classId.equals(classId) &
            t.chapterId.equals(chapterId) &
            t.deletedAt.isNull()))
        .getSingleOrNull();
    if (existing != null) return existing;

    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();
    final ClassChapterSchedCompanion companion =
        ClassChapterSchedCompanion.insert(
      id: id,
      schoolId: schoolId,
      classId: classId,
      chapterId: chapterId,
      taughtOn: const Value(null),
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.classChapterSched).insert(companion);
    return (_db.select(_db.classChapterSched)
          ..where(($ClassChapterSchedTable t) => t.id.equals(id)))
        .getSingle();
  }

  /// Records that [classId] taught [chapterId] on [taughtOn]. This is a
  /// tier-2 field write -- it queues a `delta` on `taught_on`, never an
  /// `insert` -- because the row itself already exists (or was just
  /// created locally above) on the server's side of the mirror.
  Future<void> markChapterTaught({
    required String schoolId,
    required String classId,
    required String chapterId,
    required DateTime taughtOn,
  }) async {
    final ClassChapterSchedData row = await _ensureScheduleRow(
      schoolId: schoolId,
      classId: classId,
      chapterId: chapterId,
    );

    await _outbox.queueDelta(
      table: 'class_chapter_sched',
      rowId: row.id,
      field: 'taught_on',
      observedValue: row.taughtOn?.toIso8601String(),
      newValue: taughtOn.toIso8601String(),
    );

    await (_db.update(_db.classChapterSched)
          ..where(($ClassChapterSchedTable t) => t.id.equals(row.id)))
        .write(ClassChapterSchedCompanion(taughtOn: Value(taughtOn)));
  }

  /// Returns [chapterId] to untaught for [classId] by deltaing `taught_on`
  /// back to null. A no-op (no delta queued) if the class never had a
  /// schedule row for this chapter in the first place -- there is nothing
  /// to clear.
  Future<void> clearChapterTaught({
    required String classId,
    required String chapterId,
  }) async {
    final ClassChapterSchedData? row = await (_db.select(
      _db.classChapterSched,
    )..where(($ClassChapterSchedTable t) =>
            t.classId.equals(classId) &
            t.chapterId.equals(chapterId) &
            t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return;

    await _outbox.queueDelta(
      table: 'class_chapter_sched',
      rowId: row.id,
      field: 'taught_on',
      observedValue: row.taughtOn?.toIso8601String(),
      newValue: null,
    );

    await (_db.update(_db.classChapterSched)
          ..where(($ClassChapterSchedTable t) => t.id.equals(row.id)))
        .write(const ClassChapterSchedCompanion(taughtOn: Value(null)));
  }

  String _extensionOf(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  String _mimeFor(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
