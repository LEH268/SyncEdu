import 'dart:async';
import 'dart:ffi';
import 'dart:io';

/// `flutter test` does not build package:sqlite3's native-assets hook (that
/// only runs for `flutter run`/`flutter build`), so the FFI bindings it
/// generates cannot resolve `sqlite3_initialize` on their own. Loading a
/// system sqlite3 library into the process ahead of time lets their
/// documented fallback -- "resolve missing symbols against already-loaded
/// modules" -- succeed instead. This is dev/test tooling only; the shipped
/// app is unaffected because `flutter run`/`build` bundle sqlite3 via the
/// hook as designed.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final String? path = Platform.isWindows
      ? Directory.current.path.contains('syncedu_local')
          ? 'sqlite3.dll'
          : 'packages/syncedu_local/sqlite3.dll'
      : Platform.isMacOS
          ? '/usr/lib/libsqlite3.dylib'
          : Platform.isLinux
              ? 'libsqlite3.so.0'
              : null;

  if (path != null && File(path).existsSync()) {
    DynamicLibrary.open(path);
  } else if (path != null && !Platform.isWindows) {
    // On Linux/macOS the system library is normally already discoverable.
    try {
      DynamicLibrary.open(path);
    } on Object {
      // Fall through -- the native-assets hook may already provide it.
    }
  }

  await testMain();
}
