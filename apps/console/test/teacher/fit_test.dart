import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/functions/console_functions.dart';
import 'package:syncedu_console/teacher/fit/fit_repository.dart';
import 'package:syncedu_local/syncedu_local.dart';

final DateTime _now = DateTime.utc(2026, 1, 1);

void main() {
  late SyncEduDatabase db;
  late FitRepository repo;

  setUp(() async {
    db = SyncEduDatabase.forTesting();
    repo = FitRepository(db: db, functions: const ConsoleFunctions(null));
    await db.into(db.profiles).insert(ProfilesCompanion.insert(
          id: 'p1', schoolId: 's', role: 'student', fullName: 'Amира',
          email: 'a@t', createdAt: _now, updatedAt: _now,
        ));
    await db.into(db.students).insert(StudentsCompanion.insert(
          id: 'stu1', schoolId: 's', profileId: 'p1',
          createdAt: _now, updatedAt: _now,
        ));
  });
  tearDown(() => db.close());

  test('offline, the analysis uses the rule-based recommendation and persists',
      () async {
    final FitResult result = await repo.analyse(
      schoolId: 's',
      studentId: 'stu1',
      observationText: 'Engaged, asks questions, works well with the group.',
      academicPct: 80,
      studentPct: 60,
    );

    // No model call: teacher component is absent, so the score reweights
    // around it rather than scoring it zero.
    expect(result.source, 'rule');
    expect(result.recommendation, isNotEmpty);
    expect(result.score.componentsUsed, <String>['academic', 'student']);
    expect(result.score.score, closeTo(80 * 0.4 / 0.7 + 60 * 0.3 / 0.7, 0.1));

    final row = await db.select(db.fitAnalyses).getSingle();
    expect(row.source, 'rule');
    expect(row.studentId, 'stu1');
    expect(row.fitScore, isNotNull);

    final outbox = await db.select(db.outbox).get();
    expect(outbox.any((o) => o.table == 'fit_analyses'), isTrue);
  });

  test('inputsFor reads academic accuracy and the reflection self-report',
      () async {
    final String attemptId = 'a1';
    await db.into(db.attempts).insert(AttemptsCompanion.insert(
          id: attemptId, schoolId: 's', studentId: 'stu1', mode: 'revise',
          questionCount: 10, score: const Value(7),
          submittedAt: Value(_now), createdAt: _now, updatedAt: _now,
        ));
    await db.into(db.yearEndReflections).insert(YearEndReflectionsCompanion.insert(
          id: 'r1', schoolId: 's', studentId: 'stu1', academicYear: '2026',
          studentPct: const Value(64), createdAt: _now, updatedAt: _now,
        ));

    final FitInputs inputs = await repo.inputsFor('stu1');
    expect(inputs.academicPct, closeTo(70, 0.01));
    expect(inputs.studentPct, closeTo(64, 0.01));
  });
}
