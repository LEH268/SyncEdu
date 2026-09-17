import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper over the Phase 9 Edge Functions the console calls. When
/// [supabase] is null (tests, or an offline build) every call throws
/// [ConsoleOffline], and each caller has a deterministic Dart fallback — the
/// rule stays: every arithmetic figure is Dart's, the model only writes prose.
class ConsoleFunctions {
  const ConsoleFunctions(this._supabase);

  final SupabaseClient? _supabase;

  bool get online => _supabase != null;

  /// One rationale per placement suggestion. `source` is 'ai' or 'rule'.
  Future<Map<String, dynamic>> suggestPlacement(
      Map<String, dynamic> body) async {
    return _invoke('suggest-placement', body);
  }

  /// `{ source, teacherPct, recommendation }` — teacherPct null and
  /// recommendation null when the model call failed and the console should
  /// use `ruleBasedRecommendation`.
  Future<Map<String, dynamic>> analyseFit(Map<String, dynamic> body) async {
    return _invoke('analyse-fit', body);
  }

  /// `{ id, summary, actions, deck, source }` for one (class, chapter)
  /// teaching review. Every figure in `body.signals` was computed by
  /// `reviewTeaching`; the function only writes prose and slides about them.
  Future<Map<String, dynamic>> suggestTeaching(
      Map<String, dynamic> body) async {
    return _invoke('suggest-teaching', body);
  }

  Future<Map<String, dynamic>> _invoke(
      String name, Map<String, dynamic> body) async {
    final SupabaseClient? client = _supabase;
    if (client == null) throw const ConsoleOffline();
    final FunctionResponse response =
        await client.functions.invoke(name, body: body);
    return (response.data as Map<dynamic, dynamic>).cast<String, dynamic>();
  }
}

class ConsoleOffline implements Exception {
  const ConsoleOffline();
  @override
  String toString() => 'ConsoleOffline: this action needs a connection';
}
