import '../sync/remote_gateway.dart';

/// In-memory [RemoteGateway] for tests. Records what was asked for so the
/// watermark behaviour can be asserted rather than inferred.
class FakeRemoteGateway implements RemoteGateway {
  final Map<String, List<Map<String, dynamic>>> rows =
      <String, List<Map<String, dynamic>>>{};

  /// Tables whose fetch should throw.
  final Set<String> failures = <String>{};

  final Map<String, List<DateTime?>> watermarksRequested =
      <String, List<DateTime?>>{};

  final List<Map<String, dynamic>> upserted = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> deltas = <Map<String, dynamic>>[];

  /// Status objects returned by [applyDelta], consumed in order. Defaults to
  /// `{'status': 'applied'}` once exhausted.
  final List<Map<String, dynamic>> deltaResponses = <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? watermark, {
    int limit = 500,
  }) async {
    watermarksRequested.putIfAbsent(table, () => <DateTime?>[]).add(watermark);
    if (failures.contains(table)) {
      throw StateError('fetch failed for $table');
    }
    final List<Map<String, dynamic>> all = rows[table] ?? <Map<String, dynamic>>[];
    if (watermark == null) return List<Map<String, dynamic>>.from(all);
    return all
        .where((Map<String, dynamic> row) =>
            DateTime.parse(row['updated_at'] as String).toUtc().isAfter(watermark))
        .toList();
  }

  @override
  Future<void> upsertIgnoringDuplicates(
    String table,
    List<Map<String, dynamic>> newRows,
  ) async {
    if (failures.contains(table)) {
      throw StateError('upsert failed for $table');
    }
    for (final Map<String, dynamic> row in newRows) {
      upserted.add(<String, dynamic>{'table': table, ...row});
    }
  }

  @override
  Future<Map<String, dynamic>> applyDelta({
    required String table,
    required String rowId,
    required String field,
    required Object? observedValue,
    required Object? newValue,
    required DateTime clientTs,
  }) async {
    deltas.add(<String, dynamic>{
      'table': table,
      'rowId': rowId,
      'field': field,
      'observedValue': observedValue,
      'newValue': newValue,
    });
    if (deltaResponses.isEmpty) return <String, dynamic>{'status': 'applied'};
    return deltaResponses.removeAt(0);
  }
}
