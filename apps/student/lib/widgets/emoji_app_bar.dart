import 'package:flutter/material.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

import 'emoji_scope.dart';

/// The app bar used during activities: the character shrinks into it at 28 dp
/// so per-question reactions stay visible while the student is answering
/// (spec 8.4).
///
/// Degrades to a plain [AppBar] when there is no [EmojiScope] above it, so
/// widget tests that pump a screen in isolation keep working.
class EmojiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmojiAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final EmojiController? controller = EmojiScope.maybeOf(context);
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: <Widget>[
          if (controller != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AiEmoji(controller: controller, size: 28),
            )
          else
            const SizedBox(width: 16),
          Expanded(child: Text(title)),
        ],
      ),
      actions: actions,
    );
  }
}
