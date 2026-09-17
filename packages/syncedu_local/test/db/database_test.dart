import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_local/syncedu_local.dart';

void main() {
  late SyncEduDatabase db;

  setUp(() => db = SyncEduDatabase.forTesting());
  tearDown(() => db.close());

  test('a school round-trips through the mirror', () async {
    await db.into(db.schools).insert(
          SchoolsCompanion.insert(
            id: 'school-1',
            name: 'SMK Demo',
            educationLevel: 'secondary',
            contentLanguage: drift.Value('en'),
            maxOfflineDays: drift.Value(30),
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        );

    final rows = await db.select(db.schools).get();
    expect(rows, hasLength(1));
    expect(rows.single.name, 'SMK Demo');
    expect(rows.single.deletedAt, isNull);
  });

  test('watching a table emits on every write', () async {
    final emissions = <int>[];
    final subscription =
        db.select(db.students).watch().listen((rows) => emissions.add(rows.length));

    // Let the initial snapshot emit before writing
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await db.into(db.students).insert(
          StudentsCompanion.insert(
            id: 'student-1',
            schoolId: 'school-1',
            profileId: 'profile-1',
            version: drift.Value(1),
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // The UI binds to these streams, so an initial emission plus one per write
    // is the contract the whole local-first design rests on.
    expect(emissions, containsAllInOrder(<int>[0, 1]));
    await subscription.cancel();
  });

  test('sync state starts empty and stores a watermark per table', () async {
    expect(await db.watermarkFor('students'), isNull);

    await db.setWatermark('students', DateTime.utc(2026, 9, 2, 10));
    expect(await db.watermarkFor('students'), DateTime.utc(2026, 9, 2, 10));

    await db.setWatermark('students', DateTime.utc(2026, 9, 2, 11));
    expect(
      await db.watermarkFor('students'),
      DateTime.utc(2026, 9, 2, 11),
      reason: 'a second call must replace, not accumulate',
    );
  });

  test('a tombstoned row stays in the mirror but is excluded by liveStudents',
      () async {
    await db.into(db.students).insert(
          StudentsCompanion.insert(
            id: 'student-2',
            schoolId: 'school-1',
            profileId: 'profile-2',
            version: drift.Value(1),
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        );
    await (db.update(db.students)..where((t) => t.id.equals('student-2')))
        .write(StudentsCompanion(deletedAt: drift.Value(DateTime.utc(2026, 9, 3))));

    expect(await db.select(db.students).get(), hasLength(1));
    expect(await db.liveStudents().get(), isEmpty);
  });
}
