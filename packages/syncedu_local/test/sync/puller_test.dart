import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_local/syncedu_local.dart';

Map<String, dynamic> studentRow({
  required String id,
  required String updatedAt,
  String? deletedAt,
}) =>
    <String, dynamic>{
      'id': id,
      'school_id': 'school-1',
      'profile_id': 'profile-$id',
      'class_id': null,
      'special_needs': <String>[],
      'special_needs_note': null,
      'pre_admission_completed_at': null,
      'version': 1,
      'created_at': '2026-09-01T00:00:00Z',
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };

void main() {
  late SyncEduDatabase db;
  late FakeRemoteGateway remote;
  late Puller puller;

  setUp(() {
    db = SyncEduDatabase.forTesting();
    remote = FakeRemoteGateway();
    puller = Puller(db, remote, defaultDescriptors);
  });
  tearDown(() => db.close());

  test('a first pull requests everything and stores the rows', () async {
    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(id: 's1', updatedAt: '2026-09-02T10:00:00Z'),
      studentRow(id: 's2', updatedAt: '2026-09-02T11:00:00Z'),
    ];

    final report = await puller.pullAll();

    expect(report.failures, isEmpty);
    expect(report.rowsByTable['students'], 2);
    expect(await db.select(db.students).get(), hasLength(2));
    expect(remote.watermarksRequested['students']!.first, isNull);
  });

  test('the watermark advances to the newest row seen', () async {
    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(id: 's1', updatedAt: '2026-09-02T10:00:00Z'),
      studentRow(id: 's2', updatedAt: '2026-09-02T11:30:00Z'),
    ];

    await puller.pullAll();

    expect(
      await db.watermarkFor('students'),
      DateTime.utc(2026, 9, 2, 11, 30),
    );
  });

  test('a second pull asks only for what changed since', () async {
    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(id: 's1', updatedAt: '2026-09-02T10:00:00Z'),
    ];
    await puller.pullAll();

    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(id: 's2', updatedAt: '2026-09-02T12:00:00Z'),
    ];
    await puller.pullAll();

    expect(
      remote.watermarksRequested['students']!.last,
      DateTime.utc(2026, 9, 2, 10),
    );
    expect(await db.select(db.students).get(), hasLength(2));
  });

  test('a re-pulled row updates in place rather than duplicating', () async {
    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(id: 's1', updatedAt: '2026-09-02T10:00:00Z'),
    ];
    await puller.pullAll();

    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(id: 's1', updatedAt: '2026-09-02T13:00:00Z'),
    ];
    await puller.pullAll();

    final rows = await db.select(db.students).get();
    expect(rows, hasLength(1));
    expect(rows.single.updatedAt, DateTime.utc(2026, 9, 2, 13));
  });

  test('a tombstone arrives as a row and hides the record', () async {
    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(id: 's1', updatedAt: '2026-09-02T10:00:00Z'),
    ];
    await puller.pullAll();
    expect(await db.liveStudents().get(), hasLength(1));

    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(
        id: 's1',
        updatedAt: '2026-09-02T14:00:00Z',
        deletedAt: '2026-09-02T14:00:00Z',
      ),
    ];
    await puller.pullAll();

    // The row is still mirrored -- that is what a watermark pull needs in
    // order to convey a delete at all -- but it no longer renders.
    expect(await db.select(db.students).get(), hasLength(1));
    expect(await db.liveStudents().get(), isEmpty);
  });

  test('a teaching review mirrors with its jsonb columns intact', () async {
    // Postgres hands jsonb back as decoded Dart structures; SQLite has no JSON
    // type, so the descriptor must re-encode them. Getting this wrong shows up
    // as a deck that renders as the string "Instance of ..." rather than as a
    // failure, so it is worth pinning.
    remote.rows['teaching_insights'] = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'ti1',
        'school_id': 'school-1',
        'teacher_id': 'teacher-1',
        'class_id': 'class-1',
        'chapter_id': 'chapter-1',
        'signals': <Map<String, dynamic>>[
          <String, dynamic>{'microSkillId': 's1', 'proportion': 0.6},
        ],
        'summary': 'Factorising did not land.',
        'actions': <Map<String, dynamic>>[
          <String, dynamic>{'microSkillId': 's1', 'title': 'Use a sign table'},
        ],
        'deck': <String, dynamic>{
          'title': 'Re-teach: Quadratics',
          'slides': <Map<String, dynamic>>[
            <String, dynamic>{'title': 'Why the signs flip'},
          ],
        },
        'source': 'ai',
        'created_at': '2026-09-02T10:00:00Z',
        'updated_at': '2026-09-02T10:00:00Z',
        'deleted_at': null,
      },
    ];

    await puller.pullAll();

    final rows = await db.select(db.teachingInsights).get();
    expect(rows, hasLength(1));
    expect(rows.single.summary, 'Factorising did not land.');
    expect(rows.single.source, 'ai');
    expect(
      jsonDecode(rows.single.deck),
      <String, dynamic>{
        'title': 'Re-teach: Quadratics',
        'slides': <dynamic>[
          <String, dynamic>{'title': 'Why the signs flip'},
        ],
      },
    );
    expect((jsonDecode(rows.single.signals) as List<dynamic>).single,
        <String, dynamic>{'microSkillId': 's1', 'proportion': 0.6});
  });

  test('one table failing does not stop the others or move its watermark',
      () async {
    remote.failures.add('profiles');
    remote.rows['students'] = <Map<String, dynamic>>[
      studentRow(id: 's1', updatedAt: '2026-09-02T10:00:00Z'),
    ];

    final report = await puller.pullAll();

    expect(report.failures, contains('profiles'));
    expect(report.rowsByTable['students'], 1);
    expect(await db.watermarkFor('profiles'), isNull);
  });
}
