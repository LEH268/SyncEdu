import 'package:drift/drift.dart';
import 'package:syncedu_core/syncedu_core.dart';

import '../db/database.dart';

/// Bridges the local mirror to the row shapes Phase 5's analytics functions
/// consume. Every console screen reads through here rather than composing
/// its own join, so a figure is computed the same way everywhere it appears.
class AnalyticsRepository {
  AnalyticsRepository(this._db);

  final SyncEduDatabase _db;

  /// One row per graded attempt item, joined out to the labels the analytics
  /// functions need for display. A `leftOuterJoin` on classes is deliberate:
  /// `students.classId` is nullable, and a newly-imported student who has not
  /// been placed into a class yet must still appear in the unfiltered stream.
  Stream<List<AnalyticRow>> watchRows({String? classId}) =>
      _rowQuery(classId).watch().map(
            (List<TypedResult> rows) => rows
                .map((TypedResult row) => _toAnalyticRow(row))
                .toList(growable: false),
          );

  /// The same rows, read once.
  ///
  /// Not `watchRows().first`: a stream's first event depends on the query
  /// stream machinery scheduling an emission, which does not happen inside
  /// `flutter_test`'s fake-async zone -- a caller in a widget would simply
  /// hang. A screen that needs a snapshot rather than a subscription reads
  /// through here, and the join itself is shared so the two paths cannot
  /// drift apart.
  Future<List<AnalyticRow>> readRows({String? classId}) =>
      _rowQuery(classId).get().then(
            (List<TypedResult> rows) => rows
                .map((TypedResult row) => _toAnalyticRow(row))
                .toList(growable: false),
          );

  JoinedSelectStatement<HasResultSet, dynamic> _rowQuery(String? classId) {
    final JoinedSelectStatement<HasResultSet, dynamic> query =
        _db.select(_db.attemptItems).join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        _db.attempts,
        _db.attempts.id.equalsExp(_db.attemptItems.attemptId),
      ),
      innerJoin(
        _db.students,
        _db.students.id.equalsExp(_db.attempts.studentId),
      ),
      innerJoin(
        _db.profiles,
        _db.profiles.id.equalsExp(_db.students.profileId),
      ),
      leftOuterJoin(
        _db.classes,
        _db.classes.id.equalsExp(_db.students.classId),
      ),
      innerJoin(
        _db.microSkills,
        _db.microSkills.id.equalsExp(_db.attemptItems.microSkillId),
      ),
      innerJoin(
        _db.chapters,
        _db.chapters.id.equalsExp(_db.microSkills.chapterId),
      ),
      innerJoin(
        _db.subjects,
        _db.subjects.id.equalsExp(_db.chapters.subjectId),
      ),
    ])
          ..where(_db.attemptItems.deletedAt.isNull() &
              _db.attempts.deletedAt.isNull() &
              _db.students.deletedAt.isNull() &
              _db.profiles.deletedAt.isNull() &
              // leftOuterJoin means a classless student has no class row at
              // all (classId.isNull()); when a class row IS present it must
              // not be a soft-deleted one.
              (_db.classes.id.isNull() | _db.classes.deletedAt.isNull()) &
              _db.microSkills.deletedAt.isNull() &
              _db.chapters.deletedAt.isNull() &
              _db.subjects.deletedAt.isNull());

    if (classId != null) {
      query.where(_db.students.classId.equals(classId));
    }

    return query;
  }

  AnalyticRow _toAnalyticRow(TypedResult row) {
    final AttemptItem item = row.readTable(_db.attemptItems);
    final Attempt attempt = row.readTable(_db.attempts);
    final Student student = row.readTable(_db.students);
    final Profile profile = row.readTable(_db.profiles);
    final ClassesData? klass = row.readTableOrNull(_db.classes);
    final MicroSkill microSkill = row.readTable(_db.microSkills);
    final Chapter chapter = row.readTable(_db.chapters);
    final Subject subject = row.readTable(_db.subjects);

    return AnalyticRow(
      studentId: student.id,
      studentName: profile.fullName,
      classId: klass?.id ?? '',
      className: klass?.name ?? '',
      chapterId: chapter.id,
      chapterTitle: chapter.title,
      microSkillId: microSkill.id,
      microSkillLabel: microSkill.label,
      subjectName: subject.name,
      isCorrect: item.isCorrect,
      submittedAt: attempt.submittedAt ?? attempt.createdAt,
      mode: attempt.mode,
      attemptId: attempt.id,
    );
  }

  /// One row per attempt (not per item), for retry-chain and progress-curve
  /// analytics.
  Stream<List<AttemptRow>> watchAttempts({String? studentId}) {
    final SimpleSelectStatement<$AttemptsTable, Attempt> query =
        _db.select(_db.attempts)
          ..where(($AttemptsTable t) => t.deletedAt.isNull());

    if (studentId != null) {
      query.where(($AttemptsTable t) => t.studentId.equals(studentId));
    }

    return query.watch().map(
          (List<Attempt> rows) => rows
              .map((Attempt row) => AttemptRow(
                    id: row.id,
                    studentId: row.studentId,
                    parentAttemptId: row.parentAttemptId,
                    attemptNumber: row.attemptNumber,
                    score: row.score,
                    questionCount: row.questionCount,
                    submittedAt: row.submittedAt ?? row.createdAt,
                    mode: row.mode,
                  ))
              .toList(growable: false),
        );
  }

  /// One row per detected weakness, for the at-risk list and resource
  /// allocation recommendations.
  Stream<List<WeaknessRow>> watchWeaknesses({String? studentId}) {
    final SimpleSelectStatement<$WeaknessesTable, WeaknessesData> query =
        _db.select(_db.weaknesses)
          ..where(($WeaknessesTable t) => t.deletedAt.isNull());

    if (studentId != null) {
      query.where(($WeaknessesTable t) => t.studentId.equals(studentId));
    }

    return query.watch().map(
          (List<WeaknessesData> rows) => rows
              .map((WeaknessesData row) => WeaknessRow(
                    studentId: row.studentId,
                    microSkillId: row.microSkillId,
                    source: row.source,
                    weight: row.weight,
                  ))
              .toList(growable: false),
        );
  }
}
