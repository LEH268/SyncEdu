import 'dart:math';

import 'models.dart';

const double _targetShare = 0.7;

/// Builds a quiz from local rows.
///
/// One code path, online and offline, so the offline behaviour is exercised on
/// every quiz rather than only when the network drops. Deterministic given a
/// seed, which is what makes every rule below a fast unit test.
AssemblyResult assembleQuiz(AssemblyRequest request, List<PoolQuestion> pool) {
  if (request.count <= 0) {
    return const AssemblyResult(
      questions: <PoolQuestion>[],
      relaxedSeenSet: false,
      poolExhausted: false,
      targetProportion: 0,
    );
  }

  final Set<String> chapters = request.chapterIds.toSet();
  final List<PoolQuestion> inScope = pool
      .where((PoolQuestion q) => chapters.contains(q.chapterId))
      .toList();

  if (inScope.isEmpty) {
    return const AssemblyResult(
      questions: <PoolQuestion>[],
      relaxedSeenSet: false,
      poolExhausted: true,
      targetProportion: 0,
    );
  }

  final Random random = Random(request.seed);

  List<PoolQuestion> unseen = inScope
      .where((PoolQuestion q) => !request.recentlySeenIds.contains(q.id))
      .toList();

  // Relax rather than fail. A student who has drilled a chapter hard still
  // gets a quiz; it just repeats. Connected, the app requests a top-up
  // instead -- but that is the caller's decision, not this function's.
  bool relaxed = false;
  if (unseen.length < request.count) {
    unseen = inScope;
    relaxed = request.recentlySeenIds.isNotEmpty;
  }

  final List<PoolQuestion> selected = _select(request, unseen, random);
  final List<PoolQuestion> ordered = _spread(selected, random);

  final int onTarget = request.targetMicroSkills.isEmpty
      ? 0
      : ordered
          .where((PoolQuestion q) => request.targetMicroSkills.contains(q.microSkillId))
          .length;

  return AssemblyResult(
    questions: ordered,
    relaxedSeenSet: relaxed,
    poolExhausted: ordered.length < request.count,
    targetProportion: ordered.isEmpty ? 0 : onTarget / ordered.length,
  );
}

/// Band preference. `prep` leans easy so preview material is gentler than
/// revision material; `revise` leans hard; `harderOnly` restricts to band 3.
double _bandScore(PoolQuestion question, AssemblyRequest request) {
  if (request.harderOnly) return question.difficulty == 3 ? 1.0 : 0.0;
  return switch (request.mode) {
    QuizMode.prep => switch (question.difficulty) { 1 => 1.0, 2 => 0.8, _ => 0.1 },
    QuizMode.revise => switch (question.difficulty) { 1 => 0.2, 2 => 0.9, _ => 1.0 },
  };
}

double _rank(PoolQuestion question, AssemblyRequest request, Random random) {
  final double band = _bandScore(question, request);
  if (band == 0) return -1;

  // A pack generated for this student is shaped to their learning profile, so
  // it is preferred over the shared pool wherever both are available.
  final double provenance = question.isPersonalised ? 0.6 : 0.0;
  final double weakness = request.weaknessWeights[question.microSkillId] ?? 0.0;

  // Jitter keeps two quizzes on the same chapter from being identical while
  // leaving the ordering above dominant.
  return band + provenance + weakness * 0.8 + random.nextDouble() * 0.25;
}

List<PoolQuestion> _select(
  AssemblyRequest request,
  List<PoolQuestion> candidates,
  Random random,
) {
  final List<PoolQuestion> onTarget = <PoolQuestion>[];
  final List<PoolQuestion> offTarget = <PoolQuestion>[];

  for (final PoolQuestion question in candidates) {
    if (request.targetMicroSkills.contains(question.microSkillId)) {
      onTarget.add(question);
    } else {
      offTarget.add(question);
    }
  }

  // Score once, then sort. Calling _rank inside a comparator would re-roll the
  // jitter on every comparison and produce an ordering that is not even
  // self-consistent, which sort() is entitled to turn into anything.
  List<PoolQuestion> ranked(List<PoolQuestion> input) {
    final List<({PoolQuestion question, double score})> scored = input
        .map((PoolQuestion q) => (question: q, score: _rank(q, request, random)))
        .where((({PoolQuestion question, double score}) e) => e.score >= 0)
        .toList()
      ..sort((({PoolQuestion question, double score}) a,
              ({PoolQuestion question, double score}) b) =>
          b.score.compareTo(a.score));
    return scored
        .map((({PoolQuestion question, double score}) e) => e.question)
        .toList();
  }

  final List<PoolQuestion> rankedOnTarget = ranked(onTarget);
  final List<PoolQuestion> rankedOffTarget = ranked(offTarget);

  if (request.targetMicroSkills.isEmpty) {
    return rankedOffTarget.take(request.count).toList();
  }

  // 70/30. An unbroken wall of a student's own weaknesses is demoralising, so
  // adjacent skills make up the rest.
  final int targetQuota = (request.count * _targetShare).round();
  final List<PoolQuestion> chosen = <PoolQuestion>[
    ...rankedOnTarget.take(targetQuota),
    ...rankedOffTarget.take(request.count - targetQuota),
  ];

  // Backfill from whichever side still has items, so a thin partition never
  // makes the quiz short.
  if (chosen.length < request.count) {
    final Set<String> have = chosen.map((PoolQuestion q) => q.id).toSet();
    for (final PoolQuestion question in <PoolQuestion>[
      ...rankedOnTarget,
      ...rankedOffTarget,
    ]) {
      if (chosen.length >= request.count) break;
      if (have.add(question.id)) chosen.add(question);
    }
  }

  return chosen.take(request.count).toList();
}

/// Reorders so no more than two consecutive items share a micro-skill.
/// Three in a row reads as a broken quiz rather than as targeted practice.
List<PoolQuestion> _spread(List<PoolQuestion> questions, Random random) {
  final List<PoolQuestion> remaining = List<PoolQuestion>.of(questions)..shuffle(random);
  final List<PoolQuestion> output = <PoolQuestion>[];

  while (remaining.isNotEmpty) {
    int pick = 0;

    if (output.length >= 2) {
      final String last = output[output.length - 1].microSkillId;
      final String beforeLast = output[output.length - 2].microSkillId;

      if (last == beforeLast) {
        final int alternative =
            remaining.indexWhere((PoolQuestion q) => q.microSkillId != last);
        // If nothing else is left, a run is unavoidable; taking the item is
        // better than dropping it and returning short.
        if (alternative != -1) pick = alternative;
      }
    }

    output.add(remaining.removeAt(pick));
  }

  return output;
}
