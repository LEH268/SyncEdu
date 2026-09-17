import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// A fresh in-memory database, used by `SyncEduDatabase.forTesting()`.
///
/// Kept behind a conditional import (`dart.library.ffi`) so that
/// `package:sqlite3`'s native FFI bindings, which do not compile for the
/// web, never make it into the web build of the apps.
QueryExecutor testingExecutor() => NativeDatabase.memory();
