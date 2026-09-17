/// Rule-based resource allocation recommendations.
library;

import 'inputs.dart';
import 'thresholds.dart';

/// A recommendation to allocate resources to one class for one micro-skill,
/// because a large enough share of the class is struggling on it.
///
/// [sentence] is rendered directly from this structure's own fields, so the
/// words a teacher reads and the numbers the rule fired on can never drift
/// apart.
class ResourceRecommendation {
  const ResourceRecommendation({
    required this.classId,
    required this.className,
    required this.subjectName,
    required this.microSkillId,
    required this.microSkillLabel,
    required this.proportion,
    required this.affectedCount,
    required this.studentsAssessed,
    required this.classSize,
    required this.rank,
  });

  final String classId;
  final String className;
  final String subjectName;
  final String microSkillId;
  final String microSkillLabel;
  final double proportion;
  final int affectedCount;

  /// Students who answered enough of this one micro-skill to be judged
  /// (per [AnalyticsThresholds.minimumItemsForStudentSkillJudgement]).
  /// [proportion] is [affectedCount] over this, not over [classSize].
  final int studentsAssessed;

  /// The TRUE size of the class: the count of distinct students across all
  /// rows for this class, regardless of whether they attempted this skill.
  final int classSize;
  final double rank;

  String get sentence =>
      'Recommend additional $subjectName support for $className: '
      '${(proportion * 100).round()}% of the class '
      '($affectedCount of $studentsAssessed assessed students, out of '
      '$classSize in the class) is struggling with $microSkillLabel.';
}

/// The 40% rule: for each (class, micro-skill), if the proportion of the
/// class struggling on the skill reaches
/// [AnalyticsThresholds.recommendationProportion] and the class has at least
/// [AnalyticsThresholds.recommendationMinimumClassSize] students who
/// attempted enough of the skill to be judged (per
/// [AnalyticsThresholds.minimumItemsForStudentSkillJudgement], same "per
/// student, then count" discipline as [schoolDifficultyRanking]), emit a
/// recommendation. Ranked by proportion times affected count, so support
/// goes where it reaches the most students who need it, not just where the
/// percentage is highest. Excludes 'prep' mode rows (teacher/admin-facing
/// views are revise-only).
List<ResourceRecommendation> resourceRecommendations({
  required List<AnalyticRow> rows,
  AnalyticsThresholds thresholds = const AnalyticsThresholds.standard(),
}) {
  final Iterable<AnalyticRow> reviseRows = rows.where((r) => r.mode != 'prep');

  // True class size: distinct students across ALL rows for a class,
  // independent of skill.
  final Map<String, Set<String>> studentsByClass = <String, Set<String>>{};
  for (final AnalyticRow row in reviseRows) {
    studentsByClass.putIfAbsent(row.classId, () => <String>{}).add(row.studentId);
  }

  // Group by (classId, microSkillId).
  final Map<String, Map<String, List<AnalyticRow>>> byClassSkill =
      <String, Map<String, List<AnalyticRow>>>{};
  for (final AnalyticRow row in reviseRows) {
    final Map<String, List<AnalyticRow>> bySkill =
        byClassSkill.putIfAbsent(row.classId, () => <String, List<AnalyticRow>>{});
    bySkill.putIfAbsent(row.microSkillId, () => <AnalyticRow>[]).add(row);
  }

  final List<ResourceRecommendation> recommendations = <ResourceRecommendation>[];

  for (final MapEntry<String, Map<String, List<AnalyticRow>>> classEntry in byClassSkill.entries) {
    for (final MapEntry<String, List<AnalyticRow>> skillEntry in classEntry.value.entries) {
      final List<AnalyticRow> skillRows = skillEntry.value;
      final ({int attempted, int struggling}) counts = countStrugglingStudents(skillRows, thresholds);

      if (counts.attempted == 0) {
        continue;
      }
      if (counts.attempted < thresholds.recommendationMinimumClassSize) {
        continue;
      }

      final double proportion = counts.struggling / counts.attempted;
      if (proportion < thresholds.recommendationProportion) {
        continue;
      }

      final AnalyticRow sample = skillRows.first;

      recommendations.add(
        ResourceRecommendation(
          classId: classEntry.key,
          className: sample.className,
          subjectName: sample.subjectName,
          microSkillId: skillEntry.key,
          microSkillLabel: sample.microSkillLabel,
          proportion: proportion,
          affectedCount: counts.struggling,
          studentsAssessed: counts.attempted,
          classSize: studentsByClass[classEntry.key]?.length ?? counts.attempted,
          rank: proportion * counts.struggling,
        ),
      );
    }
  }

  recommendations.sort((a, b) {
    final int cmp = b.rank.compareTo(a.rank);
    return cmp != 0 ? cmp : a.microSkillId.compareTo(b.microSkillId);
  });
  return recommendations;
}
