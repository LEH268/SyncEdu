import 'package:drift/drift.dart';

import '../db/database.dart';

/// Seeds a school, class, student, two chapters, two micro-skills, one
/// explanation, and a pool of twelve shared questions plus two personalised
/// ones -- enough for the quiz repository tests to exercise assembly, mode
/// detection, and personalisation isolation without each test re-deriving
/// its own fixture.
Future<void> seedChapterWithPool(SyncEduDatabase db) async {
  final DateTime now = DateTime.utc(2026, 1, 1);

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

  await db.into(db.students).insert(
        StudentsCompanion.insert(
          id: 'student-me',
          schoolId: 'school-1',
          profileId: 'profile-me',
          classId: const Value('class-1'),
          createdAt: now,
          updatedAt: now,
        ),
      );

  await db.into(db.students).insert(
        StudentsCompanion.insert(
          id: 'student-other',
          schoolId: 'school-1',
          profileId: 'profile-other',
          classId: const Value('class-1'),
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

  await db.into(db.chapters).insert(
        ChaptersCompanion.insert(
          id: 'ch2',
          schoolId: 'school-1',
          subjectId: 'subject-1',
          ordinal: 2,
          title: 'Chapter 2',
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

  await db.into(db.microSkills).insert(
        MicroSkillsCompanion.insert(
          id: 'skill-2',
          schoolId: 'school-1',
          chapterId: 'ch1',
          slug: 'skill-two',
          label: 'Skill Two',
          ordinal: 2,
          createdAt: now,
          updatedAt: now,
        ),
      );

  await db.into(db.microSkillExplanations).insert(
        MicroSkillExplanationsCompanion.insert(
          id: 'explanation-1',
          schoolId: 'school-1',
          microSkillId: 'skill-1',
          body:
              'To factorise a quadratic, find two numbers that multiply to give '
              'the constant term and add to give the middle term.',
          createdAt: now,
          updatedAt: now,
        ),
      );

  // Twelve shared pool questions: two micro-skills x three difficulty bands
  // x two questions each.
  int ordinal = 0;
  for (final String skillId in <String>['skill-1', 'skill-2']) {
    for (final int difficulty in <int>[1, 2, 3]) {
      for (int i = 0; i < 2; i++) {
        ordinal++;
        await db.into(db.questions).insert(
              QuestionsCompanion.insert(
                id: 'pool-q$ordinal',
                schoolId: 'school-1',
                chapterId: 'ch1',
                microSkillId: skillId,
                difficulty: difficulty,
                stem: 'Question $ordinal for $skillId at difficulty $difficulty',
                options: '["A","B","C","D"]',
                correctIndex: 0,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    }
  }

  // One personalised question for the student under test.
  await db.into(db.questions).insert(
        QuestionsCompanion.insert(
          id: 'mine',
          schoolId: 'school-1',
          chapterId: 'ch1',
          microSkillId: 'skill-1',
          difficulty: 1,
          stem: 'Personalised question for student-me',
          options: '["A","B","C","D"]',
          correctIndex: 0,
          provenance: const Value('personalised'),
          forStudentId: const Value('student-me'),
          createdAt: now,
          updatedAt: now,
        ),
      );

  // One personalised question for a different student -- must never leak
  // into student-me's pool.
  await db.into(db.questions).insert(
        QuestionsCompanion.insert(
          id: 'theirs',
          schoolId: 'school-1',
          chapterId: 'ch1',
          microSkillId: 'skill-1',
          difficulty: 1,
          stem: 'Personalised question for student-other',
          options: '["A","B","C","D"]',
          correctIndex: 0,
          provenance: const Value('personalised'),
          forStudentId: const Value('student-other'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}
