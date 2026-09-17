/// The six conversational tools, defined once in pure Dart.
///
/// The `chat` Edge Function declares these to Gemini and the offline
/// [matchLocalIntent] parser produces the same shapes, so the online and
/// offline paths cannot drift apart. A rename here is a rename everywhere; the
/// name-parity test in `chat/handler.ts`'s suite is what catches a one-sided
/// change.
library;

/// The tool names, exactly as declared to Gemini in `chat/handler.ts`.
///
/// Kept as a literal set (not derived from the classes below) so a test can
/// assert it against the function's `functionDeclarations` verbatim -- a
/// mismatch there silently breaks voice while every other test still passes.
const Set<String> kToolNames = <String>{
  'start_quiz',
  'open_flashcards',
  'open_story',
  'generate_notes',
  'show_progress',
  'pick_chapter',
};

/// Question counts a student can ask for are clamped to this range rather than
/// rejected: "a hundred questions" should start a twenty-question quiz, not an
/// error.
const int kMinQuestionCount = 5;
const int kMaxQuestionCount = 20;
const int kDefaultQuestionCount = 10;

sealed class ToolCall {
  const ToolCall();
}

class StartQuiz extends ToolCall {
  const StartQuiz({
    required this.chapterOrdinals,
    this.questionCount = kDefaultQuestionCount,
  });

  final List<int> chapterOrdinals;
  final int questionCount;

  @override
  bool operator ==(Object other) =>
      other is StartQuiz &&
      _listEquals(other.chapterOrdinals, chapterOrdinals) &&
      other.questionCount == questionCount;

  @override
  int get hashCode => Object.hash(Object.hashAll(chapterOrdinals), questionCount);

  @override
  String toString() =>
      'StartQuiz(chapters: $chapterOrdinals, count: $questionCount)';
}

class OpenFlashcards extends ToolCall {
  const OpenFlashcards({required this.chapterOrdinal});

  final int chapterOrdinal;

  @override
  bool operator ==(Object other) =>
      other is OpenFlashcards && other.chapterOrdinal == chapterOrdinal;

  @override
  int get hashCode => chapterOrdinal.hashCode;

  @override
  String toString() => 'OpenFlashcards(chapter: $chapterOrdinal)';
}

class OpenStory extends ToolCall {
  const OpenStory({required this.chapterOrdinal});

  final int chapterOrdinal;

  @override
  bool operator ==(Object other) =>
      other is OpenStory && other.chapterOrdinal == chapterOrdinal;

  @override
  int get hashCode => chapterOrdinal.hashCode;

  @override
  String toString() => 'OpenStory(chapter: $chapterOrdinal)';
}

class GenerateNotes extends ToolCall {
  const GenerateNotes({this.chapterOrdinal});

  /// Optional: "make me notes" with no chapter generates notes on the
  /// student's current weak spots instead.
  final int? chapterOrdinal;

  @override
  bool operator ==(Object other) =>
      other is GenerateNotes && other.chapterOrdinal == chapterOrdinal;

  @override
  int get hashCode => chapterOrdinal.hashCode;

  @override
  String toString() => 'GenerateNotes(chapter: $chapterOrdinal)';
}

class ShowProgress extends ToolCall {
  const ShowProgress();

  @override
  bool operator ==(Object other) => other is ShowProgress;

  @override
  int get hashCode => (ShowProgress).hashCode;

  @override
  String toString() => 'ShowProgress()';
}

class PickChapter extends ToolCall {
  const PickChapter();

  @override
  bool operator ==(Object other) => other is PickChapter;

  @override
  int get hashCode => (PickChapter).hashCode;

  @override
  String toString() => 'PickChapter()';
}

/// Builds a [ToolCall] from a tool name and its arguments, as returned by
/// Gemini's function calling or produced by the local matcher.
///
/// Returns null rather than throwing when the name is unknown or a required
/// argument is missing -- the caller then falls back to a plain reply or an
/// honest "I need a connection for that".
ToolCall? toolCallFromJson(String name, Map<String, dynamic> args) {
  switch (name) {
    case 'start_quiz':
      final List<int> ordinals = _intList(args['chapter_ordinals']);
      if (ordinals.isEmpty) return null;
      return StartQuiz(
        chapterOrdinals: ordinals,
        questionCount: clampQuestionCount(args['question_count']),
      );
    case 'open_flashcards':
      final int? ordinal = _asInt(args['chapter_ordinal']);
      if (ordinal == null) return null;
      return OpenFlashcards(chapterOrdinal: ordinal);
    case 'open_story':
      final int? ordinal = _asInt(args['chapter_ordinal']);
      if (ordinal == null) return null;
      return OpenStory(chapterOrdinal: ordinal);
    case 'generate_notes':
      return GenerateNotes(chapterOrdinal: _asInt(args['chapter_ordinal']));
    case 'show_progress':
      return const ShowProgress();
    case 'pick_chapter':
      return const PickChapter();
    default:
      return null;
  }
}

/// The in-app route a [ToolCall] navigates to, with its arguments encoded as
/// query parameters so a deep link carries everything assembly needs.
String routeFor(ToolCall call) {
  switch (call) {
    case StartQuiz(:final chapterOrdinals, :final questionCount):
      final String chapters = chapterOrdinals.join(',');
      return '/quiz/start?chapters=$chapters&count=$questionCount';
    case OpenFlashcards(:final chapterOrdinal):
      return '/flashcards?chapter=$chapterOrdinal';
    case OpenStory(:final chapterOrdinal):
      return '/story?chapter=$chapterOrdinal';
    case GenerateNotes(:final chapterOrdinal):
      return chapterOrdinal == null
          ? '/notes'
          : '/notes?chapter=$chapterOrdinal';
    case ShowProgress():
      return '/progress';
    case PickChapter():
      return '/quiz/pick';
  }
}

/// Clamps a requested count into [kMinQuestionCount]..[kMaxQuestionCount],
/// defaulting to [kDefaultQuestionCount] when none was given.
int clampQuestionCount(Object? raw) {
  final int? parsed = _asInt(raw);
  if (parsed == null) return kDefaultQuestionCount;
  return parsed.clamp(kMinQuestionCount, kMaxQuestionCount);
}

int? _asInt(Object? raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  if (raw is String) return int.tryParse(raw.trim());
  return null;
}

List<int> _intList(Object? raw) {
  if (raw is! List) return const <int>[];
  final List<int> out = <int>[];
  for (final Object? item in raw) {
    final int? value = _asInt(item);
    if (value != null) out.add(value);
  }
  return out;
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
