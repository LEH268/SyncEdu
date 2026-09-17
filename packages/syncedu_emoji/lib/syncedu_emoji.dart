/// The SyncEdu AI Emoji: an original spring-driven character with ten states.
///
/// This package takes a state enum and paints. It has zero application
/// dependencies -- no Supabase, no drift, no domain models. Consumers bind to
/// [EmojiState] and [EmojiController]; the painter behind them can be rewritten
/// freely without touching a single call site.
library;

// Re-exported so timing-sensitive tests and consumers can seed the controller
// deterministically without a separate `dart:math` import.
export 'dart:math' show Random;

export 'src/ai_emoji.dart';
export 'src/emoji_controller.dart';
export 'src/math/spring.dart';
export 'src/model/emoji_state.dart';
export 'src/model/eye_shapes.dart';
export 'src/model/pose.dart';
export 'src/render/body_path.dart';
export 'src/render/emoji_painter.dart';
