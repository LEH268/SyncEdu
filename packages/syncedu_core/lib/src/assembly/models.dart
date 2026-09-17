/// One item in the local pool. Mirrors `public.questions`, minus anything
/// assembly does not need.
class PoolQuestion {
  const PoolQuestion({
    required this.id,
    required this.chapterId,
    required this.microSkillId,
    required this.difficulty,
    required this.stem,
    required this.options,
    required this.correctIndex,
    required this.provenance,
    this.forStudentId,
    this.rationale,
  });

  final String id;
  final String chapterId;
  final String microSkillId;
  final int difficulty;
  final String stem;
  final List<String> options;
  final int correctIndex;
  final String provenance;
  final String? forStudentId;
  final String? rationale;

  bool get isPersonalised => provenance == 'personalised';
}

/// Preview (chapter not yet taught to this class) or revision.
enum QuizMode { prep, revise }

class AssemblyRequest {
  const AssemblyRequest({
    required this.chapterIds,
    required this.count,
    required this.mode,
    this.targetMicroSkills = const <String>{},
    this.weaknessWeights = const <String, double>{},
    this.recentlySeenIds = const <String>{},
    this.harderOnly = false,
    this.seed = 0,
  });

  final List<String> chapterIds;
  final int count;
  final QuizMode mode;

  /// Skills to concentrate on. Empty means unbiased -- which is what a student
  /// with nothing on file gets, with no special case anywhere.
  final Set<String> targetMicroSkills;

  /// Per-skill weakness weight in [0, 1], summed across sources by the caller.
  final Map<String, double> weaknessWeights;

  final Set<String> recentlySeenIds;

  /// Set when "practise mistakes" is offered on a perfect score.
  final bool harderOnly;

  final int seed;
}

class AssemblyResult {
  const AssemblyResult({
    required this.questions,
    required this.relaxedSeenSet,
    required this.poolExhausted,
    required this.targetProportion,
  });

  final List<PoolQuestion> questions;

  /// True when the seen set had to be ignored to fill the quiz. The UI says so.
  final bool relaxedSeenSet;

  /// True when even then there were not enough questions.
  final bool poolExhausted;

  final double targetProportion;
}
