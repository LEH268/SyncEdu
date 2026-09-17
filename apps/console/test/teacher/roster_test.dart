import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/teacher/roster/class_roster.dart';
import 'package:syncedu_console/teacher/roster/observation_editor.dart';
import 'package:syncedu_console/teacher/roster/student_detail.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

Future<void> _seedSchool(SyncEduDatabase db) async {
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
}

Future<void> _seedTeacher(
  SyncEduDatabase db, {
  required String id,
  required String fullName,
}) async {
  final DateTime now = DateTime.utc(2026, 1, 1);
  await db.into(db.profiles).insert(
        ProfilesCompanion.insert(
          id: id,
          schoolId: 'school-1',
          role: 'teacher',
          fullName: fullName,
          email: '$id@example.com',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

/// See curriculum_test.dart for why this teardown dance is needed: Drift
/// schedules a short-lived internal timer on `StreamBuilder` unsubscribe that
/// `db.close()` awaits, and flutter_test only lets it fire after the widget
/// tree is unmounted and the fake clock advances.
Future<void> _settle(WidgetTester tester, SyncEduDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await db.close();
}

ProgressPoint _point({
  required String attemptId,
  required DateTime at,
  required double proportion,
  int attemptNumber = 1,
  String? parentAttemptId,
}) {
  return ProgressPoint(
    attemptId: attemptId,
    at: at,
    proportion: proportion,
    attemptNumber: attemptNumber,
    parentAttemptId: parentAttemptId,
  );
}

void main() {
  group('ClassRoster', () {
    testWidgets('lists students with their special-needs labels',
        (tester) async {
      final entries = <RosterEntry>[
        const RosterEntry(
          studentId: 's1',
          studentName: 'Amina Yusuf',
          specialNeeds: <String>['dyslexia', 'extra time'],
        ),
        const RosterEntry(
          studentId: 's2',
          studentName: 'Ben Carter',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ClassRoster(entries: entries))),
      );

      expect(find.text('Amina Yusuf'), findsOneWidget);
      expect(find.text('dyslexia, extra time'), findsOneWidget);
      expect(find.text('Ben Carter'), findsOneWidget);
    });

    testWidgets('an at-risk student is flagged on the roster',
        (tester) async {
      final entries = <RosterEntry>[
        const RosterEntry(
          studentId: 's1',
          studentName: 'At Risk Student',
          riskLevel: RiskLevel.high,
          riskReasons: <String>['overall mastery is 30%, below the 60% bar'],
        ),
        const RosterEntry(
          studentId: 's2',
          studentName: 'Fine Student',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ClassRoster(entries: entries))),
      );

      expect(find.byKey(const Key('risk-s1')), findsOneWidget);
      expect(find.byKey(const Key('risk-s2')), findsNothing);
      expect(find.textContaining('At risk'), findsOneWidget);
    });
  });

  group('StudentDetail', () {
    testWidgets('plots the progress curve oldest first', (tester) async {
      final attempts = <AttemptRow>[
        AttemptRow(
          id: 'a2',
          studentId: 's1',
          attemptNumber: 1,
          score: 8,
          questionCount: 10,
          submittedAt: DateTime.utc(2026, 2, 1),
          mode: 'revise',
        ),
        AttemptRow(
          id: 'a1',
          studentId: 's1',
          attemptNumber: 1,
          score: 4,
          questionCount: 10,
          submittedAt: DateTime.utc(2026, 1, 1),
          mode: 'revise',
        ),
      ];
      final List<ProgressPoint> points =
          progressCurve(attempts: attempts, studentId: 's1');

      // progressCurve sorts oldest first regardless of input order.
      expect(points.first.attemptId, 'a1');
      expect(points.last.attemptId, 'a2');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentDetail(
              progress: points,
              retryChains: const <RetryChain>[],
              struggleTags: const <ConceptRank>[],
            ),
          ),
        ),
      );

      final Finder curve = find.byKey(const Key('progress-curve'));
      final Row row = tester.widget<Row>(curve);
      final List<Key> orderedKeys =
          row.children.map((Widget w) => w.key!).toList();
      expect(orderedKeys, <Key>[
        const Key('progress-point-a1'),
        const Key('progress-point-a2'),
      ]);
    });

    testWidgets('a retry chain renders as a connected segment',
        (tester) async {
      // Requirement 45: a teacher must be able to see whether targeted
      // practice worked, which scattered points cannot show.
      final chain = RetryChain(
        points: <ProgressPoint>[
          _point(
              attemptId: 'r1', at: DateTime.utc(2026, 1, 1), proportion: 0.4),
          _point(
              attemptId: 'r2', at: DateTime.utc(2026, 1, 2), proportion: 0.8),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentDetail(
              progress: const <ProgressPoint>[],
              retryChains: <RetryChain>[chain],
              struggleTags: const <ConceptRank>[],
            ),
          ),
        ),
      );

      // Both points are present, and -- unlike scattered points -- a
      // connecting segment joins them into one visible chain.
      expect(find.byKey(const Key('retry-point-r1')), findsOneWidget);
      expect(find.byKey(const Key('retry-point-r2')), findsOneWidget);
      expect(find.byKey(const Key('retry-segment-r1-r2')), findsOneWidget);
      expect(find.text('Improved'), findsOneWidget);
    });

    testWidgets('the top three struggle tags are shown with their source',
        (tester) async {
      const tags = <ConceptRank>[
        ConceptRank(
          microSkillId: 'sk1',
          microSkillLabel: 'Long division',
          errorRate: 0.9,
          total: 10,
          source: 'quiz',
        ),
        ConceptRank(
          microSkillId: 'sk2',
          microSkillLabel: 'Fractions',
          errorRate: 0.7,
          total: 8,
          source: 'quiz',
        ),
        ConceptRank(
          microSkillId: 'sk3',
          microSkillLabel: 'Geometry',
          errorRate: 0.6,
          total: 0,
          source: 'exam',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentDetail(
              progress: const <ProgressPoint>[],
              retryChains: const <RetryChain>[],
              struggleTags: tags,
            ),
          ),
        ),
      );

      expect(find.text('Long division'), findsOneWidget);
      expect(find.text('Fractions'), findsOneWidget);
      expect(find.text('Geometry'), findsOneWidget);
    });

    testWidgets('an exam-sourced tag is labelled as such', (tester) async {
      const tags = <ConceptRank>[
        ConceptRank(
          microSkillId: 'sk1',
          microSkillLabel: 'Geometry',
          errorRate: 0.6,
          total: 0,
          source: 'exam',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentDetail(
              progress: const <ProgressPoint>[],
              retryChains: const <RetryChain>[],
              struggleTags: tags,
            ),
          ),
        ),
      );

      expect(find.textContaining('exam'), findsOneWidget);
    });

    testWidgets('a student with no attempts shows an empty state, not a crash',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StudentDetail(
              progress: <ProgressPoint>[],
              retryChains: <RetryChain>[],
              struggleTags: <ConceptRank>[],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('No attempts recorded yet'), findsOneWidget);
    });
  });

  group('ObservationEditor', () {
    late SyncEduDatabase db;
    late OutboxWriter outbox;
    late ObservationRepository repo;

    setUp(() async {
      db = SyncEduDatabase.forTesting();
      outbox = OutboxWriter(db);
      repo = ObservationRepository(db, outbox);
      await _seedSchool(db);
      await _seedTeacher(db, id: 'teacher-1', fullName: 'Ms. Rossi');
      await _seedTeacher(db, id: 'teacher-2', fullName: 'Mr. Adeyemi');
    });

    testWidgets('two observations on one student both survive',
        (tester) async {
      // Tier 1 append-only: two teachers writing about the same student
      // produce two rows and neither is lost.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ObservationEditor(
              repository: repo,
              schoolId: 'school-1',
              studentId: 'student-1',
              teacherId: 'teacher-1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('observation-body')),
        'Struggling with fractions this week.',
      );
      await tester.tap(find.byKey(const Key('observation-submit')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('observation-body')),
        'Much better after extra practice.',
      );
      await tester.tap(find.byKey(const Key('observation-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Struggling with fractions this week.'),
          findsOneWidget);
      expect(find.text('Much better after extra practice.'), findsOneWidget);

      final List<TeacherObservation> rows =
          await db.select(db.teacherObservations).get();
      expect(rows.length, 2);

      await _settle(tester, db);
    });

    testWidgets('an observation written offline appears immediately',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ObservationEditor(
              repository: repo,
              schoolId: 'school-1',
              studentId: 'student-1',
              teacherId: 'teacher-1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No observations recorded yet.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('observation-body')),
        'Wrote this while offline.',
      );
      await tester.tap(find.byKey(const Key('observation-submit')));
      await tester.pumpAndSettle();

      // No network call was made -- the write landed in the local mirror
      // and the outbox only -- yet the UI already reflects it.
      expect(find.text('Wrote this while offline.'), findsOneWidget);
      final List<OutboxData> queued = await db.select(db.outbox).get();
      expect(
          queued.where((OutboxData o) => o.table == 'teacher_observations'),
          isNotEmpty);

      await _settle(tester, db);
    });

    testWidgets('observations are shown newest first with their author',
        (tester) async {
      // Insert directly with explicit, distinct timestamps so ordering is
      // unambiguous and the test does not depend on wall-clock timing.
      await db.into(db.teacherObservations).insert(
            TeacherObservationsCompanion.insert(
              id: 'obs-1',
              schoolId: 'school-1',
              studentId: 'student-1',
              teacherId: 'teacher-1',
              body: 'First note.',
              createdAt: DateTime.utc(2026, 1, 1, 10),
              updatedAt: DateTime.utc(2026, 1, 1, 10),
            ),
          );
      await db.into(db.teacherObservations).insert(
            TeacherObservationsCompanion.insert(
              id: 'obs-2',
              schoolId: 'school-1',
              studentId: 'student-1',
              teacherId: 'teacher-2',
              body: 'Second note.',
              createdAt: DateTime.utc(2026, 1, 1, 11),
              updatedAt: DateTime.utc(2026, 1, 1, 11),
            ),
          );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ObservationEditor(
              repository: repo,
              schoolId: 'school-1',
              studentId: 'student-1',
              teacherId: 'teacher-1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder list = find.byKey(const Key('observation-list'));
      final ListView listView = tester.widget<ListView>(list);
      final int itemCount =
          (listView.childrenDelegate as SliverChildBuilderDelegate)
                  .estimatedChildCount ??
              0;
      expect(itemCount, 2);

      // Newest ("Second note.") must render before the oldest.
      final Finder firstTile = find
          .descendant(of: list, matching: find.byType(ListTile))
          .first;
      final ListTile tile = tester.widget<ListTile>(firstTile);
      final Text title = tile.title! as Text;
      expect(title.data, 'Second note.');
      final Text subtitle = tile.subtitle! as Text;
      expect(subtitle.data, contains('Mr. Adeyemi'));

      await _settle(tester, db);
    });
  });
}
