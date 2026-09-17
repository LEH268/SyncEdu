/// The deliberate structure a seeded school is built to demonstrate.
///
/// Phase 10 fabricates exactly one thing: elapsed time. Every micro-skill
/// slug, pool question and chart label is real, ingested in Phase 3. What
/// cannot be lived through is four weeks of a class using the product, so the
/// seed generator writes `attempts` and `attempt_items` and lets the database
/// trigger derive every weakness — the demonstrated figures are then produced
/// by exactly the arithmetic the tests pin down.
///
/// A uniformly random seed produces charts that are technically correct and
/// say nothing. [HistoryShape] is the intended structure the generator aims
/// for: one class with a genuine deficit, three at-risk students each tripping
/// a *different* rule, one student with a visible improvement arc, and one
/// class scheduled ahead of another.
///
/// This library is pure: no I/O, no platform dependencies. `scripts/
/// seed_history.ts` mirrors these constants when it writes against the live
/// database, and `history_shape_test.dart` checks the shape is internally
/// consistent with `AnalyticsThresholds`.
library;

import '../analytics/thresholds.dart';

/// Which at-risk rule a planned student is built to trip.
///
/// The strings match the rule identifiers the seed verification script and
/// the at-risk analytics reason strings key on.
enum AtRiskRule {
  /// Overall revision accuracy below the struggling bar.
  lowMastery('low_mastery'),

  /// No attempt within the inactivity window.
  inactive('inactive'),

  /// Consecutive falling attempt scores.
  declining('declining'),

  /// At least [AnalyticsThresholds.failedSkillsForHighRisk] skills below the
  /// struggling bar. Not part of the demonstration trio, listed for
  /// completeness.
  multipleFailedSkills('multiple_failed_skills');

  const AtRiskRule(this.id);

  /// Stable identifier, equal to the value the analytics layer emits.
  final String id;
}

/// One student the seed builds to trip exactly one at-risk rule.
class AtRiskPlan {
  const AtRiskPlan({
    required this.slot,
    required this.rule,
    required this.classSlot,
    this.overallAccuracy,
    this.lastAttemptDaysAgo,
    this.decliningScores,
  });

  /// Index of the student within their class roster (0-based).
  final int slot;

  /// Index of the class within the school (0-based).
  final int classSlot;

  /// The one rule this student is constructed to trip.
  final AtRiskRule rule;

  /// For [AtRiskRule.lowMastery]: the fraction of items answered correctly
  /// across the student's whole revision history.
  final double? overallAccuracy;

  /// For [AtRiskRule.inactive]: how many days before "now" the student's most
  /// recent attempt was submitted.
  final int? lastAttemptDaysAgo;

  /// For [AtRiskRule.declining]: the chronological run of attempt scores (on a
  /// 0-100 points scale), oldest first.
  final List<int>? decliningScores;

  /// Convenience accessor matching the plan's test vocabulary.
  String get ruleId => rule.id;
}

/// The single class-and-skill deficit the 40% resource rule is built to fire
/// on, with a specific defensible output.
class DeficitPlan {
  const DeficitPlan({
    required this.classSlot,
    required this.microSkillOrdinal,
    required this.strugglingProportion,
    required this.assessedStudents,
    required this.classSize,
  });

  /// Index of the deficit class within the school (0-based).
  final int classSlot;

  /// Ordinal (1-based) of the micro-skill within its chapter that the class
  /// is weak on. The generator resolves this against the real ingested
  /// micro-skill slugs.
  final int microSkillOrdinal;

  /// The intended proportion of assessed students struggling on the skill —
  /// between 45% and 55% of the class, so the rule fires without the result
  /// looking manufactured.
  final double strugglingProportion;

  /// How many students answer enough items on the deficit skill to be judged.
  final int assessedStudents;

  /// The true class size.
  final int classSize;

  /// Whether this plan clears the 40% rule's two gates under [thresholds].
  bool firesRecommendation([
    AnalyticsThresholds thresholds = const AnalyticsThresholds.standard(),
  ]) =>
      strugglingProportion >= thresholds.recommendationProportion &&
      assessedStudents >= thresholds.recommendationMinimumClassSize;
}

/// One student built to show a visible improvement arc across a single retry
/// chain, so the progress curve and chain rendering have something to draw.
class ImprovingArcPlan {
  const ImprovingArcPlan({
    required this.slot,
    required this.classSlot,
    required this.attemptScores,
  });

  /// Index of the student within their class roster (0-based).
  final int slot;

  /// Index of the class within the school (0-based).
  final int classSlot;

  /// Attempt scores (0-100 points scale) along the chain, oldest first. Each
  /// attempt after the first has the previous one as its `parent_attempt_id`,
  /// so [retryChains] groups them into one chain, not three.
  final List<int> attemptScores;

  /// The point rise from the first attempt to the last.
  int get riseInPoints => attemptScores.last - attemptScores.first;
}

/// One class deliberately scheduled several chapters ahead of another, so
/// per-class scheduling is visibly doing something.
class SchedulePlan {
  const SchedulePlan({
    required this.aheadClassSlot,
    required this.behindClassSlot,
    required this.aheadChaptersTaught,
    required this.behindChaptersTaught,
  });

  final int aheadClassSlot;
  final int behindClassSlot;

  /// Number of chapters (per subject) marked taught for the leading class.
  final int aheadChaptersTaught;

  /// Number of chapters (per subject) marked taught for the trailing class.
  final int behindChaptersTaught;
}

/// The full intended structure of a demonstration seed.
class HistoryShape {
  const HistoryShape({
    required this.weeks,
    required this.classCount,
    required this.studentsPerClass,
    required this.teacherCount,
    required this.deficit,
    required this.atRiskStudents,
    required this.improvingStudent,
    required this.schedule,
  });

  /// The canonical demonstration shape from spec §10.
  const HistoryShape.demonstration()
      : weeks = 4,
        classCount = 3,
        studentsPerClass = 12,
        teacherCount = 2,
        deficit = const DeficitPlan(
          classSlot: 0,
          microSkillOrdinal: 2,
          strugglingProportion: 0.5,
          assessedStudents: 12,
          classSize: 12,
        ),
        atRiskStudents = const <AtRiskPlan>[
          AtRiskPlan(
            slot: 9,
            classSlot: 1,
            rule: AtRiskRule.lowMastery,
            overallAccuracy: 0.4,
          ),
          AtRiskPlan(
            slot: 10,
            classSlot: 1,
            rule: AtRiskRule.inactive,
            lastAttemptDaysAgo: 10,
          ),
          AtRiskPlan(
            slot: 11,
            classSlot: 2,
            rule: AtRiskRule.declining,
            decliningScores: <int>[85, 65, 45],
          ),
        ],
        improvingStudent = const ImprovingArcPlan(
          slot: 0,
          classSlot: 2,
          attemptScores: <int>[40, 55, 65, 78],
        ),
        schedule = const SchedulePlan(
          aheadClassSlot: 0,
          behindClassSlot: 2,
          aheadChaptersTaught: 5,
          behindChaptersTaught: 2,
        );

  /// Weeks of history to synthesise.
  final int weeks;

  /// Number of classes in the seeded school.
  final int classCount;

  /// Students per class (roughly — the spec says "roughly twelve").
  final int studentsPerClass;

  /// Non-admin teaching staff.
  final int teacherCount;

  /// The one deficit the resource recommendation is built to fire on.
  final DeficitPlan deficit;

  /// The three students, each tripping a distinct rule.
  final List<AtRiskPlan> atRiskStudents;

  /// The student with the visible improvement arc.
  final ImprovingArcPlan improvingStudent;

  /// The ahead/behind class scheduling.
  final SchedulePlan schedule;

  /// Total students across every class.
  int get totalStudents => classCount * studentsPerClass;

  /// Students not built to be at risk. The at-risk list must not be everyone —
  /// a seed where every student is flagged demonstrates nothing.
  int get healthyStudentCount => totalStudents - atRiskStudents.length;

  /// The distinct rule ids the at-risk trio is built to cover.
  Set<String> get atRiskRuleIds =>
      atRiskStudents.map((AtRiskPlan p) => p.ruleId).toSet();
}
