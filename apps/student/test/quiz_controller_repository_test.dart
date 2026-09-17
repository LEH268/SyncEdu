import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:syncedu_student/quiz/quiz_controller.dart';

/// Drives the *real* controller (not `forTesting`) against a seeded local
/// mirror. This is the layer where the router's identity bug lived: the auth
/// user id is `profiles.id`, but `poolFor`, `modeFor` and `recordAttempt` all
/// key off `students.id`.
void main() {
  late SyncEduDatabase db;
  late QuizRepository repository;

  setUp(() async {
    db = SyncEduDatabase.forTesting();
    repository = QuizRepository(db, OutboxWriter(db));
    await seedChapterWithPool(db);
  });
  tearDown(() => db.close());

  Future<QuizController> controllerForProfile(String profileId) async {
    final String? studentId = await repository.studentIdForProfile(profileId);
    expect(studentId, isNotNull,
        reason: 'the router must resolve students.id before building the '
            'controller');
    return QuizController(
      repository: repository,
      studentId: studentId!,
      schoolId: 'school-1',
    );
  }

  test('a quiz resolved from the profile id runs and records an attempt',
      () async {
    final QuizController controller =
        await controllerForProfile('profile-me');

    await controller.startQuiz(chapterIds: <String>['ch1'], count: 4);
    expect(controller.questions, hasLength(4));

    // Personalised items only reach the pool when the *student* id matches.
    expect(
      controller.questions.every((PoolQuestion q) => q.forStudentId != 'theirs'),
      isTrue,
    );

    for (int i = 0; i < controller.questions.length; i++) {
      controller.answer(i.isEven ? controller.questions[i].correctIndex : 99);
    }
    expect(controller.currentQuestion, null);

    final String? attemptId = await controller.submit();
    expect(attemptId, isNotNull);

    final attempts = await db.select(db.attempts).get();
    expect(attempts, hasLength(1));
    expect(attempts.single.studentId, 'student-me',
        reason: 'the attempt must be filed under students.id');
    expect(attempts.single.questionCount, 4);
    expect(attempts.single.score, 2);

    // ...and the local weakness recompute ran without throwing, which is what
    // the profile id used to break on `.getSingle()`.
    final weaknesses = await db.select(db.weaknesses).get();
    expect(weaknesses, isNotEmpty);
  });

  test('modeFor sees the class schedule only with the real students.id',
      () async {
    final QuizController controller =
        await controllerForProfile('profile-me');
    await controller.startQuiz(chapterIds: <String>['ch1'], count: 2);
    await controller.submit();

    final attempts = await db.select(db.attempts).get();
    // ch1 has no taught date in the fixture, so the mode is prep -- but it is
    // prep because the schedule says so, not because the student lookup fell
    // through, which is the failure the profile id produced.
    expect(attempts.single.mode, 'prep');
    expect(await repository.modeFor(<String>['ch1'], 'student-me'),
        QuizMode.prep);
  });

  test('submit is idempotent for one quiz session', () async {
    final QuizController controller =
        await controllerForProfile('profile-me');
    await controller.startQuiz(chapterIds: <String>['ch1'], count: 3);
    for (int i = 0; i < 3; i++) {
      controller.answer(0);
    }

    final String? first = await controller.submit();
    final String? second = await controller.submit();
    final String? third = await controller.submit();

    expect(controller.isSubmitted, isTrue);
    expect(second, first);
    expect(third, first);
    expect(await db.select(db.attempts).get(), hasLength(1),
        reason: 'a re-entrant onComplete must not record a second attempt');
    expect(await db.select(db.attemptItems).get(), hasLength(3));
  });

  test('a reassembled quiz may be submitted again', () async {
    final QuizController controller =
        await controllerForProfile('profile-me');
    await controller.startQuiz(chapterIds: <String>['ch1'], count: 2);
    controller
      ..answer(0)
      ..answer(0);
    final String? first = await controller.submit();

    await controller.regenerate();
    expect(controller.isSubmitted, isFalse);
    controller
      ..answer(0)
      ..answer(0);
    final String? second = await controller.submit();

    expect(second, isNot(first));
    final attempts = await db.select(db.attempts).get();
    expect(attempts, hasLength(2));
    expect(
      attempts.map((Attempt a) => a.parentAttemptId).whereType<String>(),
      <String>[first!],
      reason: 'the second attempt chains off the first',
    );
  });

  test('an empty quiz records no attempt at all', () async {
    final QuizController controller =
        await controllerForProfile('profile-me');
    // No pool for ch2, so assembly comes back empty.
    await controller.startQuiz(chapterIds: <String>['ch2'], count: 10);
    expect(controller.questions, isEmpty);

    expect(await controller.submit(), null);
    expect(await db.select(db.attempts).get(), isEmpty,
        reason: 'question_count > 0 server-side: a zero-length attempt could '
            'never sync');
    expect(await db.select(db.outbox).get(), isEmpty);
  });

  test('notes come back keyed by micro-skill', () async {
    final QuizController controller =
        await controllerForProfile('profile-me');
    await controller.startQuiz(chapterIds: <String>['ch1'], count: 6);
    for (int i = 0; i < controller.questions.length; i++) {
      controller.answer(99);
    }
    await controller.generateNotes();

    expect(controller.missedMicroSkills, isNotEmpty);
    // skill-2 has no explanation on file; skill-1 does. A positional pairing
    // would file skill-1's body under skill-2 half the time.
    if (controller.missedMicroSkills.contains('skill-1')) {
      expect(controller.notes['skill-1']!.single, contains('factorise'));
    }
    expect(controller.notes.containsKey('skill-2'), isFalse);
  });
}
