import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

const List<double> _flat = <double>[
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];
const List<double> _wild = <double>[
  0.3, -0.2, 0.25, -0.15, 0.3, -0.1, 0.2, -0.25, 0.15, -0.3, 0.1, -0.2, 0.28, -0.18,
];

void main() {
  test('the body path is closed', () {
    final Path path = buildBodyPath(
      size: const Size(200, 200),
      radialOffsets: _flat,
      squash: 1.0,
    );
    final PathMetric metric = path.computeMetrics().first;
    expect(metric.isClosed, isTrue);
  });

  test('the path stays inside its bounds', () {
    for (final double squash in <double>[0.8, 1.0, 1.2]) {
      final Rect bounds = buildBodyPath(
        size: const Size(200, 200),
        radialOffsets: _wild,
        squash: squash,
      ).getBounds();
      expect(bounds.left, greaterThanOrEqualTo(-0.01));
      expect(bounds.top, greaterThanOrEqualTo(-0.01));
      expect(bounds.right, lessThanOrEqualTo(200.01));
      expect(bounds.bottom, lessThanOrEqualTo(200.01));
    }
  });

  test('the silhouette is taller than it is wide at rest', () {
    final Rect bounds = buildBodyPath(
      size: const Size(200, 200),
      radialOffsets: _flat,
      squash: 1.0,
    ).getBounds();
    expect(bounds.height / bounds.width, closeTo(1.15, 0.08));
  });

  test('the base is flatter than the crown', () {
    final Rect b = buildBodyPath(
      size: const Size(200, 200),
      radialOffsets: _flat,
      squash: 1.0,
    ).getBounds();
    final Path path = buildBodyPath(
      size: const Size(200, 200),
      radialOffsets: _flat,
      squash: 1.0,
    );

    double widthNear(double y) {
      double minX = double.infinity;
      double maxX = -double.infinity;
      for (final PathMetric m in path.computeMetrics()) {
        for (double d = 0; d < m.length; d += 1) {
          final Offset p = m.getTangentForOffset(d)!.position;
          if ((p.dy - y).abs() <= b.height * 0.06) {
            minX = p.dx < minX ? p.dx : minX;
            maxX = p.dx > maxX ? p.dx : maxX;
          }
        }
      }
      return maxX - minX;
    }

    // The flat base spans a wide band of x near the bottom; the rounded crown
    // pinches to a point near the top.
    expect(widthNear(b.bottom - 1), greaterThan(widthNear(b.top + 1) * 1.5));
  });

  test('squashing widens and shortens without changing area much', () {
    final Rect rest = buildBodyPath(
      size: const Size(200, 200),
      radialOffsets: _flat,
      squash: 1.0,
    ).getBounds();
    final Rect squashed = buildBodyPath(
      size: const Size(200, 200),
      radialOffsets: _flat,
      squash: 1.25,
    ).getBounds();
    expect(squashed.width, greaterThan(rest.width));
    expect(squashed.height, lessThan(rest.height));
    expect(squashed.width * squashed.height,
        closeTo(rest.width * rest.height, rest.width * rest.height * 0.2));
  });

  test('below 40 dp the radial offsets are ignored', () {
    final Rect small = buildBodyPath(
      size: const Size(28, 32),
      radialOffsets: _wild,
      squash: 1.0,
    ).getBounds();
    final Rect neutral = buildBodyPath(
      size: const Size(28, 32),
      radialOffsets: _flat,
      squash: 1.0,
    ).getBounds();
    expect(small, neutral);
  });

  test('shouldRepaint is true only when something changed', () {
    final EyePair eyes = kEyeShapes[EmojiState.idle]!;
    const Color colour = Color(0xFF5B4BE8);
    final EmojiPainter a = EmojiPainter(
        bodyOffsets: _flat, squash: 1.0, eyes: eyes, colour: colour);
    final EmojiPainter same = EmojiPainter(
        bodyOffsets: _flat, squash: 1.0, eyes: eyes, colour: colour);
    final EmojiPainter moved = EmojiPainter(
        bodyOffsets: _wild, squash: 1.0, eyes: eyes, colour: colour);
    expect(a.shouldRepaint(same), isFalse);
    expect(a.shouldRepaint(moved), isTrue);
  });

  testWidgets('AiEmoji renders at 200 dp without overflowing', (tester) async {
    final EmojiController controller = EmojiController(random: Random(1));
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: AiEmoji(controller: controller, size: 200)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AiEmoji renders at 28 dp without overflowing', (tester) async {
    final EmojiController controller = EmojiController(random: Random(1));
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: AiEmoji(controller: controller, size: 28)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the widget stops ticking when removed from the tree',
      (tester) async {
    final EmojiController controller = EmojiController(random: Random(1));
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: AiEmoji(controller: controller, size: 100)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    // No Ticker was leaked; pumping does not throw about a live ticker.
    expect(tester.takeException(), isNull);
  });
}
