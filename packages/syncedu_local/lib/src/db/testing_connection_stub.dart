import 'package:drift/drift.dart';

/// The in-memory native executor is unavailable when compiled to the web.
///
/// Nothing in the shipped apps calls this: it only backs
/// `SyncEduDatabase.forTesting()`, which tests run on the Dart VM.
QueryExecutor testingExecutor() => throw UnsupportedError(
      'SyncEduDatabase.forTesting() is not available on the web.',
    );
