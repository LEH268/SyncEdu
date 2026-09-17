import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/shared/conflict_tray.dart';
import 'package:syncedu_local/syncedu_local.dart';

LocalConflict _conflict({
  required String id,
  required String field,
  String table = 'students',
  String? observed,
  String? attempted,
  String? server,
  DateTime? detectedAt,
}) {
  return LocalConflict(
    id: id,
    table: table,
    rowId: 'row-$id',
    field: field,
    observedValue: observed,
    attemptedValue: attempted,
    serverValue: server,
    detectedAt: detectedAt ?? DateTime.utc(2026, 3, 1, 9, 30),
    resolvedAt: null,
  );
}

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('an unresolved conflict shows both values with their timestamps',
      (tester) async {
    final LocalConflict conflict = _conflict(
      id: 'c1',
      field: 'class_id',
      attempted: 'class-a',
      server: 'class-b',
      detectedAt: DateTime.utc(2026, 3, 1, 9, 30),
    );

    await tester.pumpWidget(
      wrap(ConflictTray(conflicts: <LocalConflict>[conflict], onResolve: (_, _) {})),
    );

    expect(find.textContaining('class-a'), findsOneWidget);
    expect(find.textContaining('class-b'), findsOneWidget);
    expect(find.textContaining('2026-03-01'), findsOneWidget);
  });

  testWidgets('choosing a resolution clears it from the tray', (tester) async {
    List<LocalConflict> conflicts = <LocalConflict>[
      _conflict(id: 'c1', field: 'class_id', attempted: 'a', server: 'b'),
    ];
    String? resolvedId;
    ConflictResolution? resolvedChoice;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return wrap(ConflictTray(
            conflicts: conflicts,
            onResolve: (String id, ConflictResolution choice) {
              resolvedId = id;
              resolvedChoice = choice;
              setState(() {
                conflicts = conflicts.where((LocalConflict c) => c.id != id).toList();
              });
            },
          ));
        },
      ),
    );

    expect(find.byKey(const Key('conflict-c1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('conflict-keep-mine-c1')));
    await tester.pumpAndSettle();

    expect(resolvedId, 'c1');
    expect(resolvedChoice, ConflictResolution.keepMine);
    expect(find.byKey(const Key('conflict-c1')), findsNothing);
  });

  testWidgets('a tier-2 supersession is labelled as overwritten, not as an error',
      (tester) async {
    final LocalConflict conflict = _conflict(
      id: 'c1',
      field: 'taught_on',
      table: 'class_chapter_sched',
      attempted: '2026-02-01',
      server: '2026-02-05',
    );

    await tester.pumpWidget(
      wrap(ConflictTray(conflicts: <LocalConflict>[conflict], onResolve: (_, _) {})),
    );

    expect(find.text('Overwritten'), findsOneWidget);
    expect(find.textContaining('Error'), findsNothing);
  });

  testWidgets('a tier-3 conflict is labelled as needing a decision', (tester) async {
    final LocalConflict conflict = _conflict(
      id: 'c1',
      field: 'special_needs',
      attempted: '["dyslexia"]',
      server: '["adhd"]',
    );

    await tester.pumpWidget(
      wrap(ConflictTray(conflicts: <LocalConflict>[conflict], onResolve: (_, _) {})),
    );

    expect(find.text('Needs a decision'), findsOneWidget);
  });

  testWidgets('an empty tray is not shown at all', (tester) async {
    await tester.pumpWidget(
      wrap(ConflictTray(conflicts: const <LocalConflict>[], onResolve: (_, _) {})),
    );

    expect(find.byKey(const Key('conflict-tray')), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
    expect(tester.getSize(find.byType(SizedBox)), Size.zero);
  });
}
