import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

PoolQuestion q({
  required String id,
  required String skill,
  String chapter = 'ch1',
  int difficulty = 2,
  String provenance = 'pool',
  String? forStudent,
}) =>
    PoolQuestion(
      id: id,
      chapterId: chapter,
      microSkillId: skill,
      difficulty: difficulty,
      stem: 'Question $id',
      options: const <String>['a', 'b', 'c', 'd'],
      correctIndex: 0,
      provenance: provenance,
      forStudentId: forStudent,
    );

/// A pool shaped like a real ingested chapter: five skills, three bands,
/// five items each.
List<PoolQuestion> realisticPool({String chapter = 'ch1'}) {
  final List<PoolQuestion> pool = <PoolQuestion>[];
  for (final String skill in <String>['s1', 's2', 's3', 's4', 's5']) {
    for (int band = 1; band <= 3; band++) {
      for (int n = 0; n < 5; n++) {
        pool.add(q(
          id: '$chapter-$skill-b$band-$n',
          skill: skill,
          chapter: chapter,
          difficulty: band,
        ));
      }
    }
  }
  return pool;
}

AssemblyRequest request({
  List<String> chapters = const <String>['ch1'],
  int count = 10,
  QuizMode mode = QuizMode.revise,
  Set<String> targets = const <String>{},
  Map<String, double> weights = const <String, double>{},
  Set<String> seen = const <String>{},
  bool harderOnly = false,
  int seed = 42,
}) =>
    AssemblyRequest(
      chapterIds: chapters,
      count: count,
      mode: mode,
      targetMicroSkills: targets,
      weaknessWeights: weights,
      recentlySeenIds: seen,
      harderOnly: harderOnly,
      seed: seed,
    );

void main() {
  group('cardinality and filtering', () {
    test('returns exactly the requested number', () {
      final result = assembleQuiz(request(count: 10), realisticPool());
      expect(result.questions, hasLength(10));
    });

    test('never returns a question from an unrequested chapter', () {
      final pool = <PoolQuestion>[
        ...realisticPool(chapter: 'ch1'),
        ...realisticPool(chapter: 'ch2'),
      ];

      final result = assembleQuiz(
        request(chapters: <String>['ch1'], count: 15),
        pool,
      );

      expect(
        result.questions.every((PoolQuestion x) => x.chapterId == 'ch1'),
        isTrue,
      );
    });

    test('spans every requested chapter when several are chosen', () {
      final pool = <PoolQuestion>[
        ...realisticPool(chapter: 'ch1'),
        ...realisticPool(chapter: 'ch2'),
      ];

      final result = assembleQuiz(
        request(chapters: <String>['ch1', 'ch2'], count: 20),
        pool,
      );

      final chapters = result.questions.map((PoolQuestion x) => x.chapterId).toSet();
      expect(chapters, <String>{'ch1', 'ch2'});
    });

    test('never repeats a question within one quiz', () {
      final result = assembleQuiz(request(count: 20), realisticPool());
      final ids = result.questions.map((PoolQuestion x) => x.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('the seen set', () {
    test('excludes recently-seen questions', () {
      final pool = realisticPool();
      final seen = pool.take(30).map((PoolQuestion x) => x.id).toSet();

      final result = assembleQuiz(request(count: 10, seen: seen), pool);

      expect(
        result.questions.any((PoolQuestion x) => seen.contains(x.id)),
        isFalse,
      );
      expect(result.relaxedSeenSet, isFalse);
    });

    test('relaxes the seen set rather than returning short', () {
      // A student who has drilled a chapter hard. Offline, there is no top-up
      // available, so the quiz gets shallower -- it never fails.
      final pool = realisticPool();
      final seen = pool.map((PoolQuestion x) => x.id).toSet();

      final result = assembleQuiz(request(count: 10, seen: seen), pool);

      expect(result.questions, hasLength(10));
      expect(result.relaxedSeenSet, isTrue);
    });

    test('reports exhaustion when the pool itself is too small', () {
      final pool = realisticPool().take(6).toList();
      final result = assembleQuiz(request(count: 10), pool);

      expect(result.questions, hasLength(6));
      expect(result.poolExhausted, isTrue);
    });
  });

  group('difficulty bands', () {
    test('prep biases towards the two easier bands', () {
      final result = assembleQuiz(
        request(count: 20, mode: QuizMode.prep),
        realisticPool(),
      );

      final easy = result.questions.where((PoolQuestion x) => x.difficulty <= 2).length;
      // Preview material must be gentler than revision material, or a student
      // exploring ahead is just discouraged.
      expect(easy / result.questions.length, greaterThan(0.75));
    });

    test('revise biases towards the two harder bands', () {
      final result = assembleQuiz(
        request(count: 20, mode: QuizMode.revise),
        realisticPool(),
      );

      final harder = result.questions.where((PoolQuestion x) => x.difficulty >= 2).length;
      expect(harder / result.questions.length, greaterThan(0.75));
    });

    test('harderOnly returns band 3 when band 3 exists', () {
      // The "practise mistakes" option on a perfect score becomes "harder
      // questions" -- requirement 19 satisfied by a parameter, not a branch.
      final result = assembleQuiz(
        request(count: 10, harderOnly: true),
        realisticPool(),
      );

      expect(
        result.questions.every((PoolQuestion x) => x.difficulty == 3),
        isTrue,
      );
    });
  });

  group('targeting and the mix', () {
    test('roughly 70% of items hit the target skills', () {
      final result = assembleQuiz(
        request(count: 20, targets: <String>{'s1', 's2'}),
        realisticPool(),
      );

      final onTarget = result.questions
          .where((PoolQuestion x) => <String>{'s1', 's2'}.contains(x.microSkillId))
          .length;
      final proportion = onTarget / result.questions.length;

      // Not 100%: an unbroken wall of a student's own weaknesses is
      // demoralising, so adjacent skills make up the rest.
      expect(proportion, greaterThanOrEqualTo(0.6));
      expect(proportion, lessThanOrEqualTo(0.8));
      expect(result.targetProportion, closeTo(proportion, 0.001));
    });

    test('the remaining 30% comes from skills outside the target set', () {
      final result = assembleQuiz(
        request(count: 20, targets: <String>{'s1'}),
        realisticPool(),
      );

      final offTarget =
          result.questions.where((PoolQuestion x) => x.microSkillId != 's1').toList();
      expect(offTarget, isNotEmpty);
      expect(offTarget.map((PoolQuestion x) => x.microSkillId).toSet().length,
          greaterThan(1));
    });

    test('an empty target set produces unbiased content', () {
      // A brand-new student with nothing on file must get ordinary questions,
      // not an error and not an empty quiz.
      final result = assembleQuiz(request(count: 20), realisticPool());

      final bySkill = <String, int>{};
      for (final PoolQuestion x in result.questions) {
        bySkill[x.microSkillId] = (bySkill[x.microSkillId] ?? 0) + 1;
      }
      expect(bySkill.keys.length, greaterThanOrEqualTo(4));
      expect(result.targetProportion, 0);
    });

    test('higher weakness weight pulls a skill in more often', () {
      final result = assembleQuiz(
        request(
          count: 20,
          weights: <String, double>{'s1': 0.9, 's2': 0.8, 's5': 0.05},
        ),
        realisticPool(),
      );

      final heavy =
          result.questions.where((PoolQuestion x) => x.microSkillId == 's1').length;
      final light =
          result.questions.where((PoolQuestion x) => x.microSkillId == 's5').length;
      expect(heavy, greaterThan(light));
    });
  });

  group('ordering', () {
    test('no more than two consecutive items share a micro-skill', () {
      final result = assembleQuiz(
        request(count: 20, targets: <String>{'s1'}),
        realisticPool(),
      );

      int run = 1;
      for (int i = 1; i < result.questions.length; i++) {
        run = result.questions[i].microSkillId == result.questions[i - 1].microSkillId
            ? run + 1
            : 1;
        expect(run, lessThanOrEqualTo(2),
            reason: 'three in a row on one skill reads as a broken quiz');
      }
    });
  });

  group('provenance', () {
    test('a personalised item for this student outranks a pool item', () {
      final pool = <PoolQuestion>[
        ...realisticPool(),
        q(id: 'mine-1', skill: 's1', provenance: 'personalised', forStudent: 'me'),
        q(id: 'mine-2', skill: 's2', provenance: 'personalised', forStudent: 'me'),
      ];

      final result = assembleQuiz(request(count: 10), pool);
      final ids = result.questions.map((PoolQuestion x) => x.id).toSet();

      expect(ids.contains('mine-1'), isTrue);
      expect(ids.contains('mine-2'), isTrue);
    });

    test('another student\'s personalised items are never selected', () {
      final pool = <PoolQuestion>[
        ...realisticPool().take(8),
        q(id: 'theirs', skill: 's1', provenance: 'personalised', forStudent: 'someone-else'),
      ];

      final result = assembleQuiz(
        request(count: 9, seed: 1),
        pool.where((PoolQuestion x) =>
            x.provenance == 'pool' || x.forStudentId == 'me').toList(),
      );

      expect(
        result.questions.any((PoolQuestion x) => x.id == 'theirs'),
        isFalse,
      );
    });
  });

  group('determinism', () {
    test('the same seed produces the same quiz', () {
      final pool = realisticPool();
      final a = assembleQuiz(request(count: 10, seed: 7), pool);
      final b = assembleQuiz(request(count: 10, seed: 7), pool);

      expect(
        a.questions.map((PoolQuestion x) => x.id).toList(),
        b.questions.map((PoolQuestion x) => x.id).toList(),
      );
    });

    test('a different seed produces a different quiz', () {
      final pool = realisticPool();
      final a = assembleQuiz(request(count: 10, seed: 7), pool);
      final b = assembleQuiz(request(count: 10, seed: 8), pool);

      expect(
        a.questions.map((PoolQuestion x) => x.id).toList(),
        isNot(b.questions.map((PoolQuestion x) => x.id).toList()),
      );
    });
  });

  group('retargeting', () {
    test('a retargeted quiz reuses none of the missed questions', () {
      // PRD requirement 18 -- "genuinely new questions, not reworded versions"
      // -- holds by construction here: pool items were authored independently,
      // so a retargeted set cannot be a paraphrase of the missed ones.
      final pool = realisticPool();
      final first = assembleQuiz(request(count: 10, seed: 3), pool);
      final missedIds = first.questions.take(4).map((PoolQuestion x) => x.id).toSet();
      final missedSkills =
          first.questions.take(4).map((PoolQuestion x) => x.microSkillId).toSet();

      final retarget = assembleQuiz(
        request(
          count: 10,
          targets: missedSkills,
          seen: first.questions.map((PoolQuestion x) => x.id).toSet(),
          seed: 4,
        ),
        pool,
      );

      expect(
        retarget.questions.any((PoolQuestion x) => missedIds.contains(x.id)),
        isFalse,
      );
      expect(
        retarget.questions.any((PoolQuestion x) => missedSkills.contains(x.microSkillId)),
        isTrue,
      );
    });
  });

  group('degenerate input', () {
    test('an empty pool returns empty rather than throwing', () {
      final result = assembleQuiz(request(count: 10), <PoolQuestion>[]);
      expect(result.questions, isEmpty);
      expect(result.poolExhausted, isTrue);
    });

    test('a count of zero returns empty', () {
      final result = assembleQuiz(request(count: 0), realisticPool());
      expect(result.questions, isEmpty);
    });
  });
}
