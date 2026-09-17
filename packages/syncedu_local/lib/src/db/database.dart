import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/mirror_tables.dart';
import 'tables/sync_tables.dart';
import 'testing_connection_stub.dart'
    if (dart.library.ffi) 'testing_connection_native.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: <Type>[
    Schools,
    Profiles,
    Students,
    Subjects,
    Chapters,
    Classes,
    ClassSubjects,
    ClassChapterSched,
    MicroSkills,
    MicroSkillExplanations,
    Questions,
    Attempts,
    AttemptItems,
    Weaknesses,
    Materials,
    TeacherObservations,
    GeneratedContent,
    PreAdmissionResults,
    ReflectionCampaigns,
    YearEndReflections,
    FitAnalyses,
    PlacementSuggestions,
    ExamPapers,
    TeachingInsights,
    SyncState,
    Outbox,
    PendingIntents,
    LocalConflicts,
  ],
)
class SyncEduDatabase extends _$SyncEduDatabase {
  SyncEduDatabase(super.executor);

  /// In-memory instance for tests. Each call is an independent database.
  SyncEduDatabase.forTesting() : super(testingExecutor());

  /// The application instance. `driftDatabase` picks the right implementation
  /// per platform: native SQLite on Android, and on web a WASM build that
  /// falls back OPFS -> IndexedDB depending on what the browser allows.
  factory SyncEduDatabase.open() => SyncEduDatabase(
        driftDatabase(
          name: 'syncedu',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 3;

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          // v2 added the Phase 9 mirror tables. They are pull-only mirrors, so
          // creating them empty and letting the next watermark pull fill them
          // is sufficient — there is nothing local to preserve.
          if (from < 2) {
            for (final TableInfo<Table, dynamic> table in <TableInfo<Table, dynamic>>[
              generatedContent,
              preAdmissionResults,
              reflectionCampaigns,
              yearEndReflections,
              fitAnalyses,
              placementSuggestions,
              examPapers,
            ]) {
              await m.createTable(table);
            }
          }
          // v3 added the teaching review mirror. Same reasoning: a pull-only
          // mirror with nothing local to preserve.
          if (from < 3) {
            await m.createTable(teachingInsights);
          }
        },
      );

  Future<DateTime?> watermarkFor(String table) async {
    final row = await (select(syncState)
          ..where(($SyncStateTable t) => t.table.equals(table)))
        .getSingleOrNull();
    return row?.watermark;
  }

  Future<void> setWatermark(String table, DateTime value) async {
    await into(syncState).insertOnConflictUpdate(
      SyncStateData(table: table, watermark: value, lastPullAt: DateTime.now().toUtc()),
    );
  }

  /// Rows the user should see. Tombstones stay in the mirror so a later pull
  /// can distinguish "deleted" from "never seen", but nothing renders them.
  SimpleSelectStatement<$StudentsTable, Student> liveStudents() =>
      select(students)..where(($StudentsTable t) => t.deletedAt.isNull());
}
