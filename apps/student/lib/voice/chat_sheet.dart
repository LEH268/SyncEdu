import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

import 'chat_controller.dart';

/// The conversation surface: the transcript, a mic button, a text field, and a
/// button for every one of the six tools.
///
/// The buttons are the point of spec §8.3 -- "conversation is an accelerator,
/// never the only path". A student whose microphone fails, or who is offline
/// and off-script, loses nothing: every action is one tap away here.
class ChatSheet extends StatefulWidget {
  const ChatSheet({
    super.key,
    required this.controller,
    required this.chapterOrdinals,
  });

  final ChatController controller;

  /// The chapter ordinals that exist, used by the quick-action buttons.
  final List<int> chapterOrdinals;

  @override
  State<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<ChatSheet> {
  final TextEditingController _field = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _field.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  void _send() {
    final String text = _field.text;
    if (text.trim().isEmpty) return;
    _field.clear();
    widget.controller.submitText(text);
  }

  int? get _firstChapter =>
      widget.chapterOrdinals.isEmpty ? null : widget.chapterOrdinals.first;

  @override
  Widget build(BuildContext context) {
    final ChatController c = widget.controller;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  for (final ChatTurn turn in c.turns)
                    Align(
                      alignment: turn.role == ChatRole.student
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(turn.text),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _ActionBar(
              chapterOrdinals: widget.chapterOrdinals,
              firstChapter: _firstChapter,
              onTool: c.invokeTool,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                IconButton(
                  key: const Key('chat-mic'),
                  icon: Icon(c.listening ? Icons.mic : Icons.mic_none),
                  color: c.listening ? Theme.of(context).colorScheme.primary : null,
                  onPressed: c.busy ? null : c.startListening,
                ),
                Expanded(
                  child: TextField(
                    key: const Key('chat-input'),
                    controller: _field,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Ask, or tap an action above',
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('chat-send'),
                  icon: const Icon(Icons.send),
                  onPressed: c.busy ? null : _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.chapterOrdinals,
    required this.firstChapter,
    required this.onTool,
  });

  final List<int> chapterOrdinals;
  final int? firstChapter;
  final void Function(ToolCall call) onTool;

  @override
  Widget build(BuildContext context) {
    final int chapter = firstChapter ?? 1;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: <Widget>[
        ActionChip(
          key: const Key('action-quiz'),
          avatar: const Icon(Icons.quiz, size: 18),
          label: const Text('Quiz me'),
          onPressed: () => onTool(StartQuiz(
            chapterOrdinals: chapterOrdinals.isEmpty
                ? <int>[chapter]
                : chapterOrdinals,
          )),
        ),
        ActionChip(
          key: const Key('action-flashcards'),
          avatar: const Icon(Icons.style, size: 18),
          label: const Text('Flashcards'),
          onPressed: () => onTool(OpenFlashcards(chapterOrdinal: chapter)),
        ),
        ActionChip(
          key: const Key('action-story'),
          avatar: const Icon(Icons.auto_stories, size: 18),
          label: const Text('Story'),
          onPressed: () => onTool(OpenStory(chapterOrdinal: chapter)),
        ),
        ActionChip(
          key: const Key('action-notes'),
          avatar: const Icon(Icons.notes, size: 18),
          label: const Text('Notes'),
          onPressed: () => onTool(const GenerateNotes()),
        ),
        ActionChip(
          key: const Key('action-progress'),
          avatar: const Icon(Icons.insights, size: 18),
          label: const Text('My progress'),
          onPressed: () => onTool(const ShowProgress()),
        ),
        ActionChip(
          key: const Key('action-pick-chapter'),
          avatar: const Icon(Icons.list, size: 18),
          label: const Text('Pick a chapter'),
          onPressed: () => onTool(const PickChapter()),
        ),
      ],
    );
  }
}
