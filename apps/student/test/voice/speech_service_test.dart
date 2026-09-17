import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_student/voice/fake_speech_service.dart';
import 'package:syncedu_student/voice/speech_service.dart';

void main() {
  test('a denied permission surfaces as a refusal, not a crash', () async {
    final FakeSpeechService speech =
        FakeSpeechService(permissionGranted: false);
    expect(await speech.requestPermission(), isFalse);
    await speech.dispose();
  });

  test('listening emits partial results then a final one', () async {
    final FakeSpeechService speech =
        FakeSpeechService(transcript: <String>['he', 'hel', 'hello there']);

    final List<String> heard = await speech.listen().toList();

    expect(heard, <String>['he', 'hel', 'hello there']);
    await speech.dispose();
  });

  test('stopListening ends the stream', () async {
    final FakeSpeechService speech =
        FakeSpeechService(transcript: <String>['one', 'two', 'three']);

    final Stream<String> stream = speech.listen();
    final Future<List<String>> collected = stream.toList();
    await speech.stopListening();

    // Completing at all is the assertion: an unclosed stream would hang here.
    await collected;
    await speech.dispose();
  });

  test('speaking reports the speaking status then returns to idle', () async {
    final FakeSpeechService speech = FakeSpeechService();
    final Future<List<SpeechStatus>> statuses =
        speech.status.take(2).toList();

    await speech.speak('well done');

    expect(await statuses, <SpeechStatus>[
      SpeechStatus.speaking,
      SpeechStatus.idle,
    ]);
    expect(speech.spoken, <String>['well done']);
    await speech.dispose();
  });

  test('a second listen call while listening is ignored rather than stacking',
      () async {
    final FakeSpeechService speech =
        FakeSpeechService(transcript: <String>['hello']);

    speech.listen();
    final Stream<String> second = speech.listen();

    // The second call did not open a fresh recogniser: it handed back the
    // in-flight stream, which still transcribes exactly once.
    expect(await second.toList(), <String>['hello']);
    expect(speech.listenCallCount, 2);
    await speech.dispose();
  });
}
