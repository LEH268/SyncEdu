import 'dart:async';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'puller.dart';
import 'pusher.dart';

class SyncStatus {
  const SyncStatus({
    required this.online,
    required this.syncing,
    required this.pendingWrites,
    required this.unresolvedConflicts,
    this.lastSuccessAt,
    this.lastError,
  });

  final bool online;
  final bool syncing;
  final int pendingWrites;
  final int unresolvedConflicts;
  final DateTime? lastSuccessAt;
  final String? lastError;
}

/// Orchestrates push then pull, on a timer and on reconnection.
///
/// Push runs first so a row created on this device exists on the server
/// before the pull that would otherwise not see it.
class SyncEngine {
  SyncEngine({
    required SyncEduDatabase db,
    required Puller puller,
    required Pusher pusher,
    required Stream<bool> connectivity,
    this.interval = const Duration(minutes: 2),
  })  : // The public parameter names (db, puller, pusher) intentionally
        // differ from the private field names for API clarity, so the
        // `this._field` initializing-formal shorthand isn't available here.
        // ignore: prefer_initializing_formals
        _db = db,
        // ignore: prefer_initializing_formals
        _puller = puller,
        // ignore: prefer_initializing_formals
        _pusher = pusher {
    _connectivitySubscription = connectivity.listen((bool value) {
      final bool wasOffline = !_online;
      _online = value;
      if (wasOffline && value) {
        unawaited(syncNow());
      } else {
        unawaited(currentStatus().then(_emit));
      }
    });
  }

  final SyncEduDatabase _db;
  final Puller _puller;
  final Pusher _pusher;
  final Duration interval;

  final StreamController<SyncStatus> _status =
      StreamController<SyncStatus>.broadcast();

  late final StreamSubscription<bool> _connectivitySubscription;
  Timer? _timer;

  bool _online = true;
  bool _syncing = false;
  DateTime? _lastSuccessAt;
  String? _lastError;

  Stream<SyncStatus> get status => _status.stream;

  void start() {
    _timer ??= Timer.periodic(interval, (_) => unawaited(syncNow()));
  }

  Future<SyncStatus> currentStatus() async {
    final int pending = await _db.outbox.count().getSingle();
    final int conflicts = await (_db.selectOnly(_db.localConflicts)
          ..addColumns(<Expression<Object>>[_db.localConflicts.id.count()])
          ..where(_db.localConflicts.resolvedAt.isNull()))
        .map((TypedResult row) => row.read(_db.localConflicts.id.count()) ?? 0)
        .getSingle();

    return SyncStatus(
      online: _online,
      syncing: _syncing,
      pendingWrites: pending,
      unresolvedConflicts: conflicts,
      lastSuccessAt: _lastSuccessAt,
      lastError: _lastError,
    );
  }

  Future<SyncStatus> syncNow() async {
    if (_syncing || !_online) return _emit(await currentStatus());

    _syncing = true;
    _emit(await currentStatus());

    try {
      final PushReport push = await _pusher.drain();
      final PullReport pull = await _puller.pullAll();

      if (pull.failures.isEmpty && push.retained == 0) {
        _lastSuccessAt = DateTime.now().toUtc();
        _lastError = null;
      } else {
        _lastError = <String>[
          if (pull.failures.isNotEmpty) 'pull failed: ${pull.failures.join(", ")}',
          if (push.retained > 0) '${push.retained} write(s) still pending',
        ].join('; ');
      }
    } on Object catch (error) {
      _lastError = error.toString();
    } finally {
      _syncing = false;
    }

    return _emit(await currentStatus());
  }

  SyncStatus _emit(SyncStatus value) {
    if (!_status.isClosed) _status.add(value);
    return value;
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _connectivitySubscription.cancel();
    await _status.close();
  }
}
