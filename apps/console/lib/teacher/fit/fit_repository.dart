import 'package:drift/drift.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:uuid/uuid.dart';

import '../../functions/console_functions.dart';

/// The inputs to the Class Fit Analyzer that the console computes in Dart.
class FitInputs {
  const FitInputs({
    required this.studentName,
    required this.academicPct,
    required this.studentPct,
    required this.latestObservation,
  });

  final String studentName;

  /// Mean revision-quiz accuracy, 0–100, or null with no revision history.
  final double? academicPct;

  /// The student's year-end self-report, 0–100, or null if none submitted.
  final double? studentPct;

  final String? latestObservation;
}

/// The finished analysis: a Dart-composed score with its own 40/30/30
/// breakdown, plus a recommendation the console labels ai or rule.
class FitResult {
  const FitResult({
    required this.score,
    required this.recommendation,
    required this.source,
  });

  final FitScore score;
  final String recommendation;

  /// 'ai' when the model wrote the recommendation, 'rule' when
  /// [ruleBasedRecommendation] stood in.
  final String source;
}

class FitRepository {
  FitRepository({required SyncEduDatabase db, required this.functions})
      : _db = db,
        _outbox = OutboxWriter(db);

  final SyncEduDatabase _db;
  final OutboxWriter _outbox;
  final ConsoleFunctions functions;
  static const Uuid _uuid = Uuid();

  Future<FitInputs> inputsFor(String studentId) async {
    final Student student = await (_db.select(_db.students)
          ..where(($StudentsTable t) => t.id.equals(studentId)))
        .getSingle();
    final Profile? profile = await (_db.select(_db.profiles)
          ..where(($ProfilesTable p) => p.id.equals(student.profileId)))
        .getSingleOrNull();

    // academic %: mean accuracy over this student's revise-mode attempts.
    final List<Attempt> attempts = await (_db.select(_db.attempts)
          ..where(($AttemptsTable t) =>
              t.studentId.equals(studentId) &
              t.mode.equals('revise') &
              t.submittedAt.isNotNull() &
              t.deletedAt.isNull()))
        .get();
    double? academic;
    if (attempts.isNotEmpty) {
      final int q = attempts.fold(0, (int s, Attempt a) => s + a.questionCount);
      final int c = attempts.fold(0, (int s, Attempt a) => s + a.score);
      academic = q == 0 ? null : (c / q) * 100;
    }

    final YearEndReflection? reflection = await (_db.select(_db.yearEndReflections)
          ..where(($YearEndReflectionsTable t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$YearEndReflectionsTable>>[
            ($YearEndReflectionsTable t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .getSingleOrNull();

    final TeacherObservation? observation = await (_db.select(_db.teacherObservations)
          ..where(($TeacherObservationsTable t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$TeacherObservationsTable>>[
            ($TeacherObservationsTable t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get()
        .then((List<TeacherObservation> r) => r.isEmpty ? null : r.first);

    return FitInputs(
      studentName: profile?.fullName ?? 'Student',
      academicPct: academic,
      studentPct: reflection?.studentPct,
      latestObservation: observation?.body,
    );
  }

  /// Scores the observation via `analyse-fit`, composes the 40/30/30 score in
  /// Dart, and persists the analysis. On any model failure the recommendation
  /// comes from [ruleBasedRecommendation] and `source` is 'rule'.
  Future<FitResult> analyse({
    required String schoolId,
    required String studentId,
    required String observationText,
    required double? academicPct,
    required double? studentPct,
  }) async {
    double? teacherPct;
    String? aiRecommendation;
    String source = 'rule';

    if (functions.online) {
      try {
        final Map<String, dynamic> r = await functions.analyseFit(<String, dynamic>{
          'studentId': studentId,
          'observationText': observationText,
          'academicPct': academicPct,
          'studentPct': studentPct,
        });
        teacherPct = (r['teacherPct'] as num?)?.toDouble();
        aiRecommendation = r['recommendation'] as String?;
        source = r['source'] as String? ?? 'rule';
      } catch (_) {
        source = 'rule';
      }
    }

    final FitScore score = composeFitScore(
      academicPct: academicPct,
      studentPct: studentPct,
      teacherPct: teacherPct,
    );

    final String recommendation = aiRecommendation != null && aiRecommendation.isNotEmpty
        ? aiRecommendation
        : (score.score == null
            ? 'Not enough information to recommend anything yet.'
            : ruleBasedRecommendation(score.score!));
    if (aiRecommendation == null || aiRecommendation.isEmpty) source = 'rule';

    await _persist(
      schoolId: schoolId,
      studentId: studentId,
      score: score,
      academicPct: academicPct,
      studentPct: studentPct,
      teacherPct: teacherPct,
      recommendation: recommendation,
      source: source,
    );

    return FitResult(score: score, recommendation: recommendation, source: source);
  }

  Future<void> _persist({
    required String schoolId,
    required String studentId,
    required FitScore score,
    required double? academicPct,
    required double? studentPct,
    required double? teacherPct,
    required String recommendation,
    required String source,
  }) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();
    final String? verdict = score.verdict == null
        ? null
        : switch (score.verdict!) {
            FitVerdict.greatFit => 'great_fit',
            FitVerdict.acceptable => 'acceptable',
            FitVerdict.mismatch => 'mismatch',
            FitVerdict.strongMismatch => 'strong_mismatch',
          };

    await _db.into(_db.fitAnalyses).insert(
          FitAnalysesCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            academicPct: Value(academicPct),
            studentPct: Value(studentPct),
            fitScore: Value(score.score),
            verdict: Value(verdict),
            recommendation: Value(recommendation),
            source: Value(source),
            teacherPct: Value(teacherPct),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _outbox.queueInsert(
      table: 'fit_analyses',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'academic_pct': academicPct,
        'student_pct': studentPct,
        'teacher_pct': teacherPct,
        'fit_score': score.score,
        'verdict': verdict,
        'recommendation': recommendation,
        'source': source,
      },
    );
  }
}
