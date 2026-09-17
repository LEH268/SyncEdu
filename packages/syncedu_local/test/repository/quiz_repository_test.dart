import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// RFC 4122 v4, exactly what Postgres accepts for a `uuid` column.
final RegExp uuidV4Pattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  late SyncEduDatabase db;
  late QuizRepository repository;

  setUp(() async {
    db = SyncEduDatabase.forTesting();
    repository = QuizRepository(db, OutboxWriter(db));
    await seedChapterWithPool(db);
  });
  tearDown(() => db.close());

  test('poolFor returns shared items and this student\'s personalised ones',
      () async {
    final pool = await repository.poolFor(<String>['ch1'], 'student-me');

    expect(pool.any((PoolQuestion q) => q.provenance == 'pool'), isTrue);
    expect(pool.any((PoolQuestion q) => q.id == 'mine'), isTrue);
    expect(
      pool.any((PoolQuestion q) => q.id == 'theirs'),
      isFalse,
      reason: 'another student\'s personalised items must never appear',
    );
  });

  test('modeFor is prep when the chapter has no taught date', () async {
    expect(await repository.modeFor(<String>['ch1'], 'student-me'), QuizMode.prep);
  });

  test('modeFor is revise once the chapter is taught', () async {
    await db.into(db.classChapterSched).insert(
          ClassChapterSchedCompanion.insert(
            id: 'sched-1',
            schoolId: 'school-1',
            classId: 'class-1',
            chapterId: 'ch1',
            taughtOn: Value(DateTime.utc(2026, 8, 1)),
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    expect(await repository.modeFor(<String>['ch1'], 'student-me'), QuizMode.revise);
  });

  test('modeFor is prep when a taught date is still in the future', () async {
    await db.into(db.classChapterSched).insert(
          ClassChapterSchedCompanion.insert(
            id: 'sched-2',
            schoolId: 'school-1',
            classId: 'class-1',
            chapterId: 'ch1',
            taughtOn: Value(DateTime.now().add(const Duration(days: 14))),
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    expect(await repository.modeFor(<String>['ch1'], 'student-me'), QuizMode.prep);
  });

  test('modeFor is prep when any chosen chapter is untaught', () async {
    // A mixed range is a preview: grading it against the class's progress
    // would put untaught material into the teacher's analytics.
    await db.into(db.classChapterSched).insert(
          ClassChapterSchedCompanion.insert(
            id: 'sched-3', schoolId: 'school-1', classId: 'class-1',
            chapterId: 'ch1', taughtOn: Value(DateTime.utc(2026, 8, 1)),
            createdAt: DateTime.utc(2026, 8, 1), updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    expect(
      await repository.modeFor(<String>['ch1', 'ch2'], 'student-me'),
      QuizMode.prep,
    );
  });

  test('recordAttempt writes the attempt, its items, and outbox entries',
      () async {
    final pool = await repository.poolFor(<String>['ch1'], 'student-me');

    final attemptId = await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me',
        schoolId: 'school-1',
        chapterIds: <String>['ch1'],
        mode: QuizMode.revise,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: pool[0], selectedIndex: pool[0].correctIndex),
          AnsweredQuestion(question: pool[1], selectedIndex: 99),
        ],
      ),
    );

    final attempts = await db.select(db.attempts).get();
    expect(attempts, hasLength(1));
    expect(attempts.single.id, attemptId);
    expect(attempts.single.score, 1);
    expect(attempts.single.questionCount, 2);
    expect(attempts.single.mode, 'revise');

    final items = await db.select(db.attemptItems).get();
    expect(items, hasLength(2));

    // Attempts are tier-1 append-only, so they replay as idempotent inserts.
    final outbox = await db.select(db.outbox).get();
    expect(outbox.where((OutboxData e) => e.op == 'insert').length, 3);
  });

  test('a retry records its parent and increments the attempt number',
      () async {
    final pool = await repository.poolFor(<String>['ch1'], 'student-me');
    final first = await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me', schoolId: 'school-1',
        chapterIds: <String>['ch1'], mode: QuizMode.revise,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: pool[0], selectedIndex: 0),
        ],
      ),
    );

    await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me', schoolId: 'school-1',
        chapterIds: <String>['ch1'], mode: QuizMode.revise,
        parentAttemptId: first,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: pool[1], selectedIndex: 0),
        ],
      ),
    );

    final attempts = await db.select(db.attempts).get()
      ..sort((Attempt a, Attempt b) => a.attemptNumber.compareTo(b.attemptNumber));
    expect(attempts.map((Attempt a) => a.attemptNumber).toList(), <int>[1, 2]);
    expect(attempts.last.parentAttemptId, first);
  });

  test('recentlySeenFor covers the last few attempts only', () async {
    final pool = await repository.poolFor(<String>['ch1'], 'student-me');
    for (int i = 0; i < 3; i++) {
      await repository.recordAttempt(
        draft: AttemptDraft(
          studentId: 'student-me', schoolId: 'school-1',
          chapterIds: <String>['ch1'], mode: QuizMode.revise,
          answers: <AnsweredQuestion>[
            AnsweredQuestion(question: pool[i], selectedIndex: 0),
          ],
        ),
      );
    }

    final seen = await repository.recentlySeenFor('student-me', lastAttempts: 2);
    expect(seen, hasLength(2));
    expect(seen.contains(pool[0].id), isFalse);
  });

  test('explanationsFor keys bodies by micro-skill, not by position',
      () async {
    // skill-2 has no explanation on file. A flat list would leave the caller
    // pairing skill-1's body against whichever skill happened to sort first.
    final bodies =
        await repository.explanationsFor(<String>{'skill-1', 'skill-2'});

    expect(bodies.keys, <String>{'skill-1'});
    expect(bodies['skill-1'], hasLength(1));
    expect(bodies['skill-1']!.single, contains('factorise'));
    expect(bodies['skill-2'], null);
  });

  test('explanationsFor collects every body a skill has', () async {
    await db.into(db.microSkillExplanations).insert(
          MicroSkillExplanationsCompanion.insert(
            id: 'explanation-2',
            schoolId: 'school-1',
            microSkillId: 'skill-1',
            body: 'A second way of looking at the same idea.',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );

    final bodies = await repository.explanationsFor(<String>{'skill-1'});
    expect(bodies['skill-1'], hasLength(2));
  });

  test('studentIdForProfile resolves students.id from the profile id',
      () async {
    expect(await repository.studentIdForProfile('profile-me'), 'student-me');
    expect(await repository.studentIdForProfile('profile-other'),
        'student-other');
    // A profile whose student row has not been pulled yet is "not ready", not
    // an excuse to fall back to the profile id.
    expect(await repository.studentIdForProfile('profile-unsynced'), null);
  });

  test('weaknessWeightsFor reflects wrong answers', () async {
    final pool = await repository.poolFor(<String>['ch1'], 'student-me');
    final wrong = pool.firstWhere((PoolQuestion q) => q.microSkillId == 'skill-1');

    await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me', schoolId: 'school-1',
        chapterIds: <String>['ch1'], mode: QuizMode.revise,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: wrong, selectedIndex: 99),
        ],
      ),
    );

    final weights = await repository.weaknessWeightsFor('student-me');
    expect(weights['skill-1'], greaterThan(0.5));
  });

  test('every id recordAttempt mints is a real UUID', () async {
    // The server columns are `uuid primary key`. Anything else is rejected
    // with 22P02 when the outbox drains, stranding the attempt forever.
    final pool = await repository.poolFor(<String>['ch1'], 'student-me');

    final attemptId = await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me', schoolId: 'school-1',
        chapterIds: <String>['ch1'], mode: QuizMode.revise,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: pool[0], selectedIndex: 0),
          AnsweredQuestion(question: pool[1], selectedIndex: 99),
        ],
      ),
    );

    expect(attemptId, matches(uuidV4Pattern));

    final items = await db.select(db.attemptItems).get();
    expect(items, hasLength(2));
    for (final AttemptItem item in items) {
      expect(item.id, matches(uuidV4Pattern));
    }

    final weaknesses = await db.select(db.weaknesses).get();
    expect(weaknesses, isNotEmpty);
    for (final WeaknessesData row in weaknesses) {
      expect(row.id, matches(uuidV4Pattern));
    }

    // The ids that actually travel are the ones in the outbox payload.
    final outbox = await db.select(db.outbox).get();
    for (final OutboxData entry in outbox) {
      final payload = jsonDecode(entry.payload!) as Map<String, dynamic>;
      expect(payload['id'], matches(uuidV4Pattern),
          reason: 'outbox payload for ${entry.table} carries a non-UUID id');
      expect(entry.rowId, matches(uuidV4Pattern));
    }
  });

  test('a server weakness row replaces the local one for the same skill',
      () async {
    // The SQL trigger inserts with gen_random_uuid() and conflicts on
    // (student_id, micro_skill_id, source). Without the same unique key
    // locally, a pull would land a *second* row for the same skill and
    // weaknessWeightsFor would sum both toward 1.0.
    final pool = await repository.poolFor(<String>['ch1'], 'student-me');
    final wrong = pool.firstWhere((PoolQuestion q) => q.microSkillId == 'skill-1');

    await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me', schoolId: 'school-1',
        chapterIds: <String>['ch1'], mode: QuizMode.revise,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: wrong, selectedIndex: 99),
        ],
      ),
    );

    final localRows = await db.select(db.weaknesses).get();
    expect(localRows, hasLength(1));
    final localWeight = localRows.single.weight;
    expect(localWeight, greaterThan(0.5));

    // ...now the puller writes the server's own row for the same triple, with
    // the server's id. The descriptors all use insertOrReplace.
    await db.into(db.weaknesses).insert(
          WeaknessesCompanion.insert(
            id: 'a7f0f2b0-0000-4000-8000-000000000001',
            schoolId: 'school-1',
            studentId: 'student-me',
            microSkillId: 'skill-1',
            weight: localWeight,
            source: 'quiz',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
          mode: InsertMode.insertOrReplace,
        );

    final afterPull = await db.select(db.weaknesses).get();
    expect(afterPull, hasLength(1),
        reason: 'the server row must land on the local row, not beside it');
    expect(afterPull.single.id, 'a7f0f2b0-0000-4000-8000-000000000001');

    final weights = await repository.weaknessWeightsFor('student-me');
    expect(weights['skill-1'], closeTo(localWeight, 1e-9),
        reason: 'a synced row must not double-count the local one');

    // And a further local recompute writes back onto that same row rather
    // than minting a third.
    await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me', schoolId: 'school-1',
        chapterIds: <String>['ch1'], mode: QuizMode.revise,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: wrong, selectedIndex: 99),
        ],
      ),
    );
    expect(await db.select(db.weaknesses).get(), hasLength(1));
  });

  test('a soft-deleted attempt is excluded from the recomputed weight',
      () async {
    final pool = await repository.poolFor(<String>['ch1'], 'student-me');
    final wrong = pool.firstWhere((PoolQuestion q) => q.microSkillId == 'skill-1');
    final correct = pool
        .where((PoolQuestion q) => q.microSkillId == 'skill-1')
        .toList()[1];

    // A wrong answer establishes a nonzero weight...
    await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me', schoolId: 'school-1',
        chapterIds: <String>['ch1'], mode: QuizMode.revise,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: wrong, selectedIndex: 99),
        ],
      ),
    );
    final weightBeforeDelete =
        (await repository.weaknessWeightsFor('student-me'))['skill-1'];
    expect(weightBeforeDelete, greaterThan(0.5));

    // ...then soft-deleting that attempt and its item, and recording a fresh
    // correct answer, must make the weight reflect only the live rows -- the
    // server's recompute_weaknesses excludes deleted rows the same way.
    await db.update(db.attempts).write(
          AttemptsCompanion(deletedAt: Value(DateTime.now().toUtc())),
        );
    await db.update(db.attemptItems).write(
          AttemptItemsCompanion(deletedAt: Value(DateTime.now().toUtc())),
        );

    await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: 'student-me', schoolId: 'school-1',
        chapterIds: <String>['ch1'], mode: QuizMode.revise,
        answers: <AnsweredQuestion>[
          AnsweredQuestion(question: correct, selectedIndex: correct.correctIndex),
        ],
      ),
    );

    final weights = await repository.weaknessWeightsFor('student-me');
    expect(weights['skill-1'], 0,
        reason: 'the wrong answer sits on a soft-deleted attempt, so only '
            'the fresh correct answer should count');
  });
}
