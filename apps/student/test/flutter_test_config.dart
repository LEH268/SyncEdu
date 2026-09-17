import 'dart:async';
import 'dart:ffi';
import 'dart:io';

/// Same rationale as `packages/syncedu_local/test/flutter_test_config.dart`:
/// `flutter test` does not build package:sqlite3's native-assets hook, so the
/// FFI bindings cannot resolve `sqlite3_initialize` on their own. Loading a
/// sqlite3 library into the process first lets their documented fallback --
/// "resolve missing symbols against already-loaded modules" -- succeed. Only
/// the app tests that actually open `SyncEduDatabase.forTesting()` need it;
/// the shipped app is unaffected.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final List<String> candidates = Platform.isWindows
      ? <String>[
          '../../packages/syncedu_local/sqlite3.dll',
          'packages/syncedu_local/sqlite3.dll',
          'sqlite3.dll',
        ]
      : Platform.isMacOS
          ? <String>['/usr/lib/libsqlite3.dylib']
          : <String>['libsqlite3.so.0'];

  for (final String path in candidates) {
    try {
      DynamicLibrary.open(path);
      break;
    } on Object {
      // Try the next candidate; the native-assets hook may already provide it.
    }
  }

  await testMain();
}
