import 'dart:async';

import 'speech_service.dart';

/// A scripted [SpeechService] for widget and flow tests -- no plugins, no
/// microphone, no wall-clock timers.
///
/// The plan places this under `syncedu_local/testing`, but a fake of an
/// app-defined interface cannot live in a package the app depends on, so it
/// sits beside the interface instead.
class FakeSpeechService implements SpeechService {
  FakeSpeechService({
    this.permissionGranted = true,
    List<String> transcript = const <String>[],
  }) : _transcript = List<String>.of(transcript);

  bool permissionGranted;
  List<String> _transcript;

  final StreamController<SpeechStatus> _status =
      StreamController<SpeechStatus>.broadcast();
  StreamController<String>? _active;

  int listenCallCount = 0;
  final List<String> spoken = <String>[];

  /// Sets what the next [listen] call will transcribe.
  void queue(List<String> results) => _transcript = List<String>.of(results);

  @override
  Stream<SpeechStatus> get status => _status.stream;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Stream<String> listen() {
    listenCallCount++;
    final StreamController<String>? active = _active;
    if (active != null && !active.isClosed) {
      // Already listening: ignored, not stacked.
      return active.stream;
    }

    final StreamController<String> controller = StreamController<String>();
    _active = controller;
    _status.add(SpeechStatus.listening);

    if (_transcript.isEmpty) {
      // Nothing scripted: hold `listening` open until stopListening, the way a
      // real recogniser waits for speech.
      return controller.stream;
    }

    scheduleMicrotask(() async {
      for (final String result in _transcript) {
        if (_active != controller || controller.isClosed) return;
        controller.add(result);
      }
      if (_active != controller || controller.isClosed) return;
      _status.add(SpeechStatus.processing);
      await controller.close();
      if (_active == controller) _active = null;
    });

    return controller.stream;
  }

  @override
  Future<void> stopListening() async {
    final StreamController<String>? controller = _active;
    _active = null;
    if (controller != null && !controller.isClosed) await controller.close();
    _status.add(SpeechStatus.idle);
  }

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
    _status
      ..add(SpeechStatus.speaking)
      ..add(SpeechStatus.idle);
  }

  @override
  Future<void> stopSpeaking() async {
    _status.add(SpeechStatus.idle);
  }

  Future<void> dispose() async {
    await _active?.close();
    await _status.close();
  }
}
