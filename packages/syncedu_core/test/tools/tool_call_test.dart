import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

void main() {
  group('toolCallFromJson', () {
    test('start_quiz parses chapters and count', () {
      final ToolCall? call = toolCallFromJson('start_quiz', <String, dynamic>{
        'chapter_ordinals': <int>[1, 2],
        'question_count': 12,
      });
      expect(call, isA<StartQuiz>());
      expect((call! as StartQuiz).chapterOrdinals, <int>[1, 2]);
      expect((call as StartQuiz).questionCount, 12);
    });

    test('start_quiz defaults to ten questions when none is given', () {
      final ToolCall? call = toolCallFromJson('start_quiz', <String, dynamic>{
        'chapter_ordinals': <int>[3],
      });
      expect((call! as StartQuiz).questionCount, 10);
    });

    test('a question count outside 5..20 is clamped rather than rejected', () {
      StartQuiz quiz(int count) => toolCallFromJson('start_quiz', <String, dynamic>{
            'chapter_ordinals': <int>[1],
            'question_count': count,
          })! as StartQuiz;
      expect(quiz(100).questionCount, 20);
      expect(quiz(1).questionCount, 5);
      expect(quiz(10).questionCount, 10);
    });

    test('an unknown tool name yields null rather than throwing', () {
      expect(toolCallFromJson('do_a_barrel_roll', const <String, dynamic>{}),
          isNull);
    });

    test('a missing required argument yields null', () {
      expect(toolCallFromJson('start_quiz', const <String, dynamic>{}), isNull);
      expect(toolCallFromJson('open_flashcards', const <String, dynamic>{}),
          isNull);
      expect(toolCallFromJson('open_story', const <String, dynamic>{}), isNull);
    });

    test('generate_notes accepts a missing chapter', () {
      final ToolCall? call =
          toolCallFromJson('generate_notes', const <String, dynamic>{});
      expect(call, isA<GenerateNotes>());
      expect((call! as GenerateNotes).chapterOrdinal, isNull);
    });

    test('show_progress and pick_chapter take no arguments', () {
      expect(toolCallFromJson('show_progress', const <String, dynamic>{}),
          isA<ShowProgress>());
      expect(toolCallFromJson('pick_chapter', const <String, dynamic>{}),
          isA<PickChapter>());
    });
  });

  group('routeFor', () {
    test('every ToolCall maps to a route', () {
      final List<ToolCall> all = <ToolCall>[
        const StartQuiz(chapterOrdinals: <int>[1]),
        const OpenFlashcards(chapterOrdinal: 2),
        const OpenStory(chapterOrdinal: 3),
        const GenerateNotes(),
        const GenerateNotes(chapterOrdinal: 1),
        const ShowProgress(),
        const PickChapter(),
      ];
      for (final ToolCall call in all) {
        expect(routeFor(call), startsWith('/'));
      }
    });

    test('routeFor encodes chapter ordinals and count as query parameters', () {
      final String route = routeFor(
        const StartQuiz(chapterOrdinals: <int>[1, 2], questionCount: 10),
      );
      expect(route, contains('chapters=1,2'));
      expect(route, contains('count=10'));
    });
  });

  test("the six tool names match the function's declarations exactly", () {
    expect(kToolNames, <String>{
      'start_quiz',
      'open_flashcards',
      'open_story',
      'generate_notes',
      'show_progress',
      'pick_chapter',
    });
  });
}
