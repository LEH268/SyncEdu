/// Every number that decides how a figure is read, in one place.
///
/// These are not tuning knobs to be scattered through expressions: each one
/// changes what a chart *means*, and a reviewer needs to be able to find them
/// all without reading the arithmetic.
class AnalyticsThresholds {
  const AnalyticsThresholds({
    required this.minimumItemsForConceptRanking,
    required this.minimumItemsForStudentSkillJudgement,
    required this.strugglingAccuracyBar,
    required this.recommendationProportion,
    required this.recommendationMinimumClassSize,
    required this.masteryGreenFloor,
    required this.masteryAmberFloor,
    required this.inactivityDays,
    required this.decliningPointDrop,
    required this.failedSkillsForHighRisk,
    required this.decliningAttemptWindow,
  });

  const AnalyticsThresholds.standard()
      : minimumItemsForConceptRanking = 5,
        minimumItemsForStudentSkillJudgement = 3,
        strugglingAccuracyBar = 0.5,
        recommendationProportion = 0.40,
        recommendationMinimumClassSize = 5,
        masteryGreenFloor = 0.75,
        masteryAmberFloor = 0.50,
        inactivityDays = 7,
        decliningPointDrop = 15,
        failedSkillsForHighRisk = 3,
        decliningAttemptWindow = 3;

  /// Without this, one wrong answer on a skill nobody has practised tops the
  /// difficulty chart at 100%.
  final int minimumItemsForConceptRanking;

  /// The bar for judging one student on one skill.
  final int minimumItemsForStudentSkillJudgement;

  /// A student is "struggling" on a skill below this accuracy.
  final double strugglingAccuracyBar;

  /// The proportion of a class that must be struggling on one skill before a
  /// resource recommendation fires.
  final double recommendationProportion;

  /// The minimum number of students who must have attempted enough of a
  /// skill to be judged before a resourcing recommendation is trusted; a
  /// handful of students is a signal about those students, not the class.
  final int recommendationMinimumClassSize;

  /// A chapter/skill accuracy at or above this is rendered green.
  final double masteryGreenFloor;

  /// A chapter/skill accuracy at or above this (but below the green floor)
  /// is rendered amber; anything lower is red.
  final double masteryAmberFloor;

  /// A student with no attempt in at least this many days is flagged
  /// inactive.
  final int inactivityDays;

  /// The point drop (on a 0-100 scale), between consecutive attempts, that
  /// counts as "declining" for the at-risk decline rule.
  final int decliningPointDrop;

  /// The number of failed skills (each judged independently) that tips a
  /// student into high risk on their own.
  final int failedSkillsForHighRisk;

  /// The number of most-recent attempts examined for a declining trend.
  final int decliningAttemptWindow;
}
