import 'package:drift/drift.dart';

/// One watermark per mirrored table. The puller asks for rows changed after
/// it, so it must only advance once those rows are committed locally.
class SyncState extends Table {
  TextColumn get table => text()();
  DateTimeColumn get watermark => dateTime().nullable()();
  DateTimeColumn get lastPullAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{table};
}

/// Pending writes. `op` is 'insert' for append-only tier-1 rows, whose payload
/// is the whole row, or 'delta' for a single field on a tier-2/3 row.
///
/// Field-level deltas are what stop one user's offline edit clobbering an
/// unrelated field another user changed in the same row.
class Outbox extends Table {
  TextColumn get id => text()();
  TextColumn get op => text()();
  TextColumn get table => text()();
  TextColumn get rowId => text()();
  TextColumn get field => text().nullable()();
  TextColumn get observedValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get payload => text().nullable()();
  DateTimeColumn get clientTs => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Work that needs the network by nature -- a Gemini call, or account
/// creation. Recorded locally, shown in a pending tray, executed on reconnect.
class PendingIntents extends Table {
  TextColumn get id => text()();
  TextColumn get functionName => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Local mirror of server-side sync_conflicts, plus locally-detected ones, so
/// the conflict tray renders offline.
class LocalConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get table => text()();
  TextColumn get rowId => text()();
  TextColumn get field => text()();
  TextColumn get observedValue => text().nullable()();
  TextColumn get attemptedValue => text().nullable()();
  TextColumn get serverValue => text().nullable()();
  DateTimeColumn get detectedAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
