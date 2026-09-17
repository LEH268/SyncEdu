import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

import 'speech_service.dart';

enum ChatRole { student, companion }

@immutable
class ChatTurn {
  const ChatTurn(this.role, this.text);

  final ChatRole role;
  final String text;
}

/// What the `chat` Edge Function returns: a reply, and optionally the one tool
/// the model chose.
@immutable
class ChatResponse {
  const ChatResponse({required this.reply, this.toolCall});

  final String reply;
  final ToolCall? toolCall;
}

/// Calls the `chat` function. Throws on any transport or server failure, which
/// the controller treats as "offline for this turn".
typedef ChatSender = Future<ChatResponse> Function(String utterance);

const String kNeedsConnectionMessage =
    "I can't answer that offline yet -- I need a connection for questions "
    "like that. You can still ask me to start a quiz, open notes, flashcards "
    "or a story, or show your progress.";

const String kMicUnavailableMessage =
    'The microphone is unavailable. You can type instead -- everything works '
    'the same way.';

/// Owns one conversation: turn history, the emoji state through a turn, and
/// routing a resolved [ToolCall].
///
/// Online, a turn goes to [sendToChat]. If that throws, or the app is offline,
/// the turn falls to [matchLocalIntent]; anything it cannot parse gets an
/// honest "I need a connection" rather than a guess.
class ChatController extends ChangeNotifier {
  ChatController({
    required this._speech,
    required this._emoji,
    required this._isOnline,
    required this._sendToChat,
    required this._onToolCall,
  }) {
    _statusSub = _speech.status.listen(_onSpeechStatus);
  }

  final SpeechService _speech;
  final EmojiController _emoji;
  final Future<bool> Function() _isOnline;
  final ChatSender _sendToChat;
  final void Function(ToolCall call) _onToolCall;

  late final StreamSubscription<SpeechStatus> _statusSub;

  final List<ChatTurn> _turns = <ChatTurn>[];
  List<ChatTurn> get turns => List<ChatTurn>.unmodifiable(_turns);

  bool _disposed = false;

  bool _busy = false;
  bool get busy => _busy;

  bool _listening = false;
  bool get listening => _listening;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void _onSpeechStatus(SpeechStatus status) {
    if (_disposed) return;
    switch (status) {
      case SpeechStatus.listening:
        _emoji.setState(EmojiState.listening);
      case SpeechStatus.processing:
        _emoji.setState(EmojiState.thinking);
      case SpeechStatus.speaking:
        _emoji.setState(EmojiState.speaking);
      case SpeechStatus.idle:
        break;
    }
  }

  /// Opens the microphone, transcribes one utterance, and submits it. A denied
  /// permission is reported in the transcript, never thrown.
  Future<void> startListening() async {
    if (_busy || _listening) return;
    final bool granted = await _speech.requestPermission();
    if (!granted) {
      _addTurn(ChatRole.companion, kMicUnavailableMessage);
      _emoji.setState(EmojiState.confused);
      return;
    }

    _listening = true;
    _safeNotify();
    _emoji.setState(EmojiState.listening);

    String heard = '';
    try {
      await for (final String partial in _speech.listen()) {
        heard = partial;
      }
    } finally {
      _listening = false;
      _safeNotify();
    }

    final String utterance = heard.trim();
    if (utterance.isEmpty) {
      _emoji.setState(EmojiState.idle);
      return;
    }
    await submitText(utterance);
  }

  /// Handles one typed or transcribed turn.
  Future<void> submitText(String raw) async {
    final String utterance = raw.trim();
    if (utterance.isEmpty || _busy) return;

    _addTurn(ChatRole.student, utterance);
    _busy = true;
    _safeNotify();
    _emoji.setState(EmojiState.thinking);

    try {
      if (await _isOnline()) {
        try {
          final ChatResponse response = await _sendToChat(utterance);
          await _handleResponse(response);
          return;
        } on Object {
          // Fall through to the offline path: a failed request must never
          // leave the student with nothing.
        }
      }
      _handleOffline(utterance);
    } finally {
      _busy = false;
      _safeNotify();
    }
  }

  Future<void> _handleResponse(ChatResponse response) async {
    final ToolCall? call = response.toolCall;
    if (call != null) {
      if (response.reply.trim().isNotEmpty) {
        _addTurn(ChatRole.companion, response.reply.trim());
      }
      _emoji.setState(EmojiState.happy);
      _onToolCall(call);
      return;
    }

    final String reply = response.reply.trim();
    _addTurn(ChatRole.companion, reply);
    if (reply.isNotEmpty) {
      await _speech.speak(reply);
    }
    _emoji.setState(EmojiState.idle);
  }

  void _handleOffline(String utterance) {
    final ToolCall? call = matchLocalIntent(utterance);
    if (call != null) {
      _emoji.setState(EmojiState.happy);
      _onToolCall(call);
      return;
    }
    _addTurn(ChatRole.companion, kNeedsConnectionMessage);
    _emoji.setState(EmojiState.confused);
  }

  /// Runs a tool straight from its on-screen button -- no model call, no
  /// transcript entry. This is the path that guarantees conversation is an
  /// accelerator and never the only way through.
  void invokeTool(ToolCall call) {
    _emoji.setState(EmojiState.happy);
    _onToolCall(call);
  }

  void _addTurn(ChatRole role, String text) {
    _turns.add(ChatTurn(role, text));
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    _statusSub.cancel();
    super.dispose();
  }
}
