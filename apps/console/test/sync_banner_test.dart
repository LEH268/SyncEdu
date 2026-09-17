import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/widgets/sync_banner.dart';
import 'package:syncedu_local/syncedu_local.dart';

Future<void> pumpBanner(WidgetTester tester, SyncStatus status) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: SyncBanner(status: status))),
  );
}

void main() {
  testWidgets('a clean online status shows nothing', (tester) async {
    await pumpBanner(
      tester,
      SyncStatus(
        online: true,
        syncing: false,
        pendingWrites: 0,
        unresolvedConflicts: 0,
        lastSuccessAt: DateTime.utc(2026, 9, 5, 9),
      ),
    );
    expect(find.byKey(const Key('sync-banner')), findsNothing);
  });

  testWidgets('offline with pending writes says how many', (tester) async {
    await pumpBanner(
      tester,
      const SyncStatus(
        online: false,
        syncing: false,
        pendingWrites: 3,
        unresolvedConflicts: 0,
      ),
    );
    expect(find.byKey(const Key('sync-banner')), findsOneWidget);
    expect(find.textContaining('3'), findsOneWidget);
    expect(find.textContaining('Offline'), findsOneWidget);
  });

  testWidgets('conflicts are surfaced even when online', (tester) async {
    await pumpBanner(
      tester,
      SyncStatus(
        online: true,
        syncing: false,
        pendingWrites: 0,
        unresolvedConflicts: 2,
        lastSuccessAt: DateTime.utc(2026, 9, 5, 9),
      ),
    );
    // A conflict needs a human, so it must never be hidden by a green state.
    expect(find.byKey(const Key('sync-banner')), findsOneWidget);
    expect(find.textContaining('2'), findsOneWidget);
  });
}
