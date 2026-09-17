import 'package:flutter/painting.dart';

/// The ten states the character can be in. Six are reactions or lifecycle
/// markers driven from the app; `idle` and `sleeping` are the resting states.
enum EmojiState {
  idle,
  listening,
  thinking,
  speaking,
  loading,
  happy,
  confused,
  celebrate,
  sad,
  sleeping,
}

/// The behaviour attached to a state: how long it holds, whether it falls back
/// to `idle` on its own, the fill colour it lerps towards, and the
/// squash-and-stretch impulse fired on entry.
class StateBehaviour {
  const StateBehaviour({
    required this.minHold,
    required this.maxHold,
    required this.revertsToIdle,
    required this.colour,
    required this.stretchImpulse,
  });

  /// Null for states that last exactly as long as the external condition they
  /// represent -- a microphone being open, a request in flight, synthesis
  /// playing -- and for the two resting states.
  final Duration? minHold;
  final Duration? maxHold;

  /// True only for the four reactions. A lifecycle state ends when its
  /// condition ends, not on a timer.
  final bool revertsToIdle;

  final Color colour;

  /// Fired into the squash spring on entry. Positive stretches (a pop of
  /// delight), negative squashes (a slump).
  final double stretchImpulse;
}

/// Resting fill: a warm indigo, chosen so the character never competes with
/// the red/amber/green the heatmap owns (spec 8.4).
const Color _indigo = Color(0xFF5B4BE8);

final Map<EmojiState, StateBehaviour> kStateBehaviour =
    <EmojiState, StateBehaviour>{
  EmojiState.idle: const StateBehaviour(
    minHold: null,
    maxHold: null,
    revertsToIdle: false,
    colour: _indigo,
    stretchImpulse: 0.0,
  ),
  EmojiState.listening: const StateBehaviour(
    minHold: null,
    maxHold: null,
    revertsToIdle: false,
    colour: Color(0xFF7E70FF), // brightened
    stretchImpulse: 0.4,
  ),
  EmojiState.thinking: const StateBehaviour(
    minHold: null,
    maxHold: null,
    revertsToIdle: false,
    colour: _indigo,
    stretchImpulse: 0.0,
  ),
  EmojiState.speaking: const StateBehaviour(
    minHold: null,
    maxHold: null,
    revertsToIdle: false,
    colour: _indigo,
    stretchImpulse: 0.2,
  ),
  EmojiState.loading: const StateBehaviour(
    minHold: null,
    maxHold: null,
    revertsToIdle: false,
    colour: Color(0xFF6B67A0), // desaturated
    stretchImpulse: 0.0,
  ),
  EmojiState.happy: const StateBehaviour(
    minHold: Duration(milliseconds: 2500),
    maxHold: Duration(milliseconds: 4500),
    revertsToIdle: true,
    colour: Color(0xFFF2795B), // warm coral
    stretchImpulse: 1.6,
  ),
  EmojiState.confused: const StateBehaviour(
    minHold: Duration(milliseconds: 2200),
    maxHold: Duration(milliseconds: 3800),
    revertsToIdle: true,
    colour: Color(0xFF7A8FA6), // cooled, desaturated
    stretchImpulse: -0.9,
  ),
  EmojiState.celebrate: const StateBehaviour(
    minHold: Duration(milliseconds: 1400),
    maxHold: Duration(milliseconds: 2600),
    revertsToIdle: true,
    colour: Color(0xFFF5A623), // amber
    stretchImpulse: 2.4,
  ),
  EmojiState.sad: const StateBehaviour(
    minHold: Duration(seconds: 4),
    maxHold: Duration(seconds: 7),
    revertsToIdle: true,
    colour: Color(0xFF6B7C93), // desaturated blue
    stretchImpulse: -1.4,
  ),
  EmojiState.sleeping: const StateBehaviour(
    minHold: null,
    maxHold: null,
    revertsToIdle: false,
    colour: Color(0xFF2E2A4A), // heavily dimmed
    stretchImpulse: 0.0,
  ),
};
