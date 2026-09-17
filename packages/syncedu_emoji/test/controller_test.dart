import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

void tickFor(EmojiController c, Duration total, {Duration step = const Duration(milliseconds: 16)}) {
  Duration elapsed = Duration.zero;
  while (elapsed < total) {
    c.tick(step);
    elapsed += step;
  }
}

void main() {
  test('starts idle', () {
    expect(EmojiController(random: Random(1)).state, EmojiState.idle);
  });

  test('setState changes the state immediately', () {
    final c = EmojiController(random: Random(1));
    c.setState(EmojiState.thinking);
    expect(c.state, EmojiState.thinking);
  });

  test('a reaction state reverts to idle after its hold elapses', () {
    final c = EmojiController(random: Random(1));
    c.setState(EmojiState.happy);
    c.tick(const Duration(milliseconds: 2000));
    expect(c.state, EmojiState.happy);
    c.tick(const Duration(milliseconds: 3000));
    expect(c.state, EmojiState.idle);
  });

  test('the hold duration falls inside the state\'s range', () {
    for (int seed = 0; seed < 20; seed++) {
      final c = EmojiController(random: Random(seed));
      c.setState(EmojiState.celebrate);
      Duration held = Duration.zero;
      while (c.state == EmojiState.celebrate && held < const Duration(seconds: 10)) {
        c.tick(const Duration(milliseconds: 20));
        held += const Duration(milliseconds: 20);
      }
      expect(held, greaterThanOrEqualTo(const Duration(milliseconds: 1380)));
      expect(held, lessThanOrEqualTo(const Duration(milliseconds: 2640)));
    }
  });

  test('listening does not revert on its own', () {
    final c = EmojiController(random: Random(1));
    c.setState(EmojiState.listening);
    tickFor(c, const Duration(seconds: 30));
    expect(c.state, EmojiState.listening);
  });

  test('a new state cancels a pending revert', () {
    final c = EmojiController(random: Random(1));
    c.setState(EmojiState.happy);
    c.tick(const Duration(milliseconds: 1000));
    c.setState(EmojiState.listening);
    c.tick(const Duration(seconds: 10));
    expect(c.state, EmojiState.listening);
  });

  test('idle cycles to another expression and returns', () {
    final c = EmojiController(random: Random(3));
    bool sawFlash = false;
    bool returnedToIdleAfterFlash = false;
    Duration elapsed = Duration.zero;
    while (elapsed < const Duration(seconds: 40)) {
      c.tick(const Duration(milliseconds: 100));
      elapsed += const Duration(milliseconds: 100);
      if (c.state != EmojiState.idle) {
        sawFlash = true;
      } else if (sawFlash) {
        returnedToIdleAfterFlash = true;
      }
    }
    expect(sawFlash, isTrue);
    expect(returnedToIdleAfterFlash, isTrue);
  });

  test('the idle cycle interval falls between nine and sixteen seconds', () {
    for (int seed = 0; seed < 10; seed++) {
      final c = EmojiController(random: Random(seed));
      Duration elapsed = Duration.zero;
      Duration? firstFlash;
      while (elapsed < const Duration(seconds: 20) && firstFlash == null) {
        c.tick(const Duration(milliseconds: 50));
        elapsed += const Duration(milliseconds: 50);
        if (c.state != EmojiState.idle) firstFlash = elapsed;
      }
      expect(firstFlash, isNotNull);
      expect(firstFlash!, greaterThanOrEqualTo(const Duration(seconds: 9)));
      expect(firstFlash, lessThanOrEqualTo(const Duration(milliseconds: 16050)));
    }
  });

  test('the cycler does not fire while a reaction is held', () {
    final c = EmojiController(random: Random(1));
    c.setState(EmojiState.sad); // holds 4-7 s
    tickFor(c, const Duration(seconds: 3));
    expect(c.state, EmojiState.sad);
  });

  test('springs converge towards the current pose', () {
    final c = EmojiController(random: Random(1));
    c.setState(EmojiState.confused);
    tickFor(c, const Duration(milliseconds: 1500));
    final List<double> target = poseFor(EmojiState.confused).radialOffsets;
    for (int i = 0; i < target.length; i++) {
      expect(c.bodyOffsets[i], closeTo(target[i], 0.02), reason: 'point $i');
    }
  });

  test('with reduceMotion the pose snaps in a single tick', () {
    final c = EmojiController(random: Random(1), reduceMotion: true);
    c.setState(EmojiState.celebrate);
    expect(c.bodyOffsets, poseFor(EmojiState.celebrate).radialOffsets);
    expect(c.colour.toARGB32(),
        kStateBehaviour[EmojiState.celebrate]!.colour.toARGB32());
    // Eyes are fully morphed, not mid-interpolation.
    final EyePair target = kEyeShapes[EmojiState.celebrate]!;
    for (int i = 0; i < target.left.length; i++) {
      expect(c.eyes.left[i], target.left[i]);
    }
  });

  test('sleeping breathes slowly rather than freezing', () {
    final c = EmojiController(random: Random(1));
    c.setState(EmojiState.sleeping);
    tickFor(c, const Duration(seconds: 2)); // settle the entry impulse
    final double resting = c.squash;
    double maxDelta = 0.0;
    Duration elapsed = Duration.zero;
    while (elapsed < const Duration(seconds: 12)) {
      c.tick(const Duration(milliseconds: 16));
      elapsed += const Duration(milliseconds: 16);
      maxDelta = (c.squash - resting).abs() > maxDelta
          ? (c.squash - resting).abs()
          : maxDelta;
    }
    expect(maxDelta, greaterThan(0.0005));
  });

  test('notifyListeners does not fire on tick once settled', () {
    final c = EmojiController(random: Random(1));
    // Let the constructor pose settle.
    tickFor(c, const Duration(milliseconds: 500));
    int notifications = 0;
    c.addListener(() => notifications++);
    // Well short of the 9 s cycler and the 5 s breath.
    tickFor(c, const Duration(milliseconds: 2000));
    expect(notifications, 0);
  });
}
