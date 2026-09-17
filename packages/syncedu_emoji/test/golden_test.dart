import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

Future<void> pumpSettled(
  WidgetTester tester,
  EmojiState state,
  double size,
) async {
  final EmojiController controller =
      EmojiController(initial: state, random: Random(1));
  addTearDown(controller.dispose);

  // Advance past the spring transient so the golden captures the settled pose
  // rather than a frame mid-flight -- but stay under the shortest reaction
  // hold (celebrate, 1.4 s) so a reaction state has not already reverted.
  for (int i = 0; i < 120; i++) {
    controller.tick(const Duration(milliseconds: 8));
  }

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: AiEmoji(controller: controller, size: size)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  for (final EmojiState state in EmojiState.values) {
    testWidgets('golden: ${state.name} at 200dp', (tester) async {
      await pumpSettled(tester, state, 200);
      await expectLater(
        find.byType(AiEmoji),
        matchesGoldenFile('goldens/${state.name}_200.png'),
      );
    });

    testWidgets('golden: ${state.name} at 28dp', (tester) async {
      await pumpSettled(tester, state, 28);
      await expectLater(
        find.byType(AiEmoji),
        matchesGoldenFile('goldens/${state.name}_28.png'),
      );
    });
  }
}
