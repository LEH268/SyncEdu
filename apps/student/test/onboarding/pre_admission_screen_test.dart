import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:syncedu_student/onboarding/onboarding_repository.dart';
import 'package:syncedu_student/onboarding/pre_admission_screen.dart';

void main() {
  late SyncEduDatabase db;
  late OnboardingRepository repo;

  setUp(() async {
    db = SyncEduDatabase.forTesting();
    repo = OnboardingRepository(db);
    await db.into(db.students).insert(
          StudentsCompanion.insert(
            id: 'stu-1',
            schoolId: 'school-1',
            profileId: 'prof-1',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
  });
  tearDown(() => db.close());

  testWidgets('answering all twenty questions writes a scored result and '
      'stamps the student row', (tester) async {
    PreAdmissionProfile? completed;
    await tester.pumpWidget(MaterialApp(
      home: PreAdmissionScreen(
        repository: repo,
        studentId: 'stu-1',
        schoolId: 'school-1',
        onComplete: (PreAdmissionProfile p) => completed = p,
      ),
    ));

    for (int q = 0; q < kPreAdmissionInstrument.length - 1; q++) {
      expect(find.byKey(const Key('pre-admission-progress')), findsOneWidget);
      await tester.tap(find.byKey(const Key('pre-admission-option-0')));
      await tester.pump();
    }
    // The final answer triggers an async submit; pump past it without waiting
    // on the (indefinite) progress spinner to settle.
    await tester.tap(find.byKey(const Key('pre-admission-option-0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(completed, isNotNull);
    expect(kVarkOrder, contains(completed!.dominantStyle));

    final row = await db.select(db.preAdmissionResults).getSingle();
    expect(row.studentId, 'stu-1');
    expect(row.dominantStyle, completed!.dominantStyle);

    final student = await db.select(db.students).getSingle();
    expect(student.preAdmissionCompletedAt, isNotNull);

    // The write is queued for sync, not sent here.
    final outbox = await db.select(db.outbox).get();
    expect(outbox.any((o) => o.table == 'pre_admission_results'), isTrue);
  });

  testWidgets('the Back button steps to the previous question', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: PreAdmissionScreen(
        repository: repo,
        studentId: 'stu-1',
        schoolId: 'school-1',
        onComplete: (_) {},
      ),
    ));

    await tester.tap(find.byKey(const Key('pre-admission-option-1')));
    await tester.pumpAndSettle();
    expect(find.text('Question 2 of 20'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pre-admission-back')));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 20'), findsOneWidget);
  });

  test('an unsynced student is reported as not yet resolvable', () async {
    expect(await repo.studentIdForProfile('nobody'), isNull);
    expect(await repo.studentIdForProfile('prof-1'), 'stu-1');
    // Also cover the Value import staying used.
    expect(const Value<int>(1).value, 1);
  });
}
