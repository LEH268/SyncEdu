/// Teaching review: which micro-skills failed to land with a class, and
/// whether the same skills fail across the teacher's other classes too.
///
/// This is a *diagnostic* over class results, deliberately not a measure of a
/// teacher. The design spec (section 11) rules out teacher performance
/// analytics because the longitudinal per-teacher data that would justify one
/// does not exist. What does exist is the same "per student, then count"
/// evidence the resource recommendation already fires on (section 7.3), and
/// one extra reading of it: a skill that fails in *every* class a teacher
/// takes says something about how the material presents that skill, while a
/// skill that fails in one class says something about that class. Nothing
/// here scores a person.
library;

import 'inputs.dart';
import 'thresholds.dart';

/// Where the evidence points for one flagged micro-skill.
enum TeachingScope {
  /// The teacher's other classes cleared the same bar on this skill: the
  /// presentation of this skill is the common factor, not the cohort.
  materialWide,

  /// The teacher's other classes did *not* struggle: this class did.
  classSpecific,

  /// There is no second class with enough assessed students to compare
  /// against, so no claim about the material can be made at all.
  insufficientComparison,
}

/// One distractor students actually chose, and how many chose it.
///
/// Counted over *students*, not answers, for the same reason the struggling
/// proportion is: one student answering the same question five times must not
/// look like five students holding the same misconception.
class Misconception {
  const Misconception({
    required this.questionId,
    required this.questionStem,
    required this.optionIndex,
    required this.optionText,
    required this.studentCount,
  });

  final String questionId;
  final String questionStem;
  final int optionIndex;
  final String optionText;
  final int studentCount;
}

/// One micro-skill that did not land with a class, with the comparison
/// against the teacher's other classes that says what kind of problem it is.
class TeachingSignal {
  const TeachingSignal({
    required this.microSkillId,
    required this.microSkillLabel,
    required this.proportion,
    required this.affectedCount,
    required this.studentsAssessed,
    required this.classSize,
    required this.scope,
    required this.cohortProportion,
    required this.cohortStudentsAssessed,
    required this.cohortClassCount,
    required this.misconceptions,
  });

  final String microSkillId;
  final String microSkillLabel;

  /// [affectedCount] over [studentsAssessed] in *this* class.
  final double proportion;
  final int affectedCount;

  /// Students who answered at least
  /// [AnalyticsThresholds.minimumItemsForStudentSkillJudgement] items on this
  /// skill in this class. [proportion] is over this, not over [classSize].
  final int studentsAssessed;

  /// Distinct students in the class across every skill, assessed or not.
  final int classSize;

  final TeachingScope scope;

  /// The same struggling proportion pooled over the teacher's *other*
  /// classes, or null when [scope] is [TeachingScope.insufficientComparison].
  final double? cohortProportion;

  /// Assessed students behind [cohortProportion].
  final int cohortStudentsAssessed;

  /// How many other classes contributed to [cohortProportion].
  final int cohortClassCount;

  /// The wrong options students picked most often on this skill, worst
  /// first. Empty when no question text was supplied.
  final List<Misconception> misconceptions;

  /// The finding, rendered from this object's own fields so the words a
  /// teacher reads and the numbers the rule fired on cannot drift apart --
  /// the same discipline as `ResourceRecommendation.sentence`. This is the
  /// sentence shown when the model call fails, and it is never generated.
  String get sentence {
    final String head = '${(proportion * 100).round()}% of the assessed class '
        '($affectedCount of $studentsAssessed, out of $classSize enrolled) '
        'is struggling with $microSkillLabel';
    final String others =
        '$cohortClassCount ${cohortClassCount == 1 ? 'class' : 'classes'} '
        '($cohortStudentsAssessed assessed)';
    return switch (scope) {
      TeachingScope.materialWide =>
        '$head, and ${(cohortProportion! * 100).round()}% across your other '
            '$others. The same skill fails wherever it is taught, so look at '
            'how it is presented.',
      TeachingScope.classSpecific =>
        '$head, against ${(cohortProportion! * 100).round()}% across your '
            'other $others. This is specific to this class rather than to the '
            'material.',
      TeachingScope.insufficientComparison =>
        '$head. No other class of yours has enough assessed students on this '
            'skill to say whether the material or the class is the cause.',
    };
  }
}

/// Everything the teaching tab computes for one (class, chapter), before any
/// model is involved.
class TeachingReview {
  const TeachingReview({
    required this.classId,
    required this.className,
    required this.chapterId,
    required this.chapterTitle,
    required this.subjectName,
    required this.signals,
    required this.classSize,
    required this.chapterAccuracy,
  });

  final String classId;
  final String className;
  final String chapterId;
  final String chapterTitle;
  final String subjectName;

  /// Flagged skills, worst first. Empty means the chapter landed: there is
  /// nothing for the model to write about and nothing to re-teach.
  final List<TeachingSignal> signals;

  final int classSize;

  /// Whole-chapter accuracy for the class, or null with no graded items.
  final double? chapterAccuracy;

  bool get hasFindings => signals.isNotEmpty;

  /// How many flagged skills point at the material rather than at the class.
  int get materialWideCount => signals
      .where((TeachingSignal s) => s.scope == TeachingScope.materialWide)
      .length;

  /// The deterministic headline, used verbatim whenever the model call fails
  /// -- the counterpart to `ruleBasedRecommendation` in the fit analyzer.
  String get ruleHeadline {
    if (signals.isEmpty) {
      return 'No micro-skill in $chapterTitle reached the attention threshold '
          'for $className. Nothing here suggests a presentation problem.';
    }
    final String noun =
        signals.length == 1 ? 'micro-skill' : 'micro-skills';
    final String skills =
        signals.map((TeachingSignal s) => s.microSkillLabel).join(', ');
    if (materialWideCount == 0) {
      return '${signals.length} $noun in $chapterTitle did not land with '
          '$className ($skills). Your other classes did not struggle on the '
          'same skills, so this points at this class rather than at the '
          'slides.';
    }
    return '$materialWideCount of ${signals.length} flagged $noun in '
        '$chapterTitle ($skills) also failed in your other classes. A skill '
        'that fails everywhere it is taught is a presentation problem rather '
        'than a cohort problem: rework how those skills are introduced.';
  }
}

/// Counts, per wrong option, how many distinct students chose it.
///
/// [answers] is one entry per graded item a student got wrong; [questions]
/// supplies the stem and option text. An answer whose question is absent from
/// [questions] is dropped rather than guessed at.
List<Misconception> misconceptionsFor({
  required String microSkillId,
  required List<WrongAnswerRow> answers,
  required Map<String, QuestionText> questions,
  int limit = 3,
}) {
  // (questionId, optionIndex) -> the distinct students who chose it.
  final Map<(String, int), Set<String>> studentsByOption =
      <(String, int), Set<String>>{};
  for (final WrongAnswerRow answer in answers) {
    if (answer.microSkillId != microSkillId) continue;
    final int? selected = answer.selectedIndex;
    if (selected == null) continue;
    if (!questions.containsKey(answer.questionId)) continue;
    studentsByOption
        .putIfAbsent((answer.questionId, selected), () => <String>{})
        .add(answer.studentId);
  }

  final List<Misconception> result = <Misconception>[];
  for (final MapEntry<(String, int), Set<String>> entry
      in studentsByOption.entries) {
    final (String questionId, int optionIndex) = entry.key;
    final QuestionText question = questions[questionId]!;
    // A selected index outside the option list is a corrupt row, not a
    // misconception worth reporting.
    if (optionIndex < 0 || optionIndex >= question.options.length) continue;
    result.add(
      Misconception(
        questionId: questionId,
        questionStem: question.stem,
        optionIndex: optionIndex,
        optionText: question.options[optionIndex],
        studentCount: entry.value.length,
      ),
    );
  }

  result.sort((Misconception a, Misconception b) {
    final int cmp = b.studentCount.compareTo(a.studentCount);
    if (cmp != 0) return cmp;
    final int byQuestion = a.questionId.compareTo(b.questionId);
    return byQuestion != 0 ? byQuestion : a.optionIndex.compareTo(b.optionIndex);
  });
  return result.take(limit).toList();
}

/// The whole diagnostic for one (class, chapter).
///
/// [rows] must span the teacher's classes -- not just [classId] -- because the
/// cross-class comparison is the entire point: it is what separates a class
/// that struggled from material that does not teach a skill. Rows for other
/// chapters are ignored.
///
/// A skill is flagged on exactly the bar the resource recommendation uses
/// ([AnalyticsThresholds.recommendationProportion] of assessed students
/// struggling, at least [AnalyticsThresholds.recommendationMinimumClassSize]
/// of them assessed), so a teacher and an admin looking at the same class can
/// never see one flag a skill and the other not.
TeachingReview reviewTeaching({
  required List<AnalyticRow> rows,
  required String classId,
  required String chapterId,
  List<WrongAnswerRow> wrongAnswers = const <WrongAnswerRow>[],
  Map<String, QuestionText> questions = const <String, QuestionText>{},
  AnalyticsThresholds thresholds = const AnalyticsThresholds.standard(),
}) {
  // Teacher-facing, so revise-only: preview practice stays the student's own
  // (spec section 7.1).
  final List<AnalyticRow> chapterRows = rows
      .where((AnalyticRow r) => r.mode != 'prep' && r.chapterId == chapterId)
      .toList(growable: false);

  final List<AnalyticRow> mine =
      chapterRows.where((AnalyticRow r) => r.classId == classId).toList();
  // A classless student (students.classId is nullable) belongs to no cohort
  // and cannot stand in for one, so they are excluded from the comparison
  // rather than pooled into an anonymous "other".
  final List<AnalyticRow> others = chapterRows
      .where((AnalyticRow r) => r.classId != classId && r.classId.isNotEmpty)
      .toList();

  final String className = mine.isNotEmpty ? mine.first.className : '';
  final String chapterTitle =
      chapterRows.isNotEmpty ? chapterRows.first.chapterTitle : '';
  final String subjectName =
      chapterRows.isNotEmpty ? chapterRows.first.subjectName : '';

  // True class size: distinct students in this class across every row visible
  // for them, not only this chapter's.
  final Set<String> enrolled = rows
      .where((AnalyticRow r) => r.mode != 'prep' && r.classId == classId)
      .map((AnalyticRow r) => r.studentId)
      .toSet();

  double? accuracy;
  if (mine.isNotEmpty) {
    accuracy = mine.where((AnalyticRow r) => r.isCorrect).length / mine.length;
  }

  final Map<String, List<AnalyticRow>> mineBySkill = _groupBySkill(mine);
  final Map<String, List<AnalyticRow>> othersBySkill = _groupBySkill(others);

  final List<TeachingSignal> signals = <TeachingSignal>[];
  for (final MapEntry<String, List<AnalyticRow>> entry in mineBySkill.entries) {
    final List<AnalyticRow> skillRows = entry.value;
    final ({int attempted, int struggling}) counts =
        countStrugglingStudents(skillRows, thresholds);

    if (counts.attempted < thresholds.recommendationMinimumClassSize) continue;
    final double proportion = counts.struggling / counts.attempted;
    if (proportion < thresholds.recommendationProportion) continue;

    final List<AnalyticRow> cohortRows =
        othersBySkill[entry.key] ?? const <AnalyticRow>[];
    final ({int attempted, int struggling}) cohort =
        countStrugglingStudents(cohortRows, thresholds);
    final int cohortClasses =
        cohortRows.map((AnalyticRow r) => r.classId).toSet().length;

    // The comparison is held to the same evidential bar as the finding it
    // qualifies: too few assessed students elsewhere and we say so, rather
    // than implying the material is fine.
    final double? cohortProportion =
        cohort.attempted < thresholds.recommendationMinimumClassSize
            ? null
            : cohort.struggling / cohort.attempted;

    final TeachingScope scope = cohortProportion == null
        ? TeachingScope.insufficientComparison
        : (cohortProportion >= thresholds.recommendationProportion
            ? TeachingScope.materialWide
            : TeachingScope.classSpecific);

    signals.add(
      TeachingSignal(
        microSkillId: entry.key,
        microSkillLabel: skillRows.first.microSkillLabel,
        proportion: proportion,
        affectedCount: counts.struggling,
        studentsAssessed: counts.attempted,
        classSize: enrolled.length,
        scope: scope,
        cohortProportion: cohortProportion,
        cohortStudentsAssessed: cohort.attempted,
        cohortClassCount: cohortClasses,
        misconceptions: misconceptionsFor(
          microSkillId: entry.key,
          answers: wrongAnswers,
          questions: questions,
        ),
      ),
    );
  }

  // Material-wide findings first -- they are the ones a slide rewrite can
  // actually fix -- then by how much of the class they cost, then by id so
  // the order is stable for a given input.
  signals.sort((TeachingSignal a, TeachingSignal b) {
    final int byScope = _scopeRank(a.scope).compareTo(_scopeRank(b.scope));
    if (byScope != 0) return byScope;
    final int byWeight = (b.proportion * b.affectedCount)
        .compareTo(a.proportion * a.affectedCount);
    if (byWeight != 0) return byWeight;
    return a.microSkillId.compareTo(b.microSkillId);
  });

  return TeachingReview(
    classId: classId,
    className: className,
    chapterId: chapterId,
    chapterTitle: chapterTitle,
    subjectName: subjectName,
    signals: signals,
    classSize: enrolled.length,
    chapterAccuracy: accuracy,
  );
}

int _scopeRank(TeachingScope scope) => switch (scope) {
      TeachingScope.materialWide => 0,
      TeachingScope.insufficientComparison => 1,
      TeachingScope.classSpecific => 2,
    };

Map<String, List<AnalyticRow>> _groupBySkill(List<AnalyticRow> rows) {
  final Map<String, List<AnalyticRow>> bySkill = <String, List<AnalyticRow>>{};
  for (final AnalyticRow row in rows) {
    bySkill.putIfAbsent(row.microSkillId, () => <AnalyticRow>[]).add(row);
  }
  return bySkill;
}
