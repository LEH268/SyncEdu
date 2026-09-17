import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// Registration for one mirrored table. Adding a table in a later phase is a
/// new entry here, not new engine code.
class SyncDescriptor {
  const SyncDescriptor({required this.table, required this.upsert});

  final String table;
  final Future<void> Function(SyncEduDatabase db, List<Map<String, dynamic>> rows)
      upsert;
}

final RegExp _dateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Parses a timestamp to UTC. A bare SQL `date` (`YYYY-MM-DD`, no zone) would
/// otherwise be read as local midnight and drift a day per sync round trip, so
/// it is pinned to UTC midnight explicitly.
DateTime _time(Object? value) {
  final String text = value! as String;
  if (_dateOnly.hasMatch(text)) return DateTime.parse('${text}T00:00:00Z');
  return DateTime.parse(text).toUtc();
}

DateTime? _timeOrNull(Object? value) =>
    value == null ? null : _time(value);

final List<SyncDescriptor> defaultDescriptors = <SyncDescriptor>[
  SyncDescriptor(
    table: 'schools',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.schools,
            SchoolsCompanion.insert(
              id: row['id'] as String,
              name: row['name'] as String,
              educationLevel: row['education_level'] as String,
              contentLanguage: Value(row['content_language'] as String),
              maxOfflineDays: Value(row['max_offline_days'] as int),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'profiles',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.profiles,
            ProfilesCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              role: row['role'] as String,
              fullName: row['full_name'] as String,
              email: row['email'] as String,
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'students',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.students,
            StudentsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              profileId: row['profile_id'] as String,
              classId: Value(row['class_id'] as String?),
              // SQLite has no array type, so the Postgres text[] is mirrored
              // as a JSON string and decoded by the repository.
              specialNeeds: Value(jsonEncode(row['special_needs'] ?? <String>[])),
              specialNeedsNote: Value(row['special_needs_note'] as String?),
              preAdmissionCompletedAt:
                  Value(_timeOrNull(row['pre_admission_completed_at'])),
              version: Value(row['version'] as int),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'subjects',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.subjects,
            SubjectsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              name: row['name'] as String,
              chapterCount: Value(row['chapter_count'] as int),
              version: Value(row['version'] as int),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'chapters',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.chapters,
            ChaptersCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              subjectId: row['subject_id'] as String,
              ordinal: row['ordinal'] as int,
              title: row['title'] as String,
              microSkillsLockedAt:
                  Value(_timeOrNull(row['micro_skills_locked_at'])),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'classes',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.classes,
            ClassesCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              name: row['name'] as String,
              yearLevel: row['year_level'] as int,
              targetLearningStyle:
                  Value(row['target_learning_style'] as String?),
              version: Value(row['version'] as int),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'class_subjects',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.classSubjects,
            ClassSubjectsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              classId: row['class_id'] as String,
              subjectId: row['subject_id'] as String,
              teacherId: row['teacher_id'] as String,
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'class_chapter_sched',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.classChapterSched,
            ClassChapterSchedCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              classId: row['class_id'] as String,
              chapterId: row['chapter_id'] as String,
              taughtOn: Value(_timeOrNull(row['taught_on'])),
              version: Value(row['version'] as int),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'micro_skills',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.microSkills,
            MicroSkillsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              chapterId: row['chapter_id'] as String,
              slug: row['slug'] as String,
              label: row['label'] as String,
              description: Value(row['description'] as String?),
              ordinal: row['ordinal'] as int,
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'micro_skill_explanations',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.microSkillExplanations,
            MicroSkillExplanationsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              microSkillId: row['micro_skill_id'] as String,
              body: row['body'] as String,
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'questions',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.questions,
            QuestionsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              chapterId: row['chapter_id'] as String,
              microSkillId: row['micro_skill_id'] as String,
              difficulty: row['difficulty'] as int,
              stem: row['stem'] as String,
              options: jsonEncode(row['options']),
              correctIndex: row['correct_index'] as int,
              rationale: Value(row['rationale'] as String?),
              provenance: Value(row['provenance'] as String),
              forStudentId: Value(row['for_student_id'] as String?),
              materialId: Value(row['material_id'] as String?),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'attempts',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.attempts,
            AttemptsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              studentId: row['student_id'] as String,
              chapterIds: Value(jsonEncode(row['chapter_ids'] ?? <String>[])),
              mode: row['mode'] as String,
              attemptNumber: Value(row['attempt_number'] as int),
              parentAttemptId: Value(row['parent_attempt_id'] as String?),
              questionCount: row['question_count'] as int,
              score: Value(row['score'] as int),
              startedAt: Value(_timeOrNull(row['started_at'])),
              submittedAt: Value(_timeOrNull(row['submitted_at'])),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'attempt_items',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.attemptItems,
            AttemptItemsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              attemptId: row['attempt_id'] as String,
              questionId: Value(row['question_id'] as String?),
              microSkillId: row['micro_skill_id'] as String,
              selectedIndex: Value(row['selected_index'] as int?),
              isCorrect: row['is_correct'] as bool,
              ordinal: row['ordinal'] as int,
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'weaknesses',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.weaknesses,
            WeaknessesCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              studentId: row['student_id'] as String,
              microSkillId: row['micro_skill_id'] as String,
              weight: (row['weight'] as num).toDouble(),
              source: row['source'] as String,
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'generated_content',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.generatedContent,
            GeneratedContentCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              chapterId: row['chapter_id'] as String,
              studentId: Value(row['student_id'] as String?),
              kind: row['kind'] as String,
              payload: Value(jsonEncode(row['payload'] ?? <String, dynamic>{})),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'pre_admission_results',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.preAdmissionResults,
            PreAdmissionResultsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              studentId: row['student_id'] as String,
              vark: Value(jsonEncode(row['vark'] ?? <String, dynamic>{})),
              structured: Value((row['structured'] as num?)?.toInt() ?? 0),
              exploratory: Value((row['exploratory'] as num?)?.toInt() ?? 0),
              introvert: Value((row['introvert'] as num?)?.toInt() ?? 0),
              extrovert: Value((row['extrovert'] as num?)?.toInt() ?? 0),
              impulsivity: Value((row['impulsivity'] as num?)?.toInt() ?? 0),
              reflectivity: Value((row['reflectivity'] as num?)?.toInt() ?? 0),
              dominantStyle: row['dominant_style'] as String,
              answers: Value(jsonEncode(row['answers'] ?? <int>[])),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'reflection_campaigns',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.reflectionCampaigns,
            ReflectionCampaignsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              academicYear: row['academic_year'] as String,
              openedAt: _time(row['opened_at']),
              closedAt: Value(_timeOrNull(row['closed_at'])),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'year_end_reflections',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.yearEndReflections,
            YearEndReflectionsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              studentId: row['student_id'] as String,
              campaignId: Value(row['campaign_id'] as String?),
              academicYear: row['academic_year'] as String,
              responses:
                  Value(jsonEncode(row['responses'] ?? <String, dynamic>{})),
              studentPct: Value((row['student_pct'] as num?)?.toDouble()),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'fit_analyses',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.fitAnalyses,
            FitAnalysesCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              studentId: row['student_id'] as String,
              academicPct: Value((row['academic_pct'] as num?)?.toDouble()),
              studentPct: Value((row['student_pct'] as num?)?.toDouble()),
              teacherPct: Value((row['teacher_pct'] as num?)?.toDouble()),
              fitScore: Value((row['fit_score'] as num?)?.toDouble()),
              verdict: Value(row['verdict'] as String?),
              recommendation: Value(row['recommendation'] as String?),
              source: Value(row['source'] as String? ?? 'rule'),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'placement_suggestions',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.placementSuggestions,
            PlacementSuggestionsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              studentId: row['student_id'] as String,
              suggestedClassId: Value(row['suggested_class_id'] as String?),
              rationale: Value(row['rationale'] as String? ?? ''),
              status: Value(row['status'] as String? ?? 'pending'),
              version: Value((row['version'] as num?)?.toInt() ?? 1),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'teaching_insights',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.teachingInsights,
            TeachingInsightsCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              teacherId: row['teacher_id'] as String,
              classId: row['class_id'] as String,
              chapterId: row['chapter_id'] as String,
              signals: Value(jsonEncode(row['signals'] ?? <dynamic>[])),
              summary: Value(row['summary'] as String? ?? ''),
              actions: Value(jsonEncode(row['actions'] ?? <dynamic>[])),
              deck: Value(jsonEncode(row['deck'] ?? <String, dynamic>{})),
              source: Value(row['source'] as String? ?? 'rule'),
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
  SyncDescriptor(
    table: 'exam_papers',
    upsert: (SyncEduDatabase db, List<Map<String, dynamic>> rows) async {
      await db.batch((Batch batch) {
        for (final Map<String, dynamic> row in rows) {
          batch.insert(
            db.examPapers,
            ExamPapersCompanion.insert(
              id: row['id'] as String,
              schoolId: row['school_id'] as String,
              studentId: row['student_id'] as String,
              chapterId: row['chapter_id'] as String,
              storagePath: row['storage_path'] as String,
              analysisStatus: Value(row['analysis_status'] as String? ?? 'pending'),
              analysisNote: Value(row['analysis_note'] as String?),
              uploadedBy: row['uploaded_by'] as String,
              createdAt: _time(row['created_at']),
              updatedAt: _time(row['updated_at']),
              deletedAt: Value(_timeOrNull(row['deleted_at'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    },
  ),
];
