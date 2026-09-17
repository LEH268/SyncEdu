import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Fields the spec names tier-3 (`docs/superpowers/specs/2026-09-05-syncedu-
/// design.md`, the sync-tiers table): contended, compare-and-set fields that
/// need a human decision on conflict, unlike a tier-2 last-writer-wins
/// supersession. [LocalConflicts] carries no tier column of its own, so
/// this is how the tray tells the two apart -- a judgment call, but one
/// pinned to the exact field list the spec gives for T3.
const Set<String> kTier3Fields = <String>{
  'class_id',
  'special_needs',
  'target_learning_style',
};

/// Shows every unresolved [LocalConflict] and lets the viewer choose how to
/// settle each one. Renders nothing at all when there is nothing to show --
/// an empty tray should not occupy space or announce itself.
class ConflictTray extends StatelessWidget {
  const ConflictTray({
    super.key,
    required this.conflicts,
    required this.onResolve,
  });

  final List<LocalConflict> conflicts;
  final void Function(String id, ConflictResolution choice) onResolve;

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) return const SizedBox.shrink();

    return Column(
      key: const Key('conflict-tray'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: conflicts
          .map((LocalConflict c) => _ConflictTile(conflict: c, onResolve: onResolve))
          .toList(),
    );
  }
}

class _ConflictTile extends StatelessWidget {
  const _ConflictTile({required this.conflict, required this.onResolve});

  final LocalConflict conflict;
  final void Function(String id, ConflictResolution choice) onResolve;

  bool get _isTier3 => kTier3Fields.contains(conflict.field);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('conflict-${conflict.id}'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _isTier3 ? 'Needs a decision' : 'Overwritten',
              key: Key('conflict-label-${conflict.id}'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text('${conflict.table}.${conflict.field}'),
            Text(
              'Your value: ${conflict.attemptedValue ?? '(none)'}',
              key: Key('conflict-mine-${conflict.id}'),
            ),
            Text(
              "Server's value: ${conflict.serverValue ?? '(none)'}",
              key: Key('conflict-server-${conflict.id}'),
            ),
            Text(
              'Detected at ${conflict.detectedAt.toIso8601String()}',
              key: Key('conflict-detected-${conflict.id}'),
            ),
            if (_isTier3)
              Row(
                children: <Widget>[
                  TextButton(
                    key: Key('conflict-keep-mine-${conflict.id}'),
                    onPressed: () =>
                        onResolve(conflict.id, ConflictResolution.keepMine),
                    child: const Text('Keep mine'),
                  ),
                  TextButton(
                    key: Key('conflict-keep-server-${conflict.id}'),
                    onPressed: () =>
                        onResolve(conflict.id, ConflictResolution.keepServer),
                    child: const Text('Keep server'),
                  ),
                ],
              )
            else
              TextButton(
                key: Key('conflict-acknowledge-${conflict.id}'),
                onPressed: () =>
                    onResolve(conflict.id, ConflictResolution.keepServer),
                child: const Text('Acknowledge'),
              ),
          ],
        ),
      ),
    );
  }
}
