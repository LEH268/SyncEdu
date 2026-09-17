import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

void main() {
  test('every state has a behaviour entry', () {
    for (final EmojiState state in EmojiState.values) {
      expect(kStateBehaviour[state], isNotNull, reason: '$state');
    }
  });

  test('every state has an eye pair with matching vertex counts', () {
    for (final EmojiState state in EmojiState.values) {
      final EyePair? pair = kEyeShapes[state];
      expect(pair, isNotNull, reason: '$state');
      expect(pair!.left.length, pair.right.length,
          reason: '$state: interpolation needs equal vertex counts');
    }
  });

  test('every eye polygon has the same vertex count as every other', () {
    final int expected = kEyeShapes[EmojiState.idle]!.left.length;
    for (final MapEntry<EmojiState, EyePair> entry in kEyeShapes.entries) {
      expect(entry.value.left.length, expected, reason: '${entry.key}');
      expect(entry.value.right.length, expected, reason: '${entry.key}');
    }
  });

  test('eye vertices lie within the unit square', () {
    for (final MapEntry<EmojiState, EyePair> entry in kEyeShapes.entries) {
      for (final Offset point
          in <Offset>[...entry.value.left, ...entry.value.right]) {
        expect(point.dx, inInclusiveRange(-1.0, 1.0), reason: '${entry.key}');
        expect(point.dy, inInclusiveRange(-1.0, 1.0), reason: '${entry.key}');
      }
    }
  });

  test('reaction states revert to idle; lifecycle states do not', () {
    const Set<EmojiState> reactions = <EmojiState>{
      EmojiState.happy,
      EmojiState.confused,
      EmojiState.celebrate,
      EmojiState.sad,
    };
    for (final EmojiState state in EmojiState.values) {
      expect(
        kStateBehaviour[state]!.revertsToIdle,
        reactions.contains(state),
        reason: '$state',
      );
    }
  });

  test('hold ranges match the spec table', () {
    expect(kStateBehaviour[EmojiState.happy]!.minHold,
        const Duration(milliseconds: 2500));
    expect(kStateBehaviour[EmojiState.happy]!.maxHold,
        const Duration(milliseconds: 4500));
    expect(kStateBehaviour[EmojiState.celebrate]!.minHold,
        const Duration(milliseconds: 1400));
    expect(kStateBehaviour[EmojiState.celebrate]!.maxHold,
        const Duration(milliseconds: 2600));
    expect(kStateBehaviour[EmojiState.sad]!.minHold, const Duration(seconds: 4));
    expect(kStateBehaviour[EmojiState.sad]!.maxHold, const Duration(seconds: 7));
    expect(kStateBehaviour[EmojiState.confused]!.minHold,
        const Duration(milliseconds: 2200));
    expect(kStateBehaviour[EmojiState.confused]!.maxHold,
        const Duration(milliseconds: 3800));
  });

  test('states with no hold are the ones driven by an external condition', () {
    for (final EmojiState state in <EmojiState>[
      EmojiState.listening,
      EmojiState.thinking,
      EmojiState.speaking,
      EmojiState.loading,
      EmojiState.idle,
      EmojiState.sleeping,
    ]) {
      expect(kStateBehaviour[state]!.minHold, isNull, reason: '$state');
    }
  });

  test('positive states are warm and negative states are cool or desaturated',
      () {
    HSLColor hsl(EmojiState s) => HSLColor.fromColor(kStateBehaviour[s]!.colour);

    expect(hsl(EmojiState.celebrate).saturation,
        greaterThan(hsl(EmojiState.sad).saturation));
    expect(hsl(EmojiState.sleeping).lightness,
        lessThan(hsl(EmojiState.idle).lightness));
  });

  test('every pose has fourteen radial offsets', () {
    for (final EmojiState state in EmojiState.values) {
      expect(poseFor(state).radialOffsets, hasLength(14), reason: '$state');
    }
  });

  test('squash and stretch preserve volume', () {
    for (final EmojiState state in EmojiState.values) {
      final double squash = poseFor(state).squash;
      expect(squash * (1 / squash), closeTo(1.0, 1e-9));
      expect(squash, inInclusiveRange(0.7, 1.35), reason: '$state');
    }
  });
}
