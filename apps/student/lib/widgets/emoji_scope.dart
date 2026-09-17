import 'package:flutter/material.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

/// Holds the one [EmojiController] shared across every surface, so a state set
/// during a quiz (or, in Phase 8, a voice interaction) survives navigation.
///
/// It watches [MediaQuery.disableAnimations]: when reduce-motion is toggled the
/// controller is rebuilt with the new setting, since `reduceMotion` is fixed at
/// construction.
class EmojiScope extends StatefulWidget {
  const EmojiScope({super.key, required this.child});

  final Widget child;

  static EmojiController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_EmojiScopeMarker>()
        ?.controller;
  }

  static EmojiController of(BuildContext context) {
    final EmojiController? controller = maybeOf(context);
    assert(controller != null, 'No EmojiScope found in context');
    return controller!;
  }

  @override
  State<EmojiScope> createState() => _EmojiScopeState();
}

class _EmojiScopeState extends State<EmojiScope> {
  EmojiController? _controller;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_controller == null || reduceMotion != _reduceMotion) {
      _controller?.dispose();
      _reduceMotion = reduceMotion;
      _controller = EmojiController(reduceMotion: reduceMotion);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EmojiScopeMarker(
      controller: _controller!,
      child: widget.child,
    );
  }
}

class _EmojiScopeMarker extends InheritedWidget {
  const _EmojiScopeMarker({required this.controller, required super.child});

  final EmojiController controller;

  @override
  bool updateShouldNotify(_EmojiScopeMarker old) =>
      old.controller != controller;
}
