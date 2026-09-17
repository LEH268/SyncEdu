import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// The local mirror database. Overridden with a real instance once Riverpod
/// wiring lands (Task 10 of this phase) -- until then, nothing here is
/// consumed, but tests can already override it with an in-memory database.
final Provider<SyncEduDatabase> databaseProvider = Provider<SyncEduDatabase>(
  (Ref ref) => throw UnimplementedError(
    'databaseProvider must be overridden with a SyncEduDatabase instance',
  ),
);

/// The single place every console screen reads analytics rows through, so no
/// screen computes a figure of its own.
final Provider<AnalyticsRepository> analyticsRepositoryProvider =
    Provider<AnalyticsRepository>(
  (Ref ref) => AnalyticsRepository(ref.watch(databaseProvider)),
);

/// Keyed by an optional class id; `null` returns every live row.
final analyticRowsProvider = StreamProvider.family<List<AnalyticRow>, String?>(
  (Ref ref, String? classId) =>
      ref.watch(analyticsRepositoryProvider).watchRows(classId: classId),
);

/// Keyed by an optional student id; `null` returns every live attempt.
final attemptRowsProvider = StreamProvider.family<List<AttemptRow>, String?>(
  (Ref ref, String? studentId) =>
      ref.watch(analyticsRepositoryProvider).watchAttempts(studentId: studentId),
);

/// Keyed by an optional student id; `null` returns every live weakness.
final weaknessRowsProvider = StreamProvider.family<List<WeaknessRow>, String?>(
  (Ref ref, String? studentId) =>
      ref.watch(analyticsRepositoryProvider).watchWeaknesses(studentId: studentId),
);
