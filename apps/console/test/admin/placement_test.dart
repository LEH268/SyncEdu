import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/admin/placement/placement_repository.dart';
import 'package:syncedu_console/functions/console_functions.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

final DateTime _now = DateTime.utc(2026, 1, 1);

Future<void> _class(SyncEduDatabase db, String id, String style) async {
  await db.into(db.classes).insert(ClassesCompanion.insert(
        id: id,
        schoolId: 'school-1',
        name: 'Class $id',
        yearLevel: 4,
        targetLearningStyle: Value(style),
        createdAt: _now,
        updatedAt: _now,
      ));
}

Future<void> _student(SyncEduDatabase db, String id,
    {String? classId, String? dominant}) async {
  await db.into(db.profiles).insert(ProfilesCompanion.insert(
        id: 'p-$id',
        schoolId: 'school-1',
        role: 'student',
        fullName: 'Student $id',
        email: '$id@test',
        createdAt: _now,
        updatedAt: _now,
      ));
  await db.into(db.students).insert(StudentsCompanion.insert(
        id: id,
        schoolId: 'school-1',
        profileId: 'p-$id',
        classId: Value(classId),
        createdAt: _now,
        updatedAt: _now,
      ));
  if (dominant != null) {
    await db.into(db.preAdmissionResults).insert(
          PreAdmissionResultsCompanion.insert(
            id: 'pa-$id',
            schoolId: 'school-1',
            studentId: id,
            dominantStyle: dominant,
            createdAt: _now,
            updatedAt: _now,
          ),
        );
  }
}

void main() {
  late SyncEduDatabase db;
  late PlacementRepository repo;

  setUp(() {
    db = SyncEduDatabase.forTesting();
    repo = PlacementRepository(db: db, functions: const ConsoleFunctions(null));
  });
  tearDown(() => db.close());

  test('compute matches the class whose target style matches, not the name',
      () async {
    await _class(db, 'alpha', 'V'); // a "Year 1 Alpha"-style trap
    await _class(db, 'beta', 'A');
    await _student(db, 's1', dominant: 'A');

    final List<PlacementDecision> result = await repo.compute('school-1');
    expect(result.single.classId, 'beta');
  });

  test('a student with no Pre-admission profile is left unassigned', () async {
    await _class(db, 'alpha', 'A');
    await _student(db, 's1');
    final List<PlacementDecision> result = await repo.compute('school-1');
    expect(result.single.classId, isNull);
  });

  test('offline, rationales come from the rule, not the model', () async {
    await _class(db, 'alpha', 'A');
    await _student(db, 's1', dominant: 'A');
    final List<PlacementDecision> decisions = await repo.compute('school-1');
    final ({Map<String, String> rationales, String source}) r =
        await repo.rationalesFor(schoolId: 'school-1', suggestions: decisions);
    expect(r.source, 'rule');
    expect(r.rationales['s1'], isNotEmpty);
  });

  test('approving moves the student and records the suggestion', () async {
    await _class(db, 'alpha', 'A');
    await _student(db, 's1', dominant: 'A');

    await repo.approve(
      schoolId: 'school-1',
      studentId: 's1',
      classId: 'alpha',
      rationale: 'matches target style',
    );

    final Student moved =
        await (db.select(db.students)..where((t) => t.id.equals('s1'))).getSingle();
    expect(moved.classId, 'alpha');

    final row = await db.select(db.placementSuggestions).getSingle();
    expect(row.suggestedClassId, 'alpha');
    expect(row.status, 'approved');

    // The class change is a queued tier-3 delta, not a direct server write.
    final outbox = await db.select(db.outbox).get();
    expect(outbox.any((o) => o.field == 'class_id'), isTrue);
    expect(outbox.any((o) => o.table == 'placement_suggestions'), isTrue);
  });
}
