import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../sync/outbox_writer.dart';

class AnsweredQuestion {
  const AnsweredQuestion({required this.question, required this.selectedIndex});

  final PoolQuestion question;
  final int selectedIndex;

  bool get isCorrect => selectedIndex == question.correctIndex;
}

class AttemptDraft {
  const AttemptDraft({
    required this.studentId,
    required this.schoolId,
    required this.chapterIds,
    required this.mode,
    required this.answers,
    this.parentAttemptId,
  });

  final String studentId;
  final String schoolId;
  final List<String> chapterIds;
  final QuizMode mode;
  final List<AnsweredQuestion> answers;
  final String? parentAttemptId;
}

/// Local-first reads and writes for the quiz loop. Nothing here touches the
/// network: writes land in the mirror and the outbox, and the sync engine
/// drains them whenever it can.
class QuizRepository {
  QuizRepository(this._db, this._outbox);

  final SyncEduDatabase _db;
  final OutboxWriter _outbox;

  /// Every id written here is also the `uuid` primary key of the matching
  /// Postgres row once the outbox drains, so it has to be a real UUID --
  /// anything else is rejected with `22P02` and strands the attempt forever.
  static const Uuid _uuid = Uuid();

  /// Resolves `students.id` for a signed-in profile. The auth user id in the
  /// JWT is `profiles.id`; every other method here keys off `students.id`,
  /// which is a different uuid. Returns null while the student row has not
  /// been pulled into the mirror yet -- callers must treat that as "not ready"
  /// rather than substituting the profile id.
  Future<String?> studentIdForProfile(String profileId) async {
    final Student? row = await (_db.select(_db.students)
          ..where(($StudentsTable t) =>
              t.profileId.equals(profileId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row?.id;
  }

  Future<List<PoolQuestion>> poolFor(
    List<String> chapterIds,
    String studentId,
  ) async {
    final List<Question> rows = await (_db.select(_db.questions)
          ..where(($QuestionsTable t) =>
              t.chapterId.isIn(chapterIds) &
              t.deletedAt.isNull() &
              (t.provenance.equals('pool') | t.forStudentId.equals(studentId))))
        .get();

    return rows
        .map((Question row) => PoolQuestion(
              id: row.id,
              chapterId: row.chapterId,
              microSkillId: row.microSkillId,
              difficulty: row.difficulty,
              stem: row.stem,
              options: (jsonDecode(row.options) as List<dynamic>).cast<String>(),
              correctIndex: row.correctIndex,
              provenance: row.provenance,
              forStudentId: row.forStudentId,
              rationale: row.rationale,
            ))
        .toList();
  }

  /// Summed across sources, so an exam-sourced gap steers practice exactly as
  /// a quiz-sourced one does.
  Future<Map<String, double>> weaknessWeightsFor(String studentId) async {
    final List<WeaknessesData> rows = await (_db.select(_db.weaknesses)
          ..where(($WeaknessesTable t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull()))
        .get();

    final Map<String, double> weights = <String, double>{};
    for (final WeaknessesData row in rows) {
      weights.update(
        row.microSkillId,
        (double existing) => (existing + row.weight).clamp(0.0, 1.0),
        ifAbsent: () => row.weight,
      );
    }
    return weights;
  }

  Future<Set<String>> recentlySeenFor(
    String studentId, {
    int lastAttempts = 5,
  }) async {
    final List<Attempt> recent = await (_db.select(_db.attempts)
          ..where(($AttemptsTable t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$AttemptsTable>>[
            ($AttemptsTable t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(lastAttempts))
        .get();

    if (recent.isEmpty) return <String>{};

    final List<AttemptItem> items = await (_db.select(_db.attemptItems)
          ..where(($AttemptItemsTable t) =>
              t.attemptId.isIn(recent.map((Attempt a) => a.id).toList()) &
              t.deletedAt.isNull()))
        .get();

    return items
        .map((AttemptItem item) => item.questionId)
        .whereType<String>()
        .toSet();
  }

  /// Preview unless every chosen chapter has already been taught to this
  /// student's class. A mixed range counts as preview: grading untaught
  /// material would put it into the teacher's analytics.
  Future<QuizMode> modeFor(List<String> chapterIds, String studentId) async {
    final Student? student = await (_db.select(_db.students)
          ..where(($StudentsTable t) => t.id.equals(studentId)))
        .getSingleOrNull();

    final String? classId = student?.classId;
    if (classId == null) return QuizMode.prep;

    final List<ClassChapterSchedData> schedule = await (_db.select(_db.classChapterSched)
          ..where(($ClassChapterSchedTable t) =>
              t.classId.equals(classId) &
              t.chapterId.isIn(chapterIds) &
              t.deletedAt.isNull()))
        .get();

    final DateTime today = DateTime.now();
    final Set<String> taught = schedule
        .where((ClassChapterSchedData row) =>
            row.taughtOn != null && !row.taughtOn!.isAfter(today))
        .map((ClassChapterSchedData row) => row.chapterId)
        .toSet();

    return taught.length == chapterIds.toSet().length
        ? QuizMode.revise
        : QuizMode.prep;
  }

  Future<String> recordAttempt({required AttemptDraft draft}) async {
    final String attemptId = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();

    final int attemptNumber = draft.parentAttemptId == null
        ? 1
        : ((await (_db.select(_db.attempts)
                  ..where(($AttemptsTable t) => t.id.equals(draft.parentAttemptId!)))
                .getSingleOrNull())
                ?.attemptNumber ??
            0) +
            1;

    final int score = draft.answers.where((AnsweredQuestion a) => a.isCorrect).length;

    await _db.into(_db.attempts).insert(
          AttemptsCompanion.insert(
            id: attemptId,
            schoolId: draft.schoolId,
            studentId: draft.studentId,
            chapterIds: Value(jsonEncode(draft.chapterIds)),
            mode: draft.mode.name,
            attemptNumber: Value(attemptNumber),
            parentAttemptId: Value(draft.parentAttemptId),
            questionCount: draft.answers.length,
            score: Value(score),
            startedAt: Value(now),
            submittedAt: Value(now),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _outbox.queueInsert(
      table: 'attempts',
      row: <String, dynamic>{
        'id': attemptId,
        'school_id': draft.schoolId,
        'student_id': draft.studentId,
        'chapter_ids': draft.chapterIds,
        'mode': draft.mode.name,
        'attempt_number': attemptNumber,
        'parent_attempt_id': draft.parentAttemptId,
        'question_count': draft.answers.length,
        'score': score,
        'started_at': now.toIso8601String(),
        'submitted_at': now.toIso8601String(),
      },
    );

    for (final (int index, AnsweredQuestion answer) in draft.answers.indexed) {
      final String itemId = _uuid.v4();

      await _db.into(_db.attemptItems).insert(
            AttemptItemsCompanion.insert(
              id: itemId,
              schoolId: draft.schoolId,
              attemptId: attemptId,
              questionId: Value(answer.question.id),
              microSkillId: answer.question.microSkillId,
              selectedIndex: Value(answer.selectedIndex),
              isCorrect: answer.isCorrect,
              ordinal: index + 1,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _outbox.queueInsert(
        table: 'attempt_items',
        row: <String, dynamic>{
          'id': itemId,
          'school_id': draft.schoolId,
          'attempt_id': attemptId,
          'question_id': answer.question.id,
          'micro_skill_id': answer.question.microSkillId,
          'selected_index': answer.selectedIndex,
          'is_correct': answer.isCorrect,
          'ordinal': index + 1,
        },
      );
    }

    await _recomputeLocalWeaknesses(
      draft.studentId,
      draft.answers.map((AnsweredQuestion a) => a.question.microSkillId).toSet(),
    );

    return attemptId;
  }

  /// Mirrors `public.recompute_weaknesses` so the student's own view updates
  /// with no connection. The server recomputes authoritatively on sync; both
  /// read the same rows and apply the same formula, so they agree.
  Future<void> _recomputeLocalWeaknesses(
    String studentId,
    Set<String> microSkillIds,
  ) async {
    if (microSkillIds.isEmpty) return;

    final DateTime now = DateTime.now().toUtc();

    // Invariant across the loop, so it is read once rather than per skill.
    final Student? student = await (_db.select(_db.students)
          ..where(($StudentsTable t) => t.id.equals(studentId)))
        .getSingleOrNull();
    if (student == null) {
      // The student row has not been pulled into the mirror yet. The server
      // recomputes authoritatively on sync, so skipping the local mirror of
      // that computation loses nothing but an instant refresh.
      return;
    }

    for (final String skillId in microSkillIds) {
      final List<TypedResult> rows = await (_db.select(_db.attemptItems).join(
        <Join<HasResultSet, dynamic>>[
          innerJoin(_db.attempts, _db.attempts.id.equalsExp(_db.attemptItems.attemptId)),
        ],
      )..where(_db.attemptItems.microSkillId.equals(skillId) &
              _db.attempts.studentId.equals(studentId) &
              _db.attemptItems.deletedAt.isNull() &
              _db.attempts.deletedAt.isNull()))
          .get();

      final List<WeaknessObservation> observations = rows
          .map((TypedResult row) => WeaknessObservation(
                isCorrect: row.readTable(_db.attemptItems).isCorrect,
                at: row.readTable(_db.attempts).submittedAt ??
                    row.readTable(_db.attempts).createdAt,
              ))
          .toList();

      final double weight = weaknessWeight(observations: observations, now: now);

      // Conflict on (student, skill, source) rather than on the id: the
      // server writes its own `gen_random_uuid()` id for the same triple, and
      // a pull must land on this row rather than beside it.
      final WeaknessesCompanion row = WeaknessesCompanion.insert(
        id: _uuid.v4(),
        schoolId: student.schoolId,
        studentId: studentId,
        microSkillId: skillId,
        weight: weight,
        source: 'quiz',
        createdAt: now,
        updatedAt: now,
      );

      await _db.into(_db.weaknesses).insert(
            row,
            onConflict: DoUpdate(
              (_) => WeaknessesCompanion(weight: Value(weight), updatedAt: Value(now)),
              target: <Column<Object>>[
                _db.weaknesses.studentId,
                _db.weaknesses.microSkillId,
                _db.weaknesses.source,
              ],
            ),
          );
    }
  }

  /// Explanations keyed by micro-skill. A skill may have none or several, and
  /// the rows come back in no particular order, so callers must look up by id
  /// -- pairing a flat list against a set of skills by position silently shows
  /// one skill's explanation under another's heading.
  Future<Map<String, List<String>>> explanationsFor(
    Set<String> microSkillIds,
  ) async {
    if (microSkillIds.isEmpty) return <String, List<String>>{};

    final List<MicroSkillExplanation> rows =
        await (_db.select(_db.microSkillExplanations)
              ..where(($MicroSkillExplanationsTable t) =>
                  t.microSkillId.isIn(microSkillIds.toList()) & t.deletedAt.isNull()))
            .get();

    final Map<String, List<String>> bySkill = <String, List<String>>{};
    for (final MicroSkillExplanation row in rows) {
      bySkill.putIfAbsent(row.microSkillId, () => <String>[]).add(row.body);
    }
    return bySkill;
  }
}
