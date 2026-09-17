import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../sync/outbox_writer.dart';

/// One teacher's note about a student, joined out to the author's name.
class ObservationRow {
  const ObservationRow({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.teacherName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String teacherId;
  final String teacherName;
  final String body;
  final DateTime createdAt;
}

/// Local-first reads and writes for `teacher_observations`.
///
/// This is tier-1, append-only data (spec §5): a teacher's note about a
/// student is never edited or overwritten locally, and two teachers writing
/// about the same student at the same time produce two independent rows.
/// [addObservation] therefore always goes through [OutboxWriter.queueInsert]
/// -- never `queueDelta` -- and there is no update or delete method here.
class ObservationRepository {
  ObservationRepository(this._db, this._outbox);

  final SyncEduDatabase _db;
  final OutboxWriter _outbox;

  static const Uuid _uuid = Uuid();

  /// A student's observations, newest first, each with its author's name.
  /// Soft-deleted rows (on either the observation or the author's profile)
  /// are excluded.
  Stream<List<ObservationRow>> watchObservations(String studentId) {
    final JoinedSelectStatement<HasResultSet, dynamic> query = _db
        .select(_db.teacherObservations)
        .join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        _db.profiles,
        _db.profiles.id.equalsExp(_db.teacherObservations.teacherId),
      ),
    ])
          ..where(_db.teacherObservations.studentId.equals(studentId) &
              _db.teacherObservations.deletedAt.isNull() &
              _db.profiles.deletedAt.isNull())
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(_db.teacherObservations.createdAt),
          ]);

    return query.watch().map((List<TypedResult> rows) {
      return rows.map((TypedResult row) {
        final TeacherObservation observation =
            row.readTable(_db.teacherObservations);
        final Profile teacher = row.readTable(_db.profiles);
        return ObservationRow(
          id: observation.id,
          studentId: observation.studentId,
          teacherId: observation.teacherId,
          teacherName: teacher.fullName,
          body: observation.body,
          createdAt: observation.createdAt,
        );
      }).toList(growable: false);
    });
  }

  /// Appends a new observation. The local row appears immediately -- the
  /// teacher never waits on a connection -- and the queued insert is drained
  /// by the sync engine whenever one is available.
  Future<String> addObservation({
    required String schoolId,
    required String studentId,
    required String teacherId,
    required String body,
  }) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();

    await _db.into(_db.teacherObservations).insert(
          TeacherObservationsCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            teacherId: teacherId,
            body: body,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _outbox.queueInsert(
      table: 'teacher_observations',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'teacher_id': teacherId,
        'body': body,
      },
    );

    return id;
  }
}
