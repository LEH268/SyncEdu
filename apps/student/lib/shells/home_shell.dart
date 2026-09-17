import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

import '../voice/chat_launcher.dart';
import '../voice/chat_service.dart';
import '../widgets/emoji_scope.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.gateway, this.chatService});

  final AuthGateway gateway;
  final ChatService? chatService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncEdu'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => gateway.signOut(),
          ),
        ],
      ),
      floatingActionButton: ChatLauncher(chatService: chatService),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  final EmojiController? emoji = EmojiScope.maybeOf(context);
                  if (emoji == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: AiEmoji(controller: emoji, size: 200),
                  );
                },
              ),
              const Text('Learn, practise, and track progress'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const Key('home-start-quiz'),
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
