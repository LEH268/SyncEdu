import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'remote_gateway.dart';

class PushReport {
  const PushReport({
    required this.applied,
    required this.conflicted,
    required this.superseded,
    required this.retained,
  });

  final int applied;
  final int conflicted;
  final int superseded;
  final int retained;

  bool get isClean => retained == 0 && conflicted == 0;
}

/// Drains the outbox in queue order.
///
/// Order matters: a delta against a row whose insert has not landed would be
/// refused, so entries are never reordered or parallelised.
class Pusher {
  Pusher(this._db, this._remote);

  final SyncEduDatabase _db;
  final RemoteGateway _remote;

  Future<PushReport> drain() async {
    final List<OutboxData> entries =
        await (_db.select(_db.outbox)..orderBy(<OrderClauseGenerator<$OutboxTable>>[
              ($OutboxTable t) => OrderingTerm.asc(t.clientTs),
              ($OutboxTable t) => OrderingTerm.asc(t.id),
            ]))
            .get();

    int applied = 0;
    int conflicted = 0;
    int superseded = 0;
    int retained = 0;

    for (final OutboxData entry in entries) {
      try {
        if (entry.op == 'insert') {
          await _remote.upsertIgnoringDuplicates(
            entry.table,
            <Map<String, dynamic>>[
              jsonDecode(entry.payload!) as Map<String, dynamic>,
            ],
          );
          await _delete(entry);
          applied++;
          continue;
        }

        final Map<String, dynamic> result = await _remote.applyDelta(
          table: entry.table,
          rowId: entry.rowId,
          field: entry.field!,
          observedValue: jsonDecode(entry.observedValue ?? 'null'),
          newValue: jsonDecode(entry.newValue ?? 'null'),
          clientTs: entry.clientTs,
        );

        switch (result['status']) {
          case 'applied':
            await _delete(entry);
            applied++;
          case 'conflict':
            await _recordConflict(entry, result['server_value']);
            await _delete(entry);
            conflicted++;
          case 'superseded':
            await _recordConflict(entry, result['server_value']);
            await _delete(entry);
            superseded++;
          default:
            // forbidden or not_visible: retrying cannot help, and keeping the
            // entry would block everything queued behind it.
            await _delete(entry);
            conflicted++;
        }
      } on Object catch (error) {
        await (_db.update(_db.outbox)
              ..where(($OutboxTable t) => t.id.equals(entry.id)))
            .write(
          OutboxCompanion(
            attempts: Value(entry.attempts + 1),
            lastError: Value(error.toString()),
          ),
        );
        retained++;
      }
    }

    return PushReport(
      applied: applied,
      conflicted: conflicted,
      superseded: superseded,
      retained: retained,
    );
  }

  Future<void> _delete(OutboxData entry) =>
      (_db.delete(_db.outbox)..where(($OutboxTable t) => t.id.equals(entry.id)))
          .go();

  Future<void> _recordConflict(OutboxData entry, Object? serverValue) async {
    await _db.into(_db.localConflicts).insert(
          LocalConflictsCompanion.insert(
            id: 'conflict-${entry.id}-${DateTime.now().microsecondsSinceEpoch}',
            table: entry.table,
            rowId: entry.rowId,
            field: entry.field!,
            observedValue: Value(entry.observedValue),
            attemptedValue: Value(entry.newValue),
            serverValue: Value(jsonEncode(serverValue)),
            detectedAt: DateTime.now().toUtc(),
          ),
        );
  }
}
