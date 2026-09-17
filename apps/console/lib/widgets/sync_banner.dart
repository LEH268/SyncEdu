import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Shown only when there is something the user should know: offline, work
/// queued, or a conflict waiting on a decision. A permanently visible "synced"
/// badge trains people to ignore the row it lives in.
class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key, required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final List<String> messages = <String>[
      if (!status.online) 'Offline',
      if (status.pendingWrites > 0)
        '${status.pendingWrites} change${status.pendingWrites == 1 ? '' : 's'} waiting to sync',
      if (status.unresolvedConflicts > 0)
        '${status.unresolvedConflicts} conflict${status.unresolvedConflicts == 1 ? '' : 's'} need review',
    ];

    if (messages.isEmpty) return const SizedBox.shrink();

    final ColorScheme colours = Theme.of(context).colorScheme;
    final bool needsAttention = status.unresolvedConflicts > 0;

    return Material(
      key: const Key('sync-banner'),
      color: needsAttention ? colours.errorContainer : colours.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(
              needsAttention ? Icons.error_outline : Icons.cloud_off,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(messages.join(' · '))),
          ],
        ),
      ),
    );
  }
}
