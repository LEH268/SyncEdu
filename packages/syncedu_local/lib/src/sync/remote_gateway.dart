/// Everything the sync engine needs from the server, expressed without
/// reference to Supabase so the engine can be tested with no network.
abstract interface class RemoteGateway {
  /// Rows changed strictly after [watermark], ordered by `updated_at`
  /// ascending. A null watermark means "everything visible to me".
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? watermark, {
    int limit,
  });

  /// Idempotent insert for append-only tier-1 rows. Duplicate ids are ignored
  /// rather than erroring, so a replay after a dropped connection is safe.
  Future<void> upsertIgnoringDuplicates(
    String table,
    List<Map<String, dynamic>> rows,
  );

  /// Calls the apply_delta RPC. Returns its status object unchanged.
  Future<Map<String, dynamic>> applyDelta({
    required String table,
    required String rowId,
    required String field,
    required Object? observedValue,
    required Object? newValue,
    required DateTime clientTs,
  });
}
