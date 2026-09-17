import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote_gateway.dart';

/// [RemoteGateway] over PostgREST. RLS decides visibility, so no query here
/// filters by school -- doing so in the client would be redundant and would
/// invite the mistake of trusting it.
class SupabaseRemoteGateway implements RemoteGateway {
  SupabaseRemoteGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? watermark, {
    int limit = 500,
  }) async {
    final PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
        _client.from(table).select();

    final List<Map<String, dynamic>> rows = await (watermark == null
            ? query
            : query.gt('updated_at', watermark.toUtc().toIso8601String()))
        .order('updated_at', ascending: true)
        .limit(limit);

    return rows;
  }

  @override
  Future<void> upsertIgnoringDuplicates(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    await _client.from(table).upsert(rows, ignoreDuplicates: true);
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
    final Object? result = await _client.rpc<Object?>(
      'apply_delta',
      params: <String, dynamic>{
        'p_table': table,
        'p_row_id': rowId,
        'p_field': field,
        'p_observed': observedValue,
        'p_new': newValue,
        'p_client_ts': clientTs.toUtc().toIso8601String(),
      },
    );
    return (result as Map<String, dynamic>?) ??
        <String, dynamic>{'status': 'not_visible'};
  }
}
