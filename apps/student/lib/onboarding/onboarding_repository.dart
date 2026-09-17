import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:uuid/uuid.dart';

/// Local-first reads and writes for the two mandatory instruments: the
/// Pre-admission Test and the Year-End Reflection. Nothing here touches the
/// network — a row is written to the mirror and queued in the outbox, and the
/// sync engine drains it when it can. Both instruments therefore work fully
/// offline (spec §8.1).
class OnboardingRepository {
  OnboardingRepository(this._db) : _outbox = OutboxWriter(_db);

  final SyncEduDatabase _db;
  final OutboxWriter _outbox;
  static const Uuid _uuid = Uuid();

  Future<String?> studentIdForProfile(String profileId) async {
    final Student? row = await (_db.select(_db.students)
          ..where(($StudentsTable t) =>
              t.profileId.equals(profileId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row?.id;
  }

  Stream<Student?> watchStudent(String profileId) =>
      (_db.select(_db.students)
            ..where(($StudentsTable t) =>
                t.profileId.equals(profileId) & t.deletedAt.isNull()))
          .watchSingleOrNull();

  // ── Pre-admission ───────────────────────────────────────────────────────

  Future<bool> hasPreAdmissionResult(String studentId) async {
    final int count = await (_db.selectOnly(_db.preAdmissionResults)
          ..addColumns(<Expression<Object>>[_db.preAdmissionResults.id])
          ..where(_db.preAdmissionResults.studentId.equals(studentId) &
              _db.preAdmissionResults.deletedAt.isNull()))
        .get()
        .then((List<TypedResult> r) => r.length);
    return count > 0;
  }

  /// Scores [answers] locally, writes the result row and lifts the router
  /// gate by stamping the local student row. The server trigger
  /// (`mark_pre_admission_complete`) is authoritative and agrees, because it
  /// only ever sets the stamp when it is still null.
  Future<PreAdmissionProfile> submitPreAdmission({
    required String studentId,
    required String schoolId,
    required List<int> answers,
  }) async {
    final PreAdmissionProfile profile = scoreInstrument(answers);
    final DateTime now = DateTime.now().toUtc();
    final String id = _uuid.v4();

    final Map<String, dynamic> row = <String, dynamic>{
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'vark': profile.vark,
      'structured': profile.structured,
      'exploratory': profile.exploratory,
      'introvert': profile.introvert,
      'extrovert': profile.extrovert,
      'impulsivity': profile.impulsivity,
      'reflectivity': profile.reflectivity,
      'dominant_style': profile.dominantStyle,
      'answers': answers,
    };

    await _db.into(_db.preAdmissionResults).insert(
          PreAdmissionResultsCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            vark: Value(jsonEncode(profile.vark)),
            structured: Value(profile.structured),
            exploratory: Value(profile.exploratory),
            introvert: Value(profile.introvert),
            extrovert: Value(profile.extrovert),
            impulsivity: Value(profile.impulsivity),
            reflectivity: Value(profile.reflectivity),
            dominantStyle: profile.dominantStyle,
            answers: Value(jsonEncode(answers)),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _outbox.queueInsert(table: 'pre_admission_results', row: row);

    await (_db.update(_db.students)
          ..where(($StudentsTable t) => t.id.equals(studentId)))
        .write(StudentsCompanion(preAdmissionCompletedAt: Value(now)));

    return profile;
  }

  // ── Year-End Reflection ─────────────────────────────────────────────────

  /// The open campaign, if any, the student has not yet answered.
  Future<ReflectionCampaign?> openUnansweredCampaign(String studentId) async {
    final List<ReflectionCampaign> open = await (_db.select(_db.reflectionCampaigns)
          ..where(($ReflectionCampaignsTable t) =>
              t.closedAt.isNull() & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ReflectionCampaignsTable>>[
            ($ReflectionCampaignsTable t) => OrderingTerm.desc(t.openedAt),
          ]))
        .get();
    for (final ReflectionCampaign campaign in open) {
      final YearEndReflection? existing =
          await (_db.select(_db.yearEndReflections)
                ..where(($YearEndReflectionsTable t) =>
                    t.studentId.equals(studentId) &
                    t.academicYear.equals(campaign.academicYear) &
                    t.deletedAt.isNull()))
              .getSingleOrNull();
      if (existing == null) return campaign;
    }
    return null;
  }

  Stream<List<ReflectionCampaign>> watchOpenCampaigns() =>
      (_db.select(_db.reflectionCampaigns)
            ..where(($ReflectionCampaignsTable t) =>
                t.closedAt.isNull() & t.deletedAt.isNull()))
          .watch();

  Stream<List<YearEndReflection>> watchReflections(String studentId) =>
      (_db.select(_db.yearEndReflections)
            ..where(($YearEndReflectionsTable t) =>
                t.studentId.equals(studentId) & t.deletedAt.isNull()))
          .watch();

  /// Records the student's answers. `studentPct` is the 0–100 self-report the
  /// Class Fit Analyzer's 30% component reads; it is the mean of the Likert
  /// answers, computed here in Dart.
  Future<void> submitReflection({
    required String studentId,
    required String schoolId,
    required ReflectionCampaign campaign,
    required Map<String, int> likertAnswers,
    String? freeText,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final String id = _uuid.v4();

    final double? studentPct = likertAnswers.isEmpty
        ? null
        : (likertAnswers.values.reduce((int a, int b) => a + b) /
                (likertAnswers.length * 5)) *
            100;

    final Map<String, dynamic> responses = <String, dynamic>{
      'likert': likertAnswers,
      if (freeText != null && freeText.trim().isNotEmpty) 'note': freeText.trim(),
    };
    final Map<String, dynamic> row = <String, dynamic>{
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'campaign_id': campaign.id,
      'academic_year': campaign.academicYear,
      'responses': responses,
      'student_pct': studentPct,
    };

    await _db.into(_db.yearEndReflections).insert(
          YearEndReflectionsCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            campaignId: Value(campaign.id),
            academicYear: campaign.academicYear,
            responses: Value(jsonEncode(responses)),
            studentPct: Value(studentPct),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _outbox.queueInsert(table: 'year_end_reflections', row: row);
  }
}
