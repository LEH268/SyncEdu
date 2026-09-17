import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';
import 'package:syncedu_local/syncedu_local.dart';

import '../widgets/emoji_scope.dart';
import 'chat_controller.dart';
import 'chat_service.dart';
import 'chat_sheet.dart';
import 'speech_service.dart';

/// The one entry point to the conversation: a mic button on Home and Learn
/// that opens the [ChatSheet]. Absent when no [ChatService] is wired (widget
/// tests of the shells), so those keep working unchanged.
class ChatLauncher extends StatelessWidget {
  const ChatLauncher({super.key, required this.chatService});

  final ChatService? chatService;

  @override
  Widget build(BuildContext context) {
    final ChatService? service = chatService;
    if (service == null) return const SizedBox.shrink();
    return FloatingActionButton(
      key: const Key('open-chat'),
      tooltip: 'Talk to your study companion',
      onPressed: () => _open(context, service),
      child: const Icon(Icons.mic),
    );
  }

  Future<void> _open(BuildContext context, ChatService service) async {
    final EmojiController emoji = EmojiScope.of(context);
    final List<int> ordinals = await service.chapterOrdinals();
    if (!context.mounted) return;

    final ChatController controller = ChatController(
      speech: DeviceSpeechService(),
      emoji: emoji,
      isOnline: () => connectivityStream().first,
      sendToChat: service.sendToChat,
      onToolCall: (ToolCall call) {
        Navigator.of(context).pop();
        context.go(routeFor(call));
      },
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ChatSheet(controller: controller, chapterOrdinals: ordinals),
      ),
    );
    controller.dispose();
  }
}
