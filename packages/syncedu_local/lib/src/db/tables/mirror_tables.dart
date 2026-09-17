import 'package:drift/drift.dart';

/// Columns every mirrored table carries. Kept as a mixin so a missing
/// `updatedAt` on a new table becomes a compile error rather than a table the
/// puller silently never advances.
mixin MirrorColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Schools extends Table with MirrorColumns {
  TextColumn get name => text()();
  TextColumn get educationLevel => text()();
  TextColumn get contentLanguage => text().withDefault(const Constant('en'))();
  IntColumn get maxOfflineDays => integer().withDefault(const Constant(30))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Profiles extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get role => text()();
  TextColumn get fullName => text()();
  TextColumn get email => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Students extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get profileId => text()();
  TextColumn get classId => text().nullable()();
  TextColumn get specialNeeds => text().withDefault(const Constant('[]'))();
  TextColumn get specialNeedsNote => text().nullable()();
  DateTimeColumn get preAdmissionCompletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Subjects extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get name => text()();
  IntColumn get chapterCount => integer().withDefault(const Constant(0))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Chapters extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get subjectId => text()();
  IntColumn get ordinal => integer()();
  TextColumn get title => text()();
  DateTimeColumn get microSkillsLockedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Classes extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get name => text()();
  IntColumn get yearLevel => integer()();
  TextColumn get targetLearningStyle => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class ClassSubjects extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get classId => text()();
  TextColumn get subjectId => text()();
  TextColumn get teacherId => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class ClassChapterSched extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get classId => text()();
  TextColumn get chapterId => text()();
  DateTimeColumn get taughtOn => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class MicroSkills extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get chapterId => text()();
  TextColumn get slug => text()();
  TextColumn get label => text()();
  TextColumn get description => text().nullable()();
  IntColumn get ordinal => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class MicroSkillExplanations extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get microSkillId => text()();
  TextColumn get body => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Questions extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get chapterId => text()();
  TextColumn get microSkillId => text()();
  IntColumn get difficulty => integer()();
  TextColumn get stem => text()();
  // SQLite has no array/jsonb type, so the Postgres jsonb column is mirrored
  // as a JSON string and decoded by the repository.
  TextColumn get options => text()();
  IntColumn get correctIndex => integer()();
  TextColumn get rationale => text().nullable()();
  TextColumn get provenance => text().withDefault(const Constant('pool'))();
  TextColumn get forStudentId => text().nullable()();
  TextColumn get materialId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class Attempts extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  // SQLite has no array type, so the Postgres uuid[] is mirrored as a JSON
  // string and decoded by the repository.
  TextColumn get chapterIds => text().withDefault(const Constant('[]'))();
  TextColumn get mode => text()();
  IntColumn get attemptNumber => integer().withDefault(const Constant(1))();
  TextColumn get parentAttemptId => text().nullable()();
  IntColumn get questionCount => integer()();
  IntColumn get score => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get submittedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class AttemptItems extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get attemptId => text()();
  TextColumn get questionId => text().nullable()();
  TextColumn get microSkillId => text()();
  IntColumn get selectedIndex => integer().nullable()();
  BoolColumn get isCorrect => boolean()();
  IntColumn get ordinal => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.weaknesses`, including its
/// `unique (student_id, micro_skill_id, source)` constraint. Without the
/// constraint a locally-computed row and the server's own row for the same
/// skill (written with a different `gen_random_uuid()` id) would both survive
/// a pull, and `weaknessWeightsFor` would sum the two.
/// Mirrors `public.materials`. `storagePath` stays null until the sync
/// engine uploads the bytes and the server row lands back through a pull --
/// the teacher never waits on that round trip, so the local row is created
/// and shown at `pending` before a path exists.
class Materials extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get chapterId => text()();
  TextColumn get storagePath => text().nullable()();
  TextColumn get mime => text()();
  TextColumn get ingestionStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.teacher_observations` (spec §5): append-only, tier-1 --
/// two teachers writing about the same student produce two independent rows,
/// and neither ever overwrites the other. There is no update path for
/// [body]; a correction is a new row, not an edit.
class TeacherObservations extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get teacherId => text()();
  TextColumn get body => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(
  name: 'weaknesses_student_skill_source',
  columns: <Symbol>{#studentId, #microSkillId, #source},
  unique: true,
)
class Weaknesses extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get microSkillId => text()();
  RealColumn get weight => real()();
  TextColumn get source => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.generated_content` (spec §5). `payload` is a JSON string
/// decoded by the repository; its shape depends on `kind`. A row with a null
/// `studentId` is a shared chapter deck any student may open.
class GeneratedContent extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get chapterId => text()();
  TextColumn get studentId => text().nullable()();
  TextColumn get kind => text()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.pre_admission_results`. Append-only; the student sits the
/// instrument once. `vark` and `answers` are JSON strings.
class PreAdmissionResults extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get vark => text().withDefault(const Constant('{}'))();
  IntColumn get structured => integer().withDefault(const Constant(0))();
  IntColumn get exploratory => integer().withDefault(const Constant(0))();
  IntColumn get introvert => integer().withDefault(const Constant(0))();
  IntColumn get extrovert => integer().withDefault(const Constant(0))();
  IntColumn get impulsivity => integer().withDefault(const Constant(0))();
  IntColumn get reflectivity => integer().withDefault(const Constant(0))();
  TextColumn get dominantStyle => text()();
  TextColumn get answers => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.reflection_campaigns`: school-wide, admin-opened.
class ReflectionCampaigns extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get academicYear => text()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.year_end_reflections`. `responses` is a JSON string;
/// `studentPct` is null until the student answers.
class YearEndReflections extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get campaignId => text().nullable()();
  TextColumn get academicYear => text()();
  TextColumn get responses => text().withDefault(const Constant('{}'))();
  RealColumn get studentPct => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.fit_analyses`: staff-only, never shown to the student.
class FitAnalyses extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  RealColumn get academicPct => real().nullable()();
  RealColumn get studentPct => real().nullable()();
  RealColumn get teacherPct => real().nullable()();
  RealColumn get fitScore => real().nullable()();
  TextColumn get verdict => text().nullable()();
  TextColumn get recommendation => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('rule'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.placement_suggestions`. `status` is contended (tier 3).
class PlacementSuggestions extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get suggestedClassId => text().nullable()();
  TextColumn get rationale => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.exam_papers`.
class ExamPapers extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get chapterId => text()();
  TextColumn get storagePath => text()();
  TextColumn get analysisStatus =>
      text().withDefault(const Constant('pending'))();
  TextColumn get analysisNote => text().nullable()();
  TextColumn get uploadedBy => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Mirrors `public.teaching_insights`: one teacher's diagnostic over one
/// (class, chapter), with the re-teach deck generated from it.
///
/// Mirrored rather than kept server-side so a teacher can re-read a review and
/// re-export its deck with no connection -- only *generating* one needs the
/// network. `signals`, `actions` and `deck` are JSON strings for the same
/// reason `payload` is on [GeneratedContent]: SQLite has no JSON column type
/// and nothing here is ever queried by its contents.
///
/// The row class is named explicitly because drift's default singular
/// (`TeachingInsight`) collides with the console's own hydrated model of the
/// same name -- the same collision `MaterialRecord` exists to avoid.
@DataClassName('TeachingInsightRecord')
class TeachingInsights extends Table with MirrorColumns {
  TextColumn get schoolId => text()();
  TextColumn get teacherId => text()();
  TextColumn get classId => text()();
  TextColumn get chapterId => text()();
  TextColumn get signals => text().withDefault(const Constant('[]'))();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get actions => text().withDefault(const Constant('[]'))();
  TextColumn get deck => text().withDefault(const Constant('{}'))();
  TextColumn get source => text().withDefault(const Constant('rule'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
