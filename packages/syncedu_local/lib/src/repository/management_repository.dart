import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../sync/outbox_writer.dart';

/// One row parsed from a roster CSV, or typed in directly for a single
/// teacher. [role] defaults to `'teacher'` at the call site -- this
/// repository does not enforce a role, since `provision-users` accepts any
/// role in its batch.
class RosterRow {
  const RosterRow({
    required this.email,
    required this.fullName,
    this.role = 'teacher',
  });

  final String email;
  final String fullName;
  final String role;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'fullName': fullName,
        'role': role,
      };
}

/// A caller's choice for a conflict in [LocalConflicts]: keep what this
/// device attempted, or accept the server's value.
enum ConflictResolution { keepMine, keepServer }

/// Local-first reads and writes for classes, teachers and students. Nothing
/// here touches the network: tier-1 writes land in the mirror and the
/// outbox, tier-3 field changes queue a delta carrying the value this device
/// last observed, and anything that needs an account created (teacher
/// provisioning) is recorded as a [PendingIntents] row for the sync engine
/// to execute on reconnect -- exactly the pattern that table's own doc
/// comment describes for "work that needs the network by nature".
class ManagementRepository {
  ManagementRepository(this._db, this._outbox);

  final SyncEduDatabase _db;
  final OutboxWriter _outbox;

  static const Uuid _uuid = Uuid();

  Stream<List<ClassesData>> watchClasses(String schoolId) {
    return (_db.select(_db.classes)
          ..where(($ClassesTable t) =>
              t.schoolId.equals(schoolId) & t.deletedAt.isNull()))
        .watch();
  }

  Stream<List<Profile>> watchTeachers(String schoolId) {
    return (_db.select(_db.profiles)
          ..where(($ProfilesTable t) =>
              t.schoolId.equals(schoolId) &
              t.role.equals('teacher') &
              t.deletedAt.isNull()))
        .watch();
  }

  Stream<Student?> watchStudent(String studentId) {
    return (_db.select(_db.students)
          ..where(($StudentsTable t) =>
              t.id.equals(studentId) & t.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  /// Creates a class. `targetLearningStyle` is tier-3 on later edits, but on
  /// creation there is no prior observed value to race against, so it is
  /// written straight into the tier-1 insert like every other starting
  /// field.
  Future<String> createClass({
    required String schoolId,
    required String name,
    required int yearLevel,
    String? targetLearningStyle,
  }) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();

    await _db.into(_db.classes).insert(
          ClassesCompanion.insert(
            id: id,
            schoolId: schoolId,
            name: name,
            yearLevel: yearLevel,
            targetLearningStyle: Value(targetLearningStyle),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _outbox.queueInsert(
      table: 'classes',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'name': name,
        'year_level': yearLevel,
        'target_learning_style': targetLearningStyle,
      },
    );

    return id;
  }

  /// Assigns a teacher to a class for a subject. This is a tier-1 append --
  /// reassigning later is a new `class_subjects` row, not an edit of this
  /// one.
  Future<String> assignTeacherToClass({
    required String schoolId,
    required String classId,
    required String subjectId,
    required String teacherId,
  }) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();

    await _db.into(_db.classSubjects).insert(
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

    await _outbox.queueInsert(
      table: 'class_subjects',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'class_id': classId,
        'subject_id': subjectId,
        'teacher_id': teacherId,
      },
    );

    return id;
  }

  /// Queues account creation for one teacher. Creating an auth user needs
  /// the network by nature, so this never writes a `profiles` row itself --
  /// it only records the intent; the sync engine executes `provision-users`
  /// on reconnect and the profile arrives back through the ordinary pull.
  Future<String> queueTeacherProvisioning({
    required String schoolId,
    required String email,
    required String fullName,
  }) {
    return queueRosterImport(
      schoolId: schoolId,
      rows: <RosterRow>[RosterRow(email: email, fullName: fullName)],
    );
  }

  /// Queues one `provision-users` intent covering every row of a validated
  /// CSV import. One intent per import (not one per row) so the pending
  /// tray shows a single "roster import" entry rather than flooding it with
  /// one row per teacher.
  Future<String> queueRosterImport({
    required String schoolId,
    required List<RosterRow> rows,
  }) async {
    final String id = _uuid.v4();
    final String payload = jsonEncode(<String, dynamic>{
      'schoolId': schoolId,
      'users': rows.map((RosterRow r) => r.toJson()).toList(),
    });

    await _db.into(_db.pendingIntents).insert(
          PendingIntentsCompanion.insert(
            id: id,
            functionName: 'provision-users',
            payload: payload,
            createdAt: DateTime.now().toUtc(),
          ),
        );

    return id;
  }

  Stream<int> watchPendingIntentCount() {
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.selectOnly(_db.pendingIntents)
          ..addColumns(<Expression<Object>>[_db.pendingIntents.id.count()])
          ..where(_db.pendingIntents.status.equals('pending'));
    return query
        .watchSingle()
        .map((TypedResult row) => row.read(_db.pendingIntents.id.count()) ?? 0);
  }

  /// Changes a student's special-needs labels. Tier-3: the delta carries
  /// [observedValue] read from the row this device currently has, so a
  /// stale write is rejected server-side rather than silently clobbering a
  /// colleague's concurrent change.
  Future<void> updateStudentSpecialNeeds({
    required String studentId,
    required List<String> newSpecialNeeds,
  }) async {
    final Student student = await (_db.select(_db.students)
          ..where(($StudentsTable t) =>
              t.id.equals(studentId) & t.deletedAt.isNull()))
        .getSingle();

    final List<String> observed =
        (jsonDecode(student.specialNeeds) as List<dynamic>).cast<String>();

    await _outbox.queueDelta(
      table: 'students',
      rowId: studentId,
      field: 'special_needs',
      observedValue: observed,
      newValue: newSpecialNeeds,
    );

    await (_db.update(_db.students)
          ..where(($StudentsTable t) => t.id.equals(studentId)))
        .write(StudentsCompanion(
      specialNeeds: Value(jsonEncode(newSpecialNeeds)),
    ));
  }

  /// Moves a student to a different class. Tier-3, same reasoning as above:
  /// `class_id` is contended (a teacher and an admin could both be moving
  /// the same student at once), so the delta carries the class this device
  /// last saw the student in.
  Future<void> moveStudentToClass({
    required String studentId,
    required String newClassId,
  }) async {
    final Student student = await (_db.select(_db.students)
          ..where(($StudentsTable t) =>
              t.id.equals(studentId) & t.deletedAt.isNull()))
        .getSingle();

    await _outbox.queueDelta(
      table: 'students',
      rowId: studentId,
      field: 'class_id',
      observedValue: student.classId,
      newValue: newClassId,
    );

    await (_db.update(_db.students)
          ..where(($StudentsTable t) => t.id.equals(studentId)))
        .write(StudentsCompanion(classId: Value(newClassId)));
  }

  /// Unresolved conflicts, oldest first, for the conflict tray.
  Stream<List<LocalConflict>> watchConflicts() {
    return (_db.select(_db.localConflicts)
          ..where(($LocalConflictsTable t) => t.resolvedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$LocalConflictsTable>>[
            ($LocalConflictsTable t) => OrderingTerm.asc(t.detectedAt),
          ]))
        .watch();
  }

  /// Records an administrator's choice for one conflict and marks it
  /// resolved so it drops out of [watchConflicts]. Applying [keepMine] means
  /// re-queuing the attempted value as a fresh delta (with the server's
  /// value as the new observed baseline); [keepServer] means accepting the
  /// server's value into the local mirror. Both are best-effort local
  /// bookkeeping -- the authoritative outcome is still whatever the server
  /// accepts on the next sync.
  Future<void> resolveConflict(String id, ConflictResolution resolution) async {
    final LocalConflict conflict = await (_db.select(_db.localConflicts)
          ..where(($LocalConflictsTable t) => t.id.equals(id)))
        .getSingle();

    if (resolution == ConflictResolution.keepMine &&
        conflict.attemptedValue != null) {
      await _outbox.queueDelta(
        table: conflict.table,
        rowId: conflict.rowId,
        field: conflict.field,
        observedValue: conflict.serverValue == null
            ? null
            : jsonDecode(conflict.serverValue!),
        newValue:
            conflict.attemptedValue == null ? null : jsonDecode(conflict.attemptedValue!),
      );
    }

    await (_db.update(_db.localConflicts)
          ..where(($LocalConflictsTable t) => t.id.equals(id)))
        .write(LocalConflictsCompanion(
      resolvedAt: Value(DateTime.now().toUtc()),
    ));
  }
}
