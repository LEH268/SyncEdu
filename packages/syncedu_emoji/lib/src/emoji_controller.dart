import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'math/spring.dart';
import 'model/emoji_state.dart';
import 'model/eye_shapes.dart';
import 'model/pose.dart';

/// Owns the character's motion: fourteen body springs, a squash spring, an
/// eye-morph progress spring, a colour lerp, a hold timer and an idle cycler.
///
/// It does not own a [Ticker] -- the widget drives [tick] from one, and tests
/// drive it directly with synthetic durations. Every random choice is drawn
/// from an injectable [Random] so timing tests are deterministic.
class EmojiController extends ChangeNotifier {
  EmojiController({
    EmojiState initial = EmojiState.idle,
    Random? random,
    this.reduceMotion = false,
  })  : _random = random ?? Random(),
        _state = initial {
    final Pose pose = poseFor(initial);
    for (int i = 0; i < kBodyPointCount; i++) {
      _body[i]
        ..value = pose.radialOffsets[i]
        ..target = pose.radialOffsets[i];
    }
    _squash
      ..value = pose.squash
      ..target = pose.squash;
    final EyePair shape = kEyeShapes[initial]!;
    _eyeFromL = shape.left;
    _eyeFromR = shape.right;
    _eyeToL = shape.left;
    _eyeToR = shape.right;
    _morph
      ..value = 1.0
      ..target = 1.0;
    _colourFrom = kStateBehaviour[initial]!.colour;
    _colourTarget = _colourFrom;
    _colourT
      ..value = 1.0
      ..target = 1.0;
    _scheduleHold();
    _scheduleCycle();
  }

  /// With reduce-motion on, state changes snap to their target pose with
  /// colour but no spring travel (spec 8.4 -- matters for the ADHD and ASD
  /// labels the product carries through to presentation).
  final bool reduceMotion;
  final Random _random;

  final List<Spring> _body = List<Spring>.generate(
    kBodyPointCount,
    (_) => Spring(value: 0.0, stiffness: 15.0),
  );
  final Spring _squash = Spring(value: 1.0, stiffness: 12.0);
  final Spring _morph = Spring(value: 1.0, stiffness: 18.0);
  final Spring _colourT = Spring(value: 1.0, stiffness: 12.0);

  EmojiState _state;
  EmojiState get state => _state;

  List<Offset> _eyeFromL = const <Offset>[];
  List<Offset> _eyeFromR = const <Offset>[];
  List<Offset> _eyeToL = const <Offset>[];
  List<Offset> _eyeToR = const <Offset>[];
  Color _colourFrom = const Color(0xFF5B4BE8);
  Color _colourTarget = const Color(0xFF5B4BE8);

  // Revert timer for the four reactions.
  Duration? _holdLimit;
  Duration _held = Duration.zero;

  // Idle cycler: flash another expression every 9-16 s, then return.
  static const Duration _flashDuration = Duration(milliseconds: 1400);
  static const List<EmojiState> _flashPalette = <EmojiState>[
    EmojiState.happy,
    EmojiState.celebrate,
    EmojiState.confused,
    EmojiState.listening,
  ];
  Duration _cycleAt = Duration.zero;
  Duration _sinceCycle = Duration.zero;
  bool _inCycleFlash = false;
  Duration _flashElapsed = Duration.zero;

  // Breathing: a small periodic impulse rather than a continuous target
  // oscillation, so between breaths the springs settle and [tick] can early
  // out instead of rebuilding every frame on a cheap phone.
  Duration _sinceBreath = Duration.zero;

  List<double> get bodyOffsets =>
      <double>[for (final Spring s in _body) s.value];

  double get squash => _squash.value;

  Color get colour =>
      Color.lerp(_colourFrom, _colourTarget, _colourT.value.clamp(0.0, 1.0))!;

  EyePair get eyes {
    final double t = _morph.value.clamp(0.0, 1.0);
    return EyePair(
      left: _lerpPoly(_eyeFromL, _eyeToL, t),
      right: _lerpPoly(_eyeFromR, _eyeToR, t),
    );
  }

  /// Change state now. A no-op if already in [next] and not mid-flash.
  void setState(EmojiState next) {
    if (next == _state && !_inCycleFlash) return;
    _transitionTo(next);
  }

  /// Advance every spring and timer by [elapsed]. Only notifies listeners when
  /// something actually moved.
  void tick(Duration elapsed) {
    final double dt = elapsed.inMicroseconds / 1e6;
    if (dt <= 0) return;
    bool moved = false;

    // Revert a held reaction once its hold has elapsed.
    if (_holdLimit != null) {
      _held += elapsed;
      if (_held >= _holdLimit!) {
        _transitionTo(EmojiState.idle);
        return;
      }
    }

    // Idle cycler. The flash-end check must run whatever `_state` currently
    // reads, since during a flash it is the flashed expression, not idle.
    if (!reduceMotion) {
      if (_inCycleFlash) {
        _flashElapsed += elapsed;
        if (_flashElapsed >= _flashDuration) {
          _endCycleFlash();
          moved = true;
        }
      } else if (_state == EmojiState.idle) {
        _sinceCycle += elapsed;
        if (_sinceCycle >= _cycleAt) {
          _beginCycleFlash();
          moved = true;
        }
      }
    }

    // Breathing, for the states that hold a pose long enough to need it.
    if (!reduceMotion &&
        (_state == EmojiState.idle ||
            _state == EmojiState.sleeping ||
            _state == EmojiState.speaking)) {
      _sinceBreath += elapsed;
      final Duration interval = _state == EmojiState.sleeping
          ? const Duration(milliseconds: 3300) // ~0.3 Hz
          : const Duration(milliseconds: 5000);
      if (_sinceBreath >= interval) {
        _sinceBreath = Duration.zero;
        _squash.impulse(_state == EmojiState.sleeping ? 0.012 : 0.02);
        moved = true;
      }
    }

    for (final Spring s in _body) {
      if (!s.isSettled) {
        s.step(dt);
        moved = true;
      }
    }
    if (!_squash.isSettled) {
      _squash.step(dt);
      moved = true;
    }
    if (!_morph.isSettled) {
      _morph.step(dt);
      moved = true;
    }
    if (!_colourT.isSettled) {
      _colourT.step(dt);
      moved = true;
    }

    if (moved) notifyListeners();
  }

  // --- internals -----------------------------------------------------------

  void _transitionTo(EmojiState next) {
    _setVisuals(next);
    _state = next;
    _inCycleFlash = false;
    _flashElapsed = Duration.zero;
    _sinceCycle = Duration.zero;
    _sinceBreath = Duration.zero;

    final StateBehaviour b = kStateBehaviour[next]!;
    if (b.revertsToIdle) {
      _held = Duration.zero;
      _holdLimit = _randomHold(b);
    } else {
      _holdLimit = null;
    }
    if (next == EmojiState.idle) _scheduleCycle();
    notifyListeners();
  }

  /// Retargets the springs and eye/colour lerps for [s] without touching the
  /// hold timer or [_state] -- shared by real transitions and cycle flashes.
  void _setVisuals(EmojiState s) {
    final EyePair current = eyes;
    _eyeFromL = current.left;
    _eyeFromR = current.right;
    final EyePair shape = kEyeShapes[s]!;
    _eyeToL = shape.left;
    _eyeToR = shape.right;

    _colourFrom = colour;
    _colourTarget = kStateBehaviour[s]!.colour;

    final Pose pose = poseFor(s);
    for (int i = 0; i < kBodyPointCount; i++) {
      _body[i].target = pose.radialOffsets[i];
    }
    _squash.target = pose.squash;

    if (reduceMotion) {
      _morph
        ..value = 1.0
        ..velocity = 0.0;
      _colourT
        ..value = 1.0
        ..velocity = 0.0;
      for (final Spring bs in _body) {
        bs
          ..value = bs.target
          ..velocity = 0.0;
      }
      _squash
        ..value = _squash.target
        ..velocity = 0.0;
    } else {
      _morph
        ..value = 0.0
        ..velocity = 0.0
        ..target = 1.0;
      _colourT
        ..value = 0.0
        ..velocity = 0.0
        ..target = 1.0;
      _squash.impulse(kStateBehaviour[s]!.stretchImpulse);
    }
  }

  void _beginCycleFlash() {
    final EmojiState flash =
        _flashPalette[_random.nextInt(_flashPalette.length)];
    _setVisuals(flash);
    _state = flash;
    _inCycleFlash = true;
    _flashElapsed = Duration.zero;
    notifyListeners();
  }

  void _endCycleFlash() {
    _setVisuals(EmojiState.idle);
    _state = EmojiState.idle;
    _inCycleFlash = false;
    _scheduleCycle();
    notifyListeners();
  }

  void _scheduleHold() {
    final StateBehaviour b = kStateBehaviour[_state]!;
    if (b.revertsToIdle) {
      _held = Duration.zero;
      _holdLimit = _randomHold(b);
    } else {
      _holdLimit = null;
    }
  }

  void _scheduleCycle() {
    // 9-16 s (spec 8.4).
    _sinceCycle = Duration.zero;
    _cycleAt = Duration(milliseconds: 9000 + _random.nextInt(7001));
  }

  Duration _randomHold(StateBehaviour b) {
    final int lo = b.minHold!.inMilliseconds;
    final int hi = b.maxHold!.inMilliseconds;
    return Duration(milliseconds: lo + _random.nextInt(hi - lo + 1));
  }

  static List<Offset> _lerpPoly(List<Offset> a, List<Offset> b, double t) {
    final int n = a.length < b.length ? a.length : b.length;
    return <Offset>[for (int i = 0; i < n; i++) Offset.lerp(a[i], b[i], t)!];
  }
}
