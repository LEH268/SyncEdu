import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'emoji_controller.dart';
import 'render/emoji_painter.dart';

/// The public widget. Give it an [EmojiController] and a square [size]; it owns
/// the [Ticker] that advances the controller and rebuilds only when the
/// controller reports motion.
///
/// The character honours [MediaQuery.disableAnimations]: with reduce-motion on,
/// the controller is rebuilt (once) with `reduceMotion: true` so states snap.
class AiEmoji extends StatefulWidget {
  const AiEmoji({
    super.key,
    required this.controller,
    required this.size,
  });

  final EmojiController controller;
  final double size;

  @override
  State<AiEmoji> createState() => _AiEmojiState();
}

class _AiEmojiState extends State<AiEmoji> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final Duration delta = elapsed - _last;
    _last = elapsed;
    if (delta > Duration.zero) widget.controller.tick(delta);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (BuildContext context, Widget? _) {
            return CustomPaint(
              size: Size.square(widget.size),
              painter: EmojiPainter(
                bodyOffsets: widget.controller.bodyOffsets,
                squash: widget.controller.squash,
                eyes: widget.controller.eyes,
                colour: widget.controller.colour,
              ),
            );
          },
        ),
      ),
    );
  }
}
