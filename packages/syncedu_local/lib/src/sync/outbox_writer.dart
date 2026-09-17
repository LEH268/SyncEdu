import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// Queues pending writes. Every mutation in the applications goes through
/// here; nothing writes to the server directly.
class OutboxWriter {
  OutboxWriter(this._db);

  final SyncEduDatabase _db;

  /// An append-only tier-1 row. The row's own client-supplied id makes replay
  /// idempotent, so a dropped connection costs a retry and never a duplicate.
  Future<void> queueInsert({
    required String table,
    required Map<String, dynamic> row,
  }) async {
    await _db.into(_db.outbox).insert(
          OutboxCompanion.insert(
            id: 'ins-${row['id']}',
            op: 'insert',
            table: table,
            rowId: row['id'] as String,
            payload: Value(jsonEncode(row)),
            clientTs: DateTime.now().toUtc(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// A single field on a tier-2 or tier-3 row. [observedValue] is the value
  /// this device last saw, and becomes the server-side precondition.
  Future<void> queueDelta({
    required String table,
    required String rowId,
    required String field,
    required Object? observedValue,
    required Object? newValue,
  }) async {
    await _db.into(_db.outbox).insert(
          OutboxCompanion.insert(
            // One pending delta per (row, field): a second local edit before
            // sync replaces the first, which is what the user means by it.
            id: 'delta-$table-$rowId-$field',
            op: 'delta',
            table: table,
            rowId: rowId,
            field: Value(field),
            observedValue: Value(jsonEncode(observedValue)),
            newValue: Value(jsonEncode(newValue)),
            clientTs: DateTime.now().toUtc(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}
