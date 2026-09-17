/// The Class Fit Analyzer's arithmetic: compose academic results (40%), the
/// student's own year-end reflection (30%) and an AI-scored teacher
/// observation (30%) into one number, and report the composition alongside it.
///
/// Only the observation scoring and the recommendation prose are Gemini's
/// (`analyse-fit`). Everything here is deterministic Dart, so a teacher can
/// defend the recommendation (requirement 53) and the rule-based path
/// (requirement 54) stands in whenever the model call fails.
library;

enum FitVerdict { greatFit, acceptable, mismatch, strongMismatch }

/// Nominal weights. When a component is missing the remaining weights are
/// renormalised to sum to 1, rather than the absent component scoring zero —
/// treating an unsubmitted reflection as 0/30 would brand every student who
/// did not answer a mismatch, which says nothing about their fit.
const double kAcademicWeight = 0.40;
const double kStudentWeight = 0.30;
const double kTeacherWeight = 0.30;

class FitScore {
  const FitScore({
    required this.score,
    required this.academicContribution,
    required this.studentContribution,
    required this.teacherContribution,
    required this.componentsUsed,
  });

  /// The 0–100 fit score, or null when no component was supplied at all.
  final double? score;

  /// Each component's points contribution to [score] (0 when absent).
  final double academicContribution;
  final double studentContribution;
  final double teacherContribution;

  /// The components that actually fed [score], in `academic`, `student`,
  /// `teacher` order.
  final List<String> componentsUsed;

  FitVerdict? get verdict => score == null ? null : verdictFor(score!);
}

/// Composes a [FitScore] from whichever of the three percentages are present.
FitScore composeFitScore({
  double? academicPct,
  double? studentPct,
  double? teacherPct,
}) {
  final List<({String name, double pct, double weight})> present =
      <({String name, double pct, double weight})>[
    if (academicPct != null)
      (name: 'academic', pct: academicPct, weight: kAcademicWeight),
    if (studentPct != null)
      (name: 'student', pct: studentPct, weight: kStudentWeight),
    if (teacherPct != null)
      (name: 'teacher', pct: teacherPct, weight: kTeacherWeight),
  ];

  if (present.isEmpty) {
    return const FitScore(
      score: null,
      academicContribution: 0,
      studentContribution: 0,
      teacherContribution: 0,
      componentsUsed: <String>[],
    );
  }

  final double weightSum =
      present.fold<double>(0, (double s, e) => s + e.weight);

  double contributionFor(String name) {
    for (final ({String name, double pct, double weight}) e in present) {
      if (e.name == name) return e.pct * e.weight / weightSum;
    }
    return 0;
  }

  final double academic = contributionFor('academic');
  final double student = contributionFor('student');
  final double teacher = contributionFor('teacher');

  return FitScore(
    score: academic + student + teacher,
    academicContribution: academic,
    studentContribution: student,
    teacherContribution: teacher,
    componentsUsed: present.map((e) => e.name).toList(),
  );
}

/// Verdict bands, carried from the reference: ≥ 75 great fit, ≥ 55 acceptable,
/// ≥ 35 mismatch, below that a strong mismatch.
FitVerdict verdictFor(double score) {
  if (score >= 75) return FitVerdict.greatFit;
  if (score >= 55) return FitVerdict.acceptable;
  if (score >= 35) return FitVerdict.mismatch;
  return FitVerdict.strongMismatch;
}

/// The recommendation used when the model call fails. Covers every band, so
/// the tool still says something useful offline.
String ruleBasedRecommendation(double fitScore) {
  switch (verdictFor(fitScore)) {
    case FitVerdict.greatFit:
      return 'Keep the current placement. Academic results, the student\'s '
          'reflection and the teacher\'s observation all point the same way.';
    case FitVerdict.acceptable:
      return 'Hold the current placement but review at the next checkpoint. '
          'The fit is workable, not settled.';
    case FitVerdict.mismatch:
      return 'Consider re-streaming. Look for a class whose target learning '
          'style is closer to this student\'s, and weigh the teacher\'s notes.';
    case FitVerdict.strongMismatch:
      return 'Re-stream this student. The current class is a poor fit on all '
          'measured axes; discuss options with the student and a parent.';
  }
}
