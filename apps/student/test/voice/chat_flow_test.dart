import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';
import 'package:syncedu_student/quiz/quiz_controller.dart';
import 'package:syncedu_student/quiz/quiz_runner.dart';
import 'package:syncedu_student/voice/chat_controller.dart';
import 'package:syncedu_student/voice/chat_sheet.dart';
import 'package:syncedu_student/voice/fake_speech_service.dart';

Future<void> _drain(WidgetTester tester) async {
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

PoolQuestion _q() => const PoolQuestion(
      id: 'q1',
      chapterId: 'ch1',
      microSkillId: 's1',
      difficulty: 2,
      stem: 'Stem',
      options: <String>['a', 'b', 'c', 'd'],
      correctIndex: 0,
      provenance: 'pool',
    );

class _Harness {
  _Harness({
    required this.online,
    this.sender,
    bool permission = true,
  }) : speech = FakeSpeechService(permissionGranted: permission) {
    controller = ChatController(
      speech: speech,
      emoji: emoji,
      isOnline: () async => online,
      sendToChat: sender ?? (_) async => throw StateError('no sender'),
      onToolCall: (ToolCall call) {
        calls.add(call);
        router.go(routeFor(call));
      },
    );
    router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: ChatSheet(
              controller: controller,
              chapterOrdinals: const <int>[1, 2, 3],
            ),
          ),
        ),
        GoRoute(
          path: '/quiz/start',
          builder: (_, _) => Scaffold(
            body: QuizRunner(
              controller: QuizController.forTesting(
                questions: <PoolQuestion>[_q()],
              ),
            ),
          ),
        ),
      ],
    );
  }

  final bool online;
  final ChatSender? sender;
  final FakeSpeechService speech;
  final EmojiController emoji = EmojiController();
  final List<ToolCall> calls = <ToolCall>[];
  late final ChatController controller;
  late final GoRouter router;

  Widget get app => MaterialApp.router(routerConfig: router);

  void dispose() {
    controller.dispose();
    emoji.dispose();
    speech.dispose();
  }
}

void main() {
  testWidgets('the microphone button drives the listening state',
      (WidgetTester tester) async {
    final _Harness h = _Harness(online: false);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    await tester.tap(find.byKey(const Key('chat-mic')));
    await tester.pump();

    expect(h.emoji.state, EmojiState.listening);
    expect(h.controller.listening, isTrue);

    await h.speech.stopListening();
    await _drain(tester);
  });

  testWidgets('a request in flight drives thinking, not loading',
      (WidgetTester tester) async {
    final Completer<ChatResponse> pending = Completer<ChatResponse>();
    final _Harness h = _Harness(online: true, sender: (_) => pending.future);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    unawaited(h.controller.submitText('anything'));
    await tester.pump();

    expect(h.emoji.state, EmojiState.thinking);
    expect(h.emoji.state, isNot(EmojiState.loading));

    pending.complete(const ChatResponse(reply: 'ok'));
    await _drain(tester);
  });

  testWidgets('synthesis drives speaking', (WidgetTester tester) async {
    final _Harness h = _Harness(
      online: true,
      sender: (_) async => const ChatResponse(reply: 'here is an answer'),
    );
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    final List<EmojiState> states = <EmojiState>[];
    void record() => states.add(h.emoji.state);
    h.emoji.addListener(record);

    unawaited(h.controller.submitText('tell me something'));
    await _drain(tester);
    h.emoji.removeListener(record);

    expect(states, contains(EmojiState.speaking));
    expect(h.speech.spoken, <String>['here is an answer']);
  });

  testWidgets('a returned tool call navigates with its arguments',
      (WidgetTester tester) async {
    final _Harness h = _Harness(
      online: true,
      sender: (_) async => const ChatResponse(
        reply: 'starting',
        toolCall: StartQuiz(chapterOrdinals: <int>[1, 2], questionCount: 8),
      ),
    );
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    unawaited(h.controller.submitText('quiz me'));
    await _drain(tester);

    expect(h.calls.single,
        const StartQuiz(chapterOrdinals: <int>[1, 2], questionCount: 8));
    expect(find.byType(QuizRunner), findsOneWidget);
  });

  testWidgets('offline, a parsable utterance still navigates',
      (WidgetTester tester) async {
    final _Harness h = _Harness(online: false);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    unawaited(h.controller.submitText('quiz me on chapter 1'));
    await _drain(tester);

    expect((h.calls.single as StartQuiz).chapterOrdinals, <int>[1]);
    expect(find.byType(QuizRunner), findsOneWidget);
  });

  testWidgets('offline, an unparsable utterance says a connection is needed',
      (WidgetTester tester) async {
    final _Harness h = _Harness(online: false);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    unawaited(h.controller.submitText('why is the sky blue'));
    await _drain(tester);

    expect(find.textContaining('connection'), findsOneWidget);
    expect(h.calls, isEmpty);
    expect(find.byType(QuizRunner), findsNothing);
  });

  testWidgets('an unparsable input drives the confused state',
      (WidgetTester tester) async {
    final _Harness h = _Harness(online: false);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    unawaited(h.controller.submitText('explain photosynthesis to me slowly'));
    await _drain(tester);

    expect(h.emoji.state, EmojiState.confused);
  });

  testWidgets('typing works when the microphone is denied',
      (WidgetTester tester) async {
    final _Harness h = _Harness(online: false, permission: false);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    await tester.enterText(
        find.byKey(const Key('chat-input')), 'quiz me on chapter 2');
    await tester.tap(find.byKey(const Key('chat-send')));
    await _drain(tester);

    expect((h.calls.single as StartQuiz).chapterOrdinals, <int>[2]);
  });

  testWidgets('a denied microphone is reported, not crashed into',
      (WidgetTester tester) async {
    final _Harness h = _Harness(online: false, permission: false);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    await tester.tap(find.byKey(const Key('chat-mic')));
    await _drain(tester);

    expect(find.textContaining('type instead'), findsOneWidget);
  });

  testWidgets('every tool has a visible button on the same screen',
      (WidgetTester tester) async {
    final _Harness h = _Harness(online: false);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    expect(find.byKey(const Key('action-quiz')), findsOneWidget);
    expect(find.byKey(const Key('action-flashcards')), findsOneWidget);
    expect(find.byKey(const Key('action-story')), findsOneWidget);
    expect(find.byKey(const Key('action-notes')), findsOneWidget);
    expect(find.byKey(const Key('action-progress')), findsOneWidget);
    expect(find.byKey(const Key('action-pick-chapter')), findsOneWidget);
  });

  testWidgets('a failed request falls back to the offline matcher',
      (WidgetTester tester) async {
    final _Harness h = _Harness(
      online: true,
      sender: (_) async => throw Exception('network down'),
    );
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    unawaited(h.controller.submitText('quiz me on chapter 3'));
    await _drain(tester);

    expect((h.calls.single as StartQuiz).chapterOrdinals, <int>[3]);
  });

  testWidgets('a failed request leaves the buttons working',
      (WidgetTester tester) async {
    final _Harness h = _Harness(
      online: true,
      sender: (_) async => throw Exception('network down'),
    );
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);

    // Unparsable, so the turn ends on the sheet with an honest message rather
    // than navigating away.
    unawaited(h.controller.submitText('what is the meaning of life'));
    await _drain(tester);
    expect(find.textContaining('connection'), findsOneWidget);

    await tester.tap(find.byKey(const Key('action-progress')));
    await tester.pump();
    expect(h.calls.single, isA<ShowProgress>());
  });
}
