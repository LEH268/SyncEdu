import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_local/syncedu_local.dart';

void main() {
  late SyncEduDatabase db;
  late FakeRemoteGateway remote;
  late StreamController<bool> connectivity;
  late SyncEngine engine;

  setUp(() {
    db = SyncEduDatabase.forTesting();
    remote = FakeRemoteGateway();
    connectivity = StreamController<bool>.broadcast();
    engine = SyncEngine(
      db: db,
      puller: Puller(db, remote, defaultDescriptors),
      pusher: Pusher(db, remote),
      connectivity: connectivity.stream,
    );
  });

  tearDown(() async {
    await engine.dispose();
    await connectivity.close();
    await db.close();
  });

  test('syncNow pushes before it pulls', () async {
    await OutboxWriter(db).queueInsert(
      table: 'teacher_observations',
      row: <String, dynamic>{'id': 'obs-1', 'body': 'Note'},
    );

    await engine.syncNow();

    // Pushing first means a locally-created row is on the server before the
    // pull that would otherwise report it missing.
    expect(remote.upserted, hasLength(1));
    expect(remote.watermarksRequested.keys, contains('students'));
  });

  test('status reports pending writes without a network', () async {
    await OutboxWriter(db).queueDelta(
      table: 'students',
      rowId: 'student-1',
      field: 'special_needs',
      observedValue: <String>[],
      newValue: <String>['ADHD'],
    );

    final status = await engine.currentStatus();
    expect(status.pendingWrites, 1);
  });

  test('going offline suppresses syncing and going online resumes it',
      () async {
    connectivity.add(false);
    await Future<void>.delayed(Duration.zero);

    final offline = await engine.syncNow();
    expect(offline.online, isFalse);
    expect(remote.watermarksRequested, isEmpty,
        reason: 'no request may be attempted while offline');

    connectivity.add(true);
    await Future<void>.delayed(Duration.zero);

    final online = await engine.syncNow();
    expect(online.online, isTrue);
    expect(remote.watermarksRequested, isNotEmpty);
  });

  test('a failed pull is reported but does not throw', () async {
    connectivity.add(true);
    await Future<void>.delayed(Duration.zero);
    remote.failures.addAll(<String>['schools', 'profiles', 'students']);

    final status = await engine.syncNow();

    expect(status.lastError, isNotNull);
    expect(status.lastSuccessAt, isNull);
  });

  test('unresolved conflicts are surfaced in status', () async {
    remote.deltaResponses.add(<String, dynamic>{
      'status': 'conflict',
      'server_value': <String>['ADHD'],
    });
    await OutboxWriter(db).queueDelta(
      table: 'students',
      rowId: 'student-1',
      field: 'special_needs',
      observedValue: <String>[],
      newValue: <String>['Dyslexia'],
    );
    connectivity.add(true);
    await Future<void>.delayed(Duration.zero);

    await engine.syncNow();
    final status = await engine.currentStatus();

    expect(status.unresolvedConflicts, 1);
  });
}
