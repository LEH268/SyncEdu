/// School-wide difficulty ranking, at-risk students and top-level KPIs.
library;

import 'inputs.dart';
import 'thresholds.dart';

/// One micro-skill's school-wide difficulty, by proportion of students
/// struggling (not proportion of answers wrong).
class DifficultyRank {
  const DifficultyRank({
    required this.microSkillId,
    required this.microSkillLabel,
    required this.chapterTitle,
    required this.subjectName,
    required this.studentsStruggling,
    required this.studentsAttempted,
    required this.proportion,
  });

  final String microSkillId;
  final String microSkillLabel;
  final String chapterTitle;
  final String subjectName;
  final int studentsStruggling;
  final int studentsAttempted;
  final double proportion;
}

/// Overall risk tier for a student.
enum RiskLevel { high, medium, none }

/// A student flagged by one or more at-risk rules.
class RiskRow {
  const RiskRow({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.level,
    required this.reasons,
  });

  final String studentId;
  final String studentName;
  final String classId;
  final String className;
  final RiskLevel level;
  final List<String> reasons;
}

/// Top-level school counts and averages.
class SchoolKpis {
  const SchoolKpis({
    required this.totalStudents,
    required this.totalTeachers,
    required this.studentsAtRisk,
    required this.averageMastery,
  });

  final int totalStudents;
  final int totalTeachers;
  final int studentsAtRisk;
  final double averageMastery;
}

/// Ranks micro-skills school-wide by the proportion of students struggling.
///
/// Groups rows by `(microSkillId, studentId)`, drops students below
/// [AnalyticsThresholds.minimumItemsForStudentSkillJudgement] items on that
/// skill, marks each surviving student struggling when their accuracy on the
/// skill is below [AnalyticsThresholds.strugglingAccuracyBar], then takes the
/// proportion over the surviving *students* — never over answers. Excludes
/// 'prep' mode rows (teacher/admin-facing views are revise-only).
List<DifficultyRank> schoolDifficultyRanking({
  required List<AnalyticRow> rows,
  int limit = 10,
  AnalyticsThresholds thresholds = const AnalyticsThresholds.standard(),
}) {
  final Iterable<AnalyticRow> reviseRows = rows.where((r) => r.mode != 'prep');

  // Group by microSkillId.
  final Map<String, List<AnalyticRow>> bySkill = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in reviseRows) {
    bySkill.putIfAbsent(row.microSkillId, () => <AnalyticRow>[]).add(row);
  }

  final List<DifficultyRank> ranks = <DifficultyRank>[];
  for (final MapEntry<String, List<AnalyticRow>> skillEntry in bySkill.entries) {
    final List<AnalyticRow> skillRows = skillEntry.value;
    final ({int attempted, int struggling}) counts = countStrugglingStudents(skillRows, thresholds);

    if (counts.attempted == 0) {
      continue;
    }
    final AnalyticRow sample = skillRows.first;

    ranks.add(
      DifficultyRank(
        microSkillId: skillEntry.key,
        microSkillLabel: sample.microSkillLabel,
        chapterTitle: sample.chapterTitle,
        subjectName: sample.subjectName,
        studentsStruggling: counts.struggling,
        studentsAttempted: counts.attempted,
        proportion: counts.struggling / counts.attempted,
      ),
    );
  }

  ranks.sort((a, b) {
    final int cmp = b.proportion.compareTo(a.proportion);
    return cmp != 0 ? cmp : a.microSkillId.compareTo(b.microSkillId);
  });
  return ranks.take(limit).toList();
}

/// A single at-risk rule evaluation for one student.
class _RuleHit {
  const _RuleHit(this.level, this.reason);
  final RiskLevel level;
  final String reason;
}

/// Flags students against a fixed set of risk rules, reporting every reason
/// that fired but only the single highest level among them. A student
/// triggering no rule is absent from the result entirely.
List<RiskRow> atRiskStudents({
  required List<AnalyticRow> rows,
  required List<AttemptRow> attempts,
  required DateTime now,
  AnalyticsThresholds thresholds = const AnalyticsThresholds.standard(),
}) {
  final Map<String, List<AnalyticRow>> byStudent = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in rows.where((r) => r.mode != 'prep')) {
    byStudent.putIfAbsent(row.studentId, () => <AnalyticRow>[]).add(row);
  }

  final Map<String, List<AttemptRow>> attemptsByStudent = <String, List<AttemptRow>>{};
  for (final AttemptRow attempt in attempts.where((a) => a.mode != 'prep')) {
    attemptsByStudent.putIfAbsent(attempt.studentId, () => <AttemptRow>[]).add(attempt);
  }

  final List<RiskRow> results = <RiskRow>[];

  for (final MapEntry<String, List<AnalyticRow>> entry in byStudent.entries) {
    final String studentId = entry.key;
    final List<AnalyticRow> studentRows = entry.value;
    final List<AttemptRow> studentAttempts = attemptsByStudent[studentId] ?? <AttemptRow>[];

    final List<_RuleHit> hits = <_RuleHit>[
      ..._overallMasteryRule(studentRows, thresholds),
      ..._failedSkillsRule(studentRows, thresholds),
      ..._inactivityRule(studentAttempts, now, thresholds),
      ..._decliningRule(studentAttempts, thresholds),
    ];

    if (hits.isEmpty) {
      continue;
    }

    final RiskLevel level = hits.map((h) => h.level).reduce(
          (a, b) => a == RiskLevel.high || b == RiskLevel.high
              ? RiskLevel.high
              : (a == RiskLevel.medium || b == RiskLevel.medium ? RiskLevel.medium : RiskLevel.none),
        );

    results.add(
      RiskRow(
        studentId: studentId,
        studentName: studentRows.first.studentName,
        classId: studentRows.first.classId,
        className: studentRows.first.className,
        level: level,
        reasons: hits.map((h) => h.reason).toList(),
      ),
    );
  }

  return results;
}

List<_RuleHit> _overallMasteryRule(List<AnalyticRow> studentRows, AnalyticsThresholds thresholds) {
  // A student with only a handful of answered items total is a signal about
  // insufficient data, not about mastery -- the same floor discipline
  // [_failedSkillsRule] and [schoolDifficultyRanking] apply per skill.
  if (studentRows.length < thresholds.minimumItemsForStudentSkillJudgement) {
    return const <_RuleHit>[];
  }
  final int correct = studentRows.where((r) => r.isCorrect).length;
  final double accuracy = correct / studentRows.length;
  if (accuracy < thresholds.strugglingAccuracyBar) {
    return <_RuleHit>[
      _RuleHit(
        RiskLevel.high,
        'overall mastery is ${(accuracy * 100).round()}%, below the ${(thresholds.strugglingAccuracyBar * 100).round()}% bar',
      ),
    ];
  }
  return const <_RuleHit>[];
}

List<_RuleHit> _failedSkillsRule(List<AnalyticRow> studentRows, AnalyticsThresholds thresholds) {
  final Map<String, List<AnalyticRow>> bySkill = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in studentRows) {
    bySkill.putIfAbsent(row.microSkillId, () => <AnalyticRow>[]).add(row);
  }

  int failedSkills = 0;
  for (final List<AnalyticRow> skillRows in bySkill.values) {
    if (skillRows.length < thresholds.minimumItemsForStudentSkillJudgement) {
      continue;
    }
    final int correct = skillRows.where((r) => r.isCorrect).length;
    final double accuracy = correct / skillRows.length;
    if (accuracy < thresholds.strugglingAccuracyBar) {
      failedSkills++;
    }
  }

  if (failedSkills >= thresholds.failedSkillsForHighRisk) {
    return <_RuleHit>[
      _RuleHit(RiskLevel.high, 'failing $failedSkills skills'),
    ];
  }
  return const <_RuleHit>[];
}

List<_RuleHit> _inactivityRule(List<AttemptRow> studentAttempts, DateTime now, AnalyticsThresholds thresholds) {
  if (studentAttempts.isEmpty) {
    // No attempts recorded at all: nothing to measure a gap against.
    return const <_RuleHit>[];
  }
  final DateTime latest = studentAttempts.map((a) => a.submittedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  final int daysSince = now.difference(latest).inDays;
  if (daysSince >= thresholds.inactivityDays) {
    return <_RuleHit>[
      _RuleHit(RiskLevel.medium, 'no attempt in $daysSince days'),
    ];
  }
  return const <_RuleHit>[];
}

List<_RuleHit> _decliningRule(List<AttemptRow> studentAttempts, AnalyticsThresholds thresholds) {
  final int window = thresholds.decliningAttemptWindow;
  if (studentAttempts.length < window) {
    return const <_RuleHit>[];
  }
  final List<AttemptRow> ordered = List<AttemptRow>.of(studentAttempts)
    ..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));

  // Only the most recent [window] chronological attempts decide "declining":
  // a student who slumped long ago but has since recovered should not stay
  // flagged forever.
  final List<AttemptRow> recent = ordered.sublist(ordered.length - window);

  // Intentionally a 0-100 "points" scale (matching decliningPointDrop's
  // naming), not the 0.0-1.0 ratio used elsewhere (e.g. ProgressPoint).
  // An attempt with zero questions is not comparable and is treated as 0.
  final List<double> points = recent
      .map((AttemptRow a) => a.questionCount == 0 ? 0.0 : a.score / a.questionCount * 100)
      .toList();

  bool declining = true;
  for (int i = 1; i < points.length; i++) {
    if (points[i - 1] - points[i] < thresholds.decliningPointDrop) {
      declining = false;
      break;
    }
  }

  if (declining) {
    return <_RuleHit>[
      _RuleHit(RiskLevel.medium, 'declining scores over the last $window attempts'),
    ];
  }
  return const <_RuleHit>[];
}

/// Top-level school KPIs. Average mastery is the mean of *per-student*
/// accuracies (unweighted by volume), so a prolific student cannot dominate
/// the figure. `studentsAtRisk` is simply the length of the passed-in [risk]
/// list — this function does not recompute risk.
SchoolKpis schoolKpis({
  required List<AnalyticRow> rows,
  required List<RiskRow> risk,
  required int teacherCount,
}) {
  final Map<String, List<AnalyticRow>> byStudent = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in rows.where((r) => r.mode != 'prep')) {
    byStudent.putIfAbsent(row.studentId, () => <AnalyticRow>[]).add(row);
  }

  double averageMastery = 0.0;
  if (byStudent.isNotEmpty) {
    double sum = 0.0;
    for (final List<AnalyticRow> studentRows in byStudent.values) {
      final int correct = studentRows.where((r) => r.isCorrect).length;
      sum += correct / studentRows.length;
    }
    averageMastery = sum / byStudent.length;
  }

  return SchoolKpis(
    totalStudents: byStudent.length,
    totalTeachers: teacherCount,
    studentsAtRisk: risk.length,
    averageMastery: averageMastery,
  );
}
