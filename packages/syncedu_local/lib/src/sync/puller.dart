import '../db/database.dart';
import 'remote_gateway.dart';
import 'sync_descriptor.dart';

class PullReport {
  const PullReport({required this.rowsByTable, required this.failures});

  final Map<String, int> rowsByTable;
  final List<String> failures;

  bool get isClean => failures.isEmpty;
}

/// Pulls each table forward from its own watermark.
///
/// The watermark advances only after the rows are committed locally: crashing
/// mid-pull re-fetches rather than skipping, and re-fetching is harmless
/// because upserts are idempotent.
class Puller {
  Puller(this._db, this._remote, this._descriptors);

  final SyncEduDatabase _db;
  final RemoteGateway _remote;
  final List<SyncDescriptor> _descriptors;

  static const int pageSize = 500;

  Future<PullReport> pullAll() async {
    final Map<String, int> counts = <String, int>{};
    final List<String> failures = <String>[];

    for (final SyncDescriptor descriptor in _descriptors) {
      try {
        counts[descriptor.table] = await _pullOne(descriptor);
      } on Object {
        // One table failing must not strand the others: a teacher with a
        // broken roster still needs their schedule.
        failures.add(descriptor.table);
      }
    }

    return PullReport(rowsByTable: counts, failures: failures);
  }

  Future<int> _pullOne(SyncDescriptor descriptor) async {
    int total = 0;
    DateTime? watermark = await _db.watermarkFor(descriptor.table);

    while (true) {
      final List<Map<String, dynamic>> rows = await _remote.fetchSince(
        descriptor.table,
        watermark,
        limit: pageSize,
      );
      if (rows.isEmpty) break;

      await descriptor.upsert(_db, rows);
      total += rows.length;

      final DateTime newest =
          DateTime.parse(rows.last['updated_at'] as String).toUtc();
      await _db.setWatermark(descriptor.table, newest);
      watermark = newest;

      if (rows.length < pageSize) break;
    }

    return total;
  }
}
