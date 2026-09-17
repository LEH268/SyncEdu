/// Offline parsing for the six conversational tool shapes.
///
/// Pure Dart, regular expressions over a normalised utterance plus a small
/// number-word table. It exists because full offline support is a headline
/// requirement (spec D9): a conversational app that goes mute without a signal
/// fails in exactly the conditions the Problem Statement names.
///
/// It deliberately refuses rather than guesses. Opening the wrong screen is
/// worse than admitting a connection is needed, so anything outside the six
/// declared shapes returns null and the caller says so plainly.
library;

import 'tool_call.dart';

const Map<String, int> _numberWords = <String, int>{
  'zero': 0,
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'seven': 7,
  'eight': 8,
  'nine': 9,
  'ten': 10,
  'eleven': 11,
  'twelve': 12,
  'thirteen': 13,
  'fourteen': 14,
  'fifteen': 15,
  'sixteen': 16,
  'seventeen': 17,
  'eighteen': 18,
  'nineteen': 19,
  'twenty': 20,
};

/// Verbs a student actually uses to ask for a quiz.
final RegExp _quizVerb = RegExp(
  r'\b(quiz|test|practi[sc]e|drill|exam)\b',
);

final RegExp _chapterRange = RegExp(
  r'chapters?\s+(\d+)\s*(?:to|through|thru|until|-|–|—)\s*(\d+)',
);
final RegExp _chapterList = RegExp(
  r'chapters?\s+([\d,\s]+(?:and\s+\d+)?[\d,\s]*)',
);
final RegExp _singleChapter = RegExp(r'chapters?\s+(\d+)');
final RegExp _questionCount = RegExp(r'(\d+)\s+questions?\b');

/// Parses [utterance] into one of the six [ToolCall] shapes, or null if it is
/// not one of them.
ToolCall? matchLocalIntent(String utterance) {
  final String text = _normalise(utterance);
  if (text.isEmpty) return null;

  // Quiz first: it is the only shape with a required argument (a chapter), so
  // a quiz verb with no chapter must fall through to a refusal rather than be
  // caught by a looser rule below.
  if (_quizVerb.hasMatch(text) || text.contains('give me a quiz')) {
    final List<int> chapters = _chaptersIn(text);
    if (chapters.isEmpty) return null;
    return StartQuiz(
      chapterOrdinals: chapters,
      questionCount: _countIn(text),
    );
  }

  if (text.contains('flashcard')) {
    final List<int> chapters = _chaptersIn(text);
    if (chapters.isEmpty) return null;
    return OpenFlashcards(chapterOrdinal: chapters.first);
  }

  if (text.contains('story')) {
    final List<int> chapters = _chaptersIn(text);
    if (chapters.isEmpty) return null;
    return OpenStory(chapterOrdinal: chapters.first);
  }

  if (text.contains('note')) {
    final List<int> chapters = _chaptersIn(text);
    return GenerateNotes(
      chapterOrdinal: chapters.isEmpty ? null : chapters.first,
    );
  }

  if (_looksLikeProgress(text)) return const ShowProgress();

  if (_looksLikePickChapter(text)) return const PickChapter();

  return null;
}

bool _looksLikeProgress(String text) {
  if (text.contains('my progress') || text.contains('how am i doing')) {
    return true;
  }
  if (text.contains('how am i getting on')) return true;
  if (text.contains('show') && text.contains('progress')) return true;
  return false;
}

bool _looksLikePickChapter(String text) {
  if (text.contains('new range') || text.contains('different range')) {
    return true;
  }
  final bool choosing = text.contains('choose') || text.contains('pick');
  return choosing && (text.contains('chapter') || text.contains('range'));
}

/// Lower-cases, turns number words into digits, drops punctuation and collapses
/// whitespace, so casing and punctuation cannot change the outcome.
String _normalise(String raw) {
  String text = raw.toLowerCase();
  _numberWords.forEach((String word, int value) {
    text = text.replaceAll(RegExp('\\b$word\\b'), '$value');
  });
  text = text.replaceAll(RegExp(r"[^\w\s\-–—]"), ' ');
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

List<int> _chaptersIn(String rawText) {
  // Strip any "<n> questions" phrase first so its number is never mistaken for
  // a chapter ordinal.
  final String text = rawText.replaceAll(_questionCount, ' ');
  final RegExpMatch? range = _chapterRange.firstMatch(text);
  if (range != null) {
    final int lo = int.parse(range.group(1)!);
    final int hi = int.parse(range.group(2)!);
    if (hi >= lo && hi - lo <= 50) {
      return <int>[for (int i = lo; i <= hi; i++) i];
    }
  }

  final RegExpMatch? list = _chapterList.firstMatch(text);
  if (list != null) {
    final Iterable<int> numbers = RegExp(r'\d+')
        .allMatches(list.group(1)!)
        .map((RegExpMatch m) => int.parse(m.group(0)!));
    final List<int> ordered = numbers.toList();
    if (ordered.isNotEmpty) return ordered;
  }

  final RegExpMatch? single = _singleChapter.firstMatch(text);
  if (single != null) return <int>[int.parse(single.group(1)!)];

  return const <int>[];
}

int _countIn(String text) {
  // Ignore a number immediately after "chapter(s)" -- that is a chapter, not a
  // question count. The `_questionCount` pattern already requires the word
  // "questions" to follow, so "chapters 1 and 2" cannot match it.
  final RegExpMatch? match = _questionCount.firstMatch(text);
  if (match == null) return kDefaultQuestionCount;
  return int.parse(match.group(1)!).clamp(kMinQuestionCount, kMaxQuestionCount);
}
