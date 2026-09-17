import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

import '../voice/chat_launcher.dart';
import '../voice/chat_service.dart';
import '../widgets/emoji_scope.dart';

/// The Learn surface. Like Home, the character sits full-size here (spec 8.4);
/// it shrinks into the app bar once an activity starts.
class LearnShell extends StatelessWidget {
  const LearnShell({super.key, this.chatService});

  final ChatService? chatService;

  @override
  Widget build(BuildContext context) {
    final EmojiController? emoji = EmojiScope.maybeOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      floatingActionButton: ChatLauncher(chatService: chatService),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (emoji != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: AiEmoji(controller: emoji, size: 200),
                ),
              const Text('Pick a range and practise'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const Key('learn-start-quiz'),
                onPressed: () => context.go('/quiz/pick'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start a quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
