import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

void main() {
  late SyncEduDatabase db;
  late AnalyticsRepository repository;

  final DateTime now = DateTime.utc(2026, 1, 1);

  Future<void> seedSchool() async {
    await db.into(db.schools).insert(
          SchoolsCompanion.insert(
            id: 'school-1',
            name: 'Test School',
            educationLevel: 'secondary',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.classes).insert(
          ClassesCompanion.insert(
            id: 'class-1',
            schoolId: 'school-1',
            name: 'Class 1',
            yearLevel: 9,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'subject-1',
            schoolId: 'school-1',
            name: 'Maths',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.chapters).insert(
          ChaptersCompanion.insert(
            id: 'ch1',
            schoolId: 'school-1',
            subjectId: 'subject-1',
            ordinal: 1,
            title: 'Chapter 1',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.microSkills).insert(
          MicroSkillsCompanion.insert(
            id: 'skill-1',
            schoolId: 'school-1',
            chapterId: 'ch1',
            slug: 'skill-one',
            label: 'Skill One',
            ordinal: 1,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> seedProfile(String id, String fullName) async {
    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: id,
            schoolId: 'school-1',
            role: 'student',
            fullName: fullName,
            email: '$id@example.com',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> seedStudent(String id, String profileId, {String? classId}) async {
    await db.into(db.students).insert(
          StudentsCompanion.insert(
            id: id,
            schoolId: 'school-1',
            profileId: profileId,
            classId: Value(classId),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> seedAttempt(
    String id,
    String studentId, {
    String mode = 'revise',
    DateTime? deletedAt,
  }) async {
    await db.into(db.attempts).insert(
          AttemptsCompanion.insert(
            id: id,
            schoolId: 'school-1',
            studentId: studentId,
            mode: mode,
            questionCount: 1,
            submittedAt: Value(now),
            createdAt: now,
            updatedAt: now,
            deletedAt: Value(deletedAt),
          ),
        );
  }

  Future<void> seedAttemptItem(
    String id,
    String attemptId, {
    bool isCorrect = true,
    DateTime? deletedAt,
  }) async {
    await db.into(db.attemptItems).insert(
          AttemptItemsCompanion.insert(
            id: id,
            schoolId: 'school-1',
            attemptId: attemptId,
            microSkillId: 'skill-1',
            isCorrect: isCorrect,
            ordinal: 1,
            createdAt: now,
            updatedAt: now,
            deletedAt: Value(deletedAt),
          ),
        );
  }

  setUp(() async {
    db = SyncEduDatabase.forTesting();
    repository = AnalyticsRepository(db);
    await seedSchool();
  });
  tearDown(() => db.close());

  test('joins attempt_items to attempts, students, chapters and micro-skills',
      () async {
    await seedProfile('profile-1', 'Ada Lovelace');
    await seedStudent('student-1', 'profile-1', classId: 'class-1');
    await seedAttempt('attempt-1', 'student-1');
    await seedAttemptItem('item-1', 'attempt-1');

    final List<AnalyticRow> rows = await repository.watchRows().first;

    expect(rows, hasLength(1));
    final AnalyticRow row = rows.single;
    expect(row.studentId, 'student-1');
    expect(row.attemptId, 'attempt-1');
    expect(row.microSkillId, 'skill-1');
    expect(row.chapterId, 'ch1');
  });

  test('a row carries the labels the analytics functions need for display',
      () async {
    await seedProfile('profile-1', 'Ada Lovelace');
    await seedStudent('student-1', 'profile-1', classId: 'class-1');
    await seedAttempt('attempt-1', 'student-1');
    await seedAttemptItem('item-1', 'attempt-1', isCorrect: false);

    final AnalyticRow row = (await repository.watchRows().first).single;

    expect(row.studentName, 'Ada Lovelace');
    expect(row.className, 'Class 1');
    expect(row.chapterTitle, 'Chapter 1');
    expect(row.microSkillLabel, 'Skill One');
    expect(row.subjectName, 'Maths');
    expect(row.isCorrect, isFalse);
    expect(row.mode, 'revise');
    expect(row.submittedAt, now);
  });

  test('watching emits again when an attempt is inserted', () async {
    await seedProfile('profile-1', 'Ada Lovelace');
    await seedStudent('student-1', 'profile-1', classId: 'class-1');

    final Stream<List<AnalyticRow>> stream = repository.watchRows();
    final List<List<AnalyticRow>> emissions = <List<AnalyticRow>>[];
    final Future<void> done = stream.take(2).forEach(emissions.add);

    await seedAttempt('attempt-1', 'student-1');
    await seedAttemptItem('item-1', 'attempt-1');

    await done;

    expect(emissions.first, isEmpty);
    expect(emissions.last, hasLength(1));
  });

  test('tombstoned attempts are excluded', () async {
    await seedProfile('profile-1', 'Ada Lovelace');
    await seedStudent('student-1', 'profile-1', classId: 'class-1');
    await seedAttempt('attempt-1', 'student-1', deletedAt: now);
    await seedAttemptItem('item-1', 'attempt-1');

    final List<AnalyticRow> rows = await repository.watchRows().first;

    expect(rows, isEmpty);
  });

  test('filtering by class returns only that class\'s rows', () async {
    await db.into(db.classes).insert(
          ClassesCompanion.insert(
            id: 'class-2',
            schoolId: 'school-1',
            name: 'Class 2',
            yearLevel: 10,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await seedProfile('profile-1', 'Ada Lovelace');
    await seedStudent('student-1', 'profile-1', classId: 'class-1');
    await seedAttempt('attempt-1', 'student-1');
    await seedAttemptItem('item-1', 'attempt-1');

    await seedProfile('profile-2', 'Bertie Bott');
    await seedStudent('student-2', 'profile-2', classId: 'class-2');
    await seedAttempt('attempt-2', 'student-2');
    await seedAttemptItem('item-2', 'attempt-2');

    final List<AnalyticRow> rows =
        await repository.watchRows(classId: 'class-1').first;

    expect(rows, hasLength(1));
    expect(rows.single.studentId, 'student-1');
  });

  test('a soft-deleted profile is excluded from the stream', () async {
    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: 'profile-1',
            schoolId: 'school-1',
            role: 'student',
            fullName: 'Deactivated Student',
            email: 'profile-1@example.com',
            createdAt: now,
            updatedAt: now,
            deletedAt: Value(now),
          ),
        );
    await seedStudent('student-1', 'profile-1', classId: 'class-1');
    await seedAttempt('attempt-1', 'student-1');
    await seedAttemptItem('item-1', 'attempt-1');

    final List<AnalyticRow> rows = await repository.watchRows().first;

    expect(rows, isEmpty);
  });

  test('a soft-deleted class is excluded from the stream', () async {
    await db.update(db.classes).write(
          ClassesCompanion(deletedAt: Value(now)),
        );

    await seedProfile('profile-1', 'Ada Lovelace');
    await seedStudent('student-1', 'profile-1', classId: 'class-1');
    await seedAttempt('attempt-1', 'student-1');
    await seedAttemptItem('item-1', 'attempt-1');

    final List<AnalyticRow> rows = await repository.watchRows().first;

    expect(rows, isEmpty);
  });

  test('a student with no class still appears in the unfiltered stream',
      () async {
    await seedProfile('profile-1', 'Ada Lovelace');
    await seedStudent('student-1', 'profile-1');
    await seedAttempt('attempt-1', 'student-1');
    await seedAttemptItem('item-1', 'attempt-1');

    final List<AnalyticRow> rows = await repository.watchRows().first;

    expect(rows, hasLength(1));
    expect(rows.single.studentId, 'student-1');
    expect(rows.single.classId, '');
  });
}
