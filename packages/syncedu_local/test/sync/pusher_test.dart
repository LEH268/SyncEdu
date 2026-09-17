import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_local/syncedu_local.dart';

void main() {
  late SyncEduDatabase db;
  late FakeRemoteGateway remote;
  late OutboxWriter writer;
  late Pusher pusher;

  setUp(() {
    db = SyncEduDatabase.forTesting();
    remote = FakeRemoteGateway();
    writer = OutboxWriter(db);
    pusher = Pusher(db, remote);
  });
  tearDown(() => db.close());

  test('a queued insert is sent once and then cleared', () async {
    await writer.queueInsert(
      table: 'teacher_observations',
      row: <String, dynamic>{'id': 'obs-1', 'body': 'Improving steadily'},
    );

    final report = await pusher.drain();

    expect(report.applied, 1);
    expect(remote.upserted, hasLength(1));
    expect(remote.upserted.single['id'], 'obs-1');
    expect(await db.select(db.outbox).get(), isEmpty);
  });

  test('draining twice does not resend an already-sent insert', () async {
    await writer.queueInsert(
      table: 'teacher_observations',
      row: <String, dynamic>{'id': 'obs-1', 'body': 'Improving'},
    );
    await pusher.drain();
    await pusher.drain();

    expect(remote.upserted, hasLength(1));
  });

  test('a delta carries the observed value as its precondition', () async {
    await writer.queueDelta(
      table: 'students',
      rowId: 'student-1',
      field: 'special_needs',
      observedValue: <String>[],
      newValue: <String>['Dyslexia'],
    );

    await pusher.drain();

    expect(remote.deltas, hasLength(1));
    expect(remote.deltas.single['observedValue'], <String>[]);
    expect(remote.deltas.single['newValue'], <String>['Dyslexia']);
  });

  test('a conflict is recorded locally and the entry is dropped', () async {
    remote.deltaResponses.add(<String, dynamic>{
      'status': 'conflict',
      'server_value': <String>['ADHD'],
    });
    await writer.queueDelta(
      table: 'students',
      rowId: 'student-1',
      field: 'special_needs',
      observedValue: <String>[],
      newValue: <String>['Dyslexia'],
    );

    final report = await pusher.drain();

    expect(report.conflicted, 1);
    final conflicts = await db.select(db.localConflicts).get();
    expect(conflicts, hasLength(1));
    expect(conflicts.single.field, 'special_needs');
    // Dropped, not retried: retrying a stale precondition can only fail again.
    expect(await db.select(db.outbox).get(), isEmpty);
  });

  test('a transport failure retains the entry and counts an attempt', () async {
    remote.failures.add('teacher_observations');
    await writer.queueInsert(
      table: 'teacher_observations',
      row: <String, dynamic>{'id': 'obs-1', 'body': 'Note'},
    );

    final report = await pusher.drain();

    expect(report.retained, 1);
    final entries = await db.select(db.outbox).get();
    expect(entries, hasLength(1));
    expect(entries.single.attempts, 1);
    expect(entries.single.lastError, isNotNull);
  });

  test('entries are sent in the order they were queued', () async {
    for (final String id in <String>['a', 'b', 'c']) {
      await writer.queueInsert(
        table: 'teacher_observations',
        row: <String, dynamic>{'id': id, 'body': id},
      );
    }

    await pusher.drain();

    expect(
      remote.upserted.map((Map<String, dynamic> row) => row['id']).toList(),
      <String>['a', 'b', 'c'],
    );
  });
}
