/// Row shapes for analytics computations.
library;

import 'thresholds.dart';

/// A single attempt result from a student.
class AnalyticRow {
  const AnalyticRow({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.chapterId,
    required this.chapterTitle,
    required this.microSkillId,
    required this.microSkillLabel,
    required this.subjectName,
    required this.isCorrect,
    required this.submittedAt,
    required this.mode,
    required this.attemptId,
  });

  final String studentId;
  final String studentName;
  final String classId;
  final String className;
  final String chapterId;
  final String chapterTitle;
  final String microSkillId;
  final String microSkillLabel;
  final String subjectName;
  final bool isCorrect;
  final DateTime submittedAt;
  final String mode;
  final String attemptId;
}

/// A student's attempt on a skill (possibly multi-item).
class AttemptRow {
  const AttemptRow({
    required this.id,
    required this.studentId,
    required this.attemptNumber,
    required this.score,
    required this.questionCount,
    required this.submittedAt,
    required this.mode,
    this.parentAttemptId,
  });

  final String id;
  final String studentId;
  final String? parentAttemptId;
  final int attemptNumber;
  final int score;
  final int questionCount;
  final DateTime submittedAt;
  final String mode;
}

/// One graded item a student got *wrong*, carrying which option they chose.
///
/// Separate from [AnalyticRow] rather than folded into it: every existing
/// aggregate is a `group by` over correctness, and only the teaching review
/// needs the distractor. Adding the field to [AnalyticRow] would widen the
/// row every analytic reads to serve the one that needs it.
class WrongAnswerRow {
  const WrongAnswerRow({
    required this.studentId,
    required this.questionId,
    required this.microSkillId,
    required this.selectedIndex,
  });

  final String studentId;
  final String questionId;
  final String microSkillId;

  /// The option the student picked, or null when the item was left blank --
  /// a blank is not a misconception and is counted as neither.
  final int? selectedIndex;
}

/// A question's displayable text, keyed by id wherever it is needed.
class QuestionText {
  const QuestionText({
    required this.stem,
    required this.options,
    required this.correctIndex,
  });

  final String stem;
  final List<String> options;
  final int correctIndex;
}

/// A detected weak point in a student's knowledge.
class WeaknessRow {
  const WeaknessRow({
    required this.studentId,
    required this.microSkillId,
    required this.source,
    required this.weight,
  });

  final String studentId;
  final String microSkillId;
  final String source;
  final double weight;
}

/// Groups [rows] by student for one skill, drops students below the
/// per-student item floor ([AnalyticsThresholds.minimumItemsForStudentSkillJudgement]),
/// and reports how many of the rest are struggling
/// ([AnalyticsThresholds.strugglingAccuracyBar]).
///
/// [rows] must already be scoped to one (skill) grouping and to whatever
/// mode filter the caller wants (this helper does not filter mode) --
/// it only performs the per-student floor check, the accuracy check, and
/// the count.
({int attempted, int struggling}) countStrugglingStudents(
  List<AnalyticRow> rows,
  AnalyticsThresholds thresholds,
) {
  final Map<String, List<AnalyticRow>> byStudent = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in rows) {
    byStudent.putIfAbsent(row.studentId, () => <AnalyticRow>[]).add(row);
  }

  int attempted = 0;
  int struggling = 0;
  for (final List<AnalyticRow> studentRows in byStudent.values) {
    if (studentRows.length < thresholds.minimumItemsForStudentSkillJudgement) {
      continue;
    }
    attempted++;
    final int correct = studentRows.where((AnalyticRow r) => r.isCorrect).length;
    final double accuracy = correct / studentRows.length;
    if (accuracy < thresholds.strugglingAccuracyBar) {
      struggling++;
    }
  }

  return (attempted: attempted, struggling: struggling);
}
