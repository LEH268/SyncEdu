import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// What the character reports at any moment during a turn. The chat controller
/// maps these onto emoji states -- `listening`, `thinking`, `speaking` -- so
/// the character *is* the progress indicator (spec 8.3).
enum SpeechStatus { idle, listening, processing, speaking }

/// On-device speech recognition and synthesis, behind an interface so widget
/// tests bind to a fake rather than the platform plugins.
///
/// Speech is captured on device, handed on as text, and returned as text.
/// There is no streaming and no bidirectional audio (spec §11).
abstract interface class SpeechService {
  /// Asks for the microphone permission. A denial is a `false`, never a throw.
  Future<bool> requestPermission();

  /// Opens the microphone and emits transcripts -- partial results as they
  /// firm up, then one final result -- closing when speech ends or
  /// [stopListening] is called. A second call while already listening is
  /// ignored rather than stacking a second recogniser.
  Stream<String> listen();

  Future<void> stopListening();

  Future<void> speak(String text);

  Future<void> stopSpeaking();

  Stream<SpeechStatus> get status;
}

class DeviceSpeechService implements SpeechService {
  DeviceSpeechService({stt.SpeechToText? recognizer, FlutterTts? synthesizer})
      : _recognizer = recognizer ?? stt.SpeechToText(),
        _tts = synthesizer ?? FlutterTts();

  final stt.SpeechToText _recognizer;
  final FlutterTts _tts;
  final StreamController<SpeechStatus> _status =
      StreamController<SpeechStatus>.broadcast();

  StreamController<String>? _transcript;
  bool _recognizerReady = false;

  @override
  Stream<SpeechStatus> get status => _status.stream;

  @override
  Future<bool> requestPermission() async {
    final PermissionStatus result = await Permission.microphone.request();
    return result.isGranted;
  }

  @override
  Stream<String> listen() {
    // Already listening -- hand back the live stream rather than opening a
    // second recogniser on top of the first.
    final StreamController<String>? active = _transcript;
    if (active != null && !active.isClosed) return active.stream;

    final StreamController<String> controller = StreamController<String>();
    _transcript = controller;
    unawaited(_startListening(controller));
    return controller.stream;
  }

  Future<void> _startListening(StreamController<String> controller) async {
    try {
      _recognizerReady = _recognizerReady ||
          await _recognizer.initialize(
            onStatus: (String s) {
              if (s == 'done' || s == 'notListening') {
                _status.add(SpeechStatus.processing);
                if (!controller.isClosed) controller.close();
              }
            },
            onError: (Object _) {
              if (!controller.isClosed) controller.close();
              _status.add(SpeechStatus.idle);
            },
          );
      if (!_recognizerReady) {
        await controller.close();
        _status.add(SpeechStatus.idle);
        return;
      }

      _status.add(SpeechStatus.listening);
      await _recognizer.listen(
        onResult: (dynamic result) {
          if (controller.isClosed) return;
          controller.add(result.recognizedWords as String);
        },
      );
    } on Object {
      if (!controller.isClosed) await controller.close();
      _status.add(SpeechStatus.idle);
    }
  }

  @override
  Future<void> stopListening() async {
    await _recognizer.stop();
    final StreamController<String>? controller = _transcript;
    _transcript = null;
    if (controller != null && !controller.isClosed) await controller.close();
    _status.add(SpeechStatus.idle);
  }

  @override
  Future<void> speak(String text) async {
    _status.add(SpeechStatus.speaking);
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
    _status.add(SpeechStatus.idle);
  }

  @override
  Future<void> stopSpeaking() async {
    await _tts.stop();
    _status.add(SpeechStatus.idle);
  }

  Future<void> dispose() async {
    await _status.close();
  }
}
