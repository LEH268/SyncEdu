/// Mastery heatmap, most-missed concepts and student struggle tags.
library;

import 'inputs.dart';
import 'thresholds.dart';

/// The colour band a mastery figure should be rendered in.
enum MasteryBand { green, amber, red, insufficient }

/// One micro-skill's accuracy, at the grain a [MasteryCell] breaks down into.
class SkillCell {
  const SkillCell({
    required this.microSkillId,
    required this.microSkillLabel,
    required this.correct,
    required this.total,
    required this.accuracy,
  });

  final String microSkillId;
  final String microSkillLabel;
  final int correct;
  final int total;
  final double accuracy;
}

/// A chapter's aggregate accuracy for a class, with its per-skill breakdown.
class MasteryCell {
  const MasteryCell({
    required this.chapterId,
    required this.chapterTitle,
    required this.correct,
    required this.total,
    required this.accuracy,
    required this.band,
    required this.skills,
  });

  final String chapterId;
  final String chapterTitle;
  final int correct;
  final int total;
  final double accuracy;
  final MasteryBand band;
  final List<SkillCell> skills;
}

/// One ranked concept: a micro-skill and how badly it is being missed.
class ConceptRank {
  const ConceptRank({
    required this.microSkillId,
    required this.microSkillLabel,
    required this.errorRate,
    required this.total,
    required this.source,
  });

  final String microSkillId;
  final String microSkillLabel;
  final double errorRate;
  final int total;
  final String source;
}

MasteryBand _bandFor({
  required int total,
  required double accuracy,
  required AnalyticsThresholds thresholds,
}) {
  if (total < thresholds.minimumItemsForStudentSkillJudgement) {
    return MasteryBand.insufficient;
  }
  if (accuracy >= thresholds.masteryGreenFloor) {
    return MasteryBand.green;
  }
  if (accuracy >= thresholds.masteryAmberFloor) {
    return MasteryBand.amber;
  }
  return MasteryBand.red;
}

/// A per-chapter, per-skill accuracy heatmap for one class.
///
/// Only `revise`-mode rows are considered — a student exploring ahead in
/// `prep` mode must not be penalised on the teacher's view.
List<MasteryCell> masteryHeatmap({
  required List<AnalyticRow> rows,
  required String classId,
  AnalyticsThresholds thresholds = const AnalyticsThresholds.standard(),
}) {
  final List<AnalyticRow> scoped = rows
      .where((AnalyticRow r) => r.classId == classId && r.mode == 'revise')
      .toList();

  final Map<String, String> chapterTitles = <String, String>{};
  final Map<String, List<AnalyticRow>> byChapter = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in scoped) {
    chapterTitles[row.chapterId] = row.chapterTitle;
    byChapter.putIfAbsent(row.chapterId, () => <AnalyticRow>[]).add(row);
  }

  final List<MasteryCell> cells = <MasteryCell>[];
  for (final MapEntry<String, List<AnalyticRow>> entry in byChapter.entries) {
    final List<AnalyticRow> chapterRows = entry.value;
    final int total = chapterRows.length;
    final int correct = chapterRows.where((AnalyticRow r) => r.isCorrect).length;
    final double accuracy = total == 0 ? 0.0 : correct / total;

    final Map<String, String> skillLabels = <String, String>{};
    final Map<String, List<AnalyticRow>> bySkill = <String, List<AnalyticRow>>{};
    for (final AnalyticRow row in chapterRows) {
      skillLabels[row.microSkillId] = row.microSkillLabel;
      bySkill.putIfAbsent(row.microSkillId, () => <AnalyticRow>[]).add(row);
    }

    final List<SkillCell> skills = bySkill.entries.map((MapEntry<String, List<AnalyticRow>> e) {
      final int skillTotal = e.value.length;
      final int skillCorrect = e.value.where((AnalyticRow r) => r.isCorrect).length;
      return SkillCell(
        microSkillId: e.key,
        microSkillLabel: skillLabels[e.key]!,
        correct: skillCorrect,
        total: skillTotal,
        accuracy: skillTotal == 0 ? 0.0 : skillCorrect / skillTotal,
      );
    }).toList();

    cells.add(
      MasteryCell(
        chapterId: entry.key,
        chapterTitle: chapterTitles[entry.key]!,
        correct: correct,
        total: total,
        accuracy: accuracy,
        band: _bandFor(total: total, accuracy: accuracy, thresholds: thresholds),
        skills: skills,
      ),
    );
  }

  return cells;
}

/// The class's most-missed micro-skills, ranked by error rate descending.
///
/// A skill below [AnalyticsThresholds.minimumItemsForConceptRanking] is
/// excluded entirely rather than risk a confidently wrong ranking off a
/// tiny sample.
List<ConceptRank> mostMissedConcepts({
  required List<AnalyticRow> rows,
  required String classId,
  int limit = 10,
  AnalyticsThresholds thresholds = const AnalyticsThresholds.standard(),
}) {
  final List<AnalyticRow> scoped = rows
      .where((AnalyticRow r) => r.classId == classId && r.mode == 'revise')
      .toList();

  final Map<String, String> skillLabels = <String, String>{};
  final Map<String, List<AnalyticRow>> bySkill = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in scoped) {
    skillLabels[row.microSkillId] = row.microSkillLabel;
    bySkill.putIfAbsent(row.microSkillId, () => <AnalyticRow>[]).add(row);
  }

  final List<ConceptRank> ranked = <ConceptRank>[];
  for (final MapEntry<String, List<AnalyticRow>> entry in bySkill.entries) {
    final int total = entry.value.length;
    if (total < thresholds.minimumItemsForConceptRanking) {
      continue;
    }
    final int wrong = entry.value.where((AnalyticRow r) => !r.isCorrect).length;
    ranked.add(
      ConceptRank(
        microSkillId: entry.key,
        microSkillLabel: skillLabels[entry.key]!,
        errorRate: wrong / total,
        total: total,
        source: 'quiz',
      ),
    );
  }

  ranked.sort((ConceptRank a, ConceptRank b) {
    final int cmp = b.errorRate.compareTo(a.errorRate);
    return cmp != 0 ? cmp : a.microSkillId.compareTo(b.microSkillId);
  });
  return ranked.take(limit).toList();
}

/// One student's most likely struggle areas, unioning quiz-derived error
/// rates with explicit weakness rows (e.g. from an uploaded exam) so a gap
/// with no quiz history at all still surfaces.
///
/// Scope decision: this feeds the same teacher-facing family of views as
/// [masteryHeatmap] and [mostMissedConcepts] in this file, so the
/// [AnalyticRow]-derived portion applies the same `mode == 'revise'` filter
/// they do -- a student exploring ahead in `prep` mode must not be
/// penalised here either. The [WeaknessRow]-derived portion has no `mode`
/// field and is never filtered: an exam-sourced weakness always surfaces.
List<ConceptRank> topStruggleTags({
  required List<AnalyticRow> rows,
  required List<WeaknessRow> weaknesses,
  required String studentId,
  int limit = 3,
}) {
  final List<AnalyticRow> scoped = rows
      .where((AnalyticRow r) => r.studentId == studentId && r.mode == 'revise')
      .toList();

  final Map<String, String> skillLabels = <String, String>{};
  final Map<String, List<AnalyticRow>> bySkill = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in scoped) {
    skillLabels[row.microSkillId] = row.microSkillLabel;
    bySkill.putIfAbsent(row.microSkillId, () => <AnalyticRow>[]).add(row);
  }

  final Map<String, ConceptRank> byMicroSkill = <String, ConceptRank>{};
  for (final MapEntry<String, List<AnalyticRow>> entry in bySkill.entries) {
    final int total = entry.value.length;
    final int wrong = entry.value.where((AnalyticRow r) => !r.isCorrect).length;
    byMicroSkill[entry.key] = ConceptRank(
      microSkillId: entry.key,
      microSkillLabel: skillLabels[entry.key]!,
      errorRate: total == 0 ? 0.0 : wrong / total,
      total: total,
      source: 'quiz',
    );
  }

  for (final WeaknessRow weakness in weaknesses) {
    if (weakness.studentId != studentId) {
      continue;
    }
    final ConceptRank? existing = byMicroSkill[weakness.microSkillId];
    if (existing == null) {
      byMicroSkill[weakness.microSkillId] = ConceptRank(
        microSkillId: weakness.microSkillId,
        microSkillLabel: weakness.microSkillId,
        errorRate: weakness.weight,
        total: 0,
        source: weakness.source,
      );
    } else if (weakness.weight > existing.errorRate) {
      byMicroSkill[weakness.microSkillId] = ConceptRank(
        microSkillId: existing.microSkillId,
        microSkillLabel: existing.microSkillLabel,
        errorRate: weakness.weight,
        total: existing.total,
        source: weakness.source,
      );
    }
  }

  final List<ConceptRank> ranked = byMicroSkill.values.toList()
    ..sort((ConceptRank a, ConceptRank b) {
      final int cmp = b.errorRate.compareTo(a.errorRate);
      return cmp != 0 ? cmp : a.microSkillId.compareTo(b.microSkillId);
    });
  return ranked.take(limit).toList();
}
