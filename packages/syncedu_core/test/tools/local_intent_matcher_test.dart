import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

void main() {
  group('start_quiz', () {
    test('parses the canonical phrasing', () {
      final ToolCall? call =
          matchLocalIntent('quiz me on chapters 1 and 2, ten questions');
      expect(call, isA<StartQuiz>());
      expect((call! as StartQuiz).chapterOrdinals, <int>[1, 2]);
      expect((call as StartQuiz).questionCount, 10);
    });

    test('parses digits and words for the count', () {
      for (final String phrase in <String>[
        'quiz me on chapter 3 with 15 questions',
        'quiz me on chapter 3, fifteen questions',
      ]) {
        expect((matchLocalIntent(phrase)! as StartQuiz).questionCount, 15);
      }
    });

    test('parses a chapter range', () {
      expect(
        (matchLocalIntent('test me on chapters 1 to 3')! as StartQuiz)
            .chapterOrdinals,
        <int>[1, 2, 3],
      );
    });

    test('accepts several verbs students actually use', () {
      for (final String verb in <String>[
        'quiz me',
        'test me',
        'give me a quiz',
      ]) {
        expect(matchLocalIntent('$verb on chapter 1'), isA<StartQuiz>());
      }
    });

    test('defaults the count when unstated', () {
      expect(
        (matchLocalIntent('quiz me on chapter 1')! as StartQuiz).questionCount,
        10,
      );
    });

    test('is case and punctuation insensitive', () {
      final ToolCall? call =
          matchLocalIntent('QUIZ ME ON CHAPTER 2!!!  (5 questions)');
      expect((call! as StartQuiz).chapterOrdinals, <int>[2]);
      expect((call as StartQuiz).questionCount, 5);
    });
  });

  group('the other five', () {
    test('flashcards', () => expect(
        matchLocalIntent('flashcards for chapter 2'), isA<OpenFlashcards>()));
    test('story', () => expect(
        matchLocalIntent('tell me a story about chapter 4'), isA<OpenStory>()));
    test('notes', () => expect(
        matchLocalIntent('make me notes on chapter 1'), isA<GenerateNotes>()));
    test('progress', () =>
        expect(matchLocalIntent('how am I doing'), isA<ShowProgress>()));
    test('pick chapter', () => expect(
        matchLocalIntent('let me choose a chapter'), isA<PickChapter>()));
  });

  group('refusal', () {
    test('returns null for anything it cannot parse', () {
      expect(matchLocalIntent('why is the sky blue'), isNull);
      expect(matchLocalIntent('explain photosynthesis to me slowly'), isNull);
      expect(matchLocalIntent(''), isNull);
    });

    test('does not match a quiz request with no chapter at all', () {
      expect(matchLocalIntent('quiz me'), isNull);
      expect(matchLocalIntent('give me a quiz'), isNull);
    });
  });
}
