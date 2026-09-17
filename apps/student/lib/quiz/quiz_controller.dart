import 'package:flutter/foundation.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Drives one quiz attempt: assembly, answering, and the four adaptive
/// follow-ups offered once the attempt is done.
///
/// The `forTesting` constructor takes questions directly so widget tests can
/// exercise `QuizRunner` and `QuizResult` with no database and no assembly
/// call -- the pure assembly logic already has its own unit tests.
class QuizController extends ChangeNotifier {
  /// [studentId] is `students.id`, not the auth user id: the pool, weakness
  /// and attempt tables all key off it.
  QuizController({
    required QuizRepository this._repository,
    required this._studentId,
    required this._schoolId,
  }) : _labels = const <String, String>{};

  QuizController.forTesting({
    required List<PoolQuestion> questions,
    this._labels = const <String, String>{},
    this._relaxedSeenSet = false,
  })  : _repository = null,
        _studentId = 'test-student',
        _schoolId = 'test-school',
        _pool = List<PoolQuestion>.of(questions),
        _questions = List<PoolQuestion>.of(questions),
        _chapterIds =
            questions.map((PoolQuestion q) => q.chapterId).toSet().toList();

  final QuizRepository? _repository;
  final String _studentId;
  final String _schoolId;

  /// The `students.id` this controller was built for -- exposed so callers
  /// can detect a stale, cross-student cache (e.g. router.dart's session
  /// cache after a sign-out/sign-in as a different student).
  String get studentId => _studentId;
  final Map<String, String> _labels;

  List<PoolQuestion> _pool = <PoolQuestion>[];
  List<PoolQuestion> _questions = <PoolQuestion>[];
  final List<int?> _answers = <int?>[];
  int _currentIndex = 0;
  bool _relaxedSeenSet = false;
  List<String> _chapterIds = <String>[];
  QuizMode _mode = QuizMode.prep;
  Set<String> _seenIds = <String>{};
  Map<String, double> _weaknessWeights = <String, double>{};
  Map<String, List<String>> _notes = <String, List<String>>{};
  int _seed = 0;
  String? _lastAttemptId;
  bool _submitted = false;

  List<PoolQuestion> get questions => List<PoolQuestion>.unmodifiable(_questions);
  List<int?> get answers => List<int?>.unmodifiable(_answers);
  int get currentIndex => _currentIndex;
  bool get relaxedSeenSet => _relaxedSeenSet;

  /// Explanations keyed by micro-skill id. Keyed rather than positional: a
  /// skill may have none or several, so a flat list cannot be lined up against
  /// [missedMicroSkills] without eventually mislabelling one.
  Map<String, List<String>> get notes =>
      Map<String, List<String>>.unmodifiable(_notes);
  String? get lastAttemptId => _lastAttemptId;

  /// True once this quiz has been submitted. The runner fires `onComplete`
  /// from a post-frame callback, which can run more than once for a single
  /// finished quiz.
  bool get isSubmitted => _submitted;

  PoolQuestion? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;

  bool get isComplete =>
      _questions.isNotEmpty && _currentIndex >= _questions.length;

  /// A human label for a micro-skill, for display. Falls back to the raw id
  /// when no label is on file -- callers still see *something* to work on.
  String labelFor(String microSkillId) => _labels[microSkillId] ?? microSkillId;

  int get score {
    int correct = 0;
    for (int i = 0; i < _answers.length && i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) correct++;
    }
    return correct;
  }

  /// Exactly the micro-skills of questions answered incorrectly -- an
  /// unanswered question also counts as missed.
  Set<String> get missedMicroSkills {
    final Set<String> missed = <String>{};
    for (int i = 0; i < _questions.length; i++) {
      final int? selected = i < _answers.length ? _answers[i] : null;
      if (selected != _questions[i].correctIndex) {
        missed.add(_questions[i].microSkillId);
      }
    }
    return missed;
  }

  bool get isPerfect =>
      _questions.isNotEmpty &&
      _answers.length == _questions.length &&
      missedMicroSkills.isEmpty;

  Set<String> get _currentAttemptIds =>
      _questions.map((PoolQuestion q) => q.id).toSet();

  /// Loads the pool and profile for [chapterIds] and assembles the first
  /// quiz. Only meaningful on the real (non-`forTesting`) constructor.
  Future<void> startQuiz({
    required List<String> chapterIds,
    int count = 10,
  }) async {
    final QuizRepository repository = _repository!;
    _chapterIds = chapterIds;
    // A quiz over a freshly chosen range is a new chain, not a retry of the
    // last one.
    _lastAttemptId = null;
    _pool = await repository.poolFor(chapterIds, _studentId);
    _weaknessWeights = await repository.weaknessWeightsFor(_studentId);
    _seenIds = await repository.recentlySeenFor(_studentId);
    _mode = await repository.modeFor(chapterIds, _studentId);

    _assemble(AssemblyRequest(
      chapterIds: _chapterIds,
      count: count,
      mode: _mode,
      weaknessWeights: _weaknessWeights,
      recentlySeenIds: _seenIds,
      seed: _seed++,
    ));
    notifyListeners();
  }

  /// Records the selected option for the current question and advances.
  void answer(int selectedIndex) {
    if (_currentIndex >= _questions.length) return;
    if (_currentIndex < _answers.length) {
      _answers[_currentIndex] = selectedIndex;
    } else {
      _answers.add(selectedIndex);
    }
    _currentIndex++;
    notifyListeners();
  }

  /// Persists the finished attempt. Safe to call under `forTesting`, where it
  /// is a no-op beyond folding this attempt's questions into the seen set.
  ///
  /// Idempotent: the runner schedules its completion callback from a
  /// post-frame callback, so a rebuild in that window would otherwise record
  /// the same answers a second time as a "retry". An empty quiz records
  /// nothing at all -- `question_count` is `> 0` server-side, so a zero-length
  /// attempt could never sync.
  Future<String?> submit() async {
    if (_submitted) return _lastAttemptId;
    if (_questions.isEmpty) return null;
    _submitted = true;

    _seenIds = <String>{..._seenIds, ..._currentAttemptIds};

    final QuizRepository? repository = _repository;
    if (repository == null) return null;

    final List<AnsweredQuestion> answered = <AnsweredQuestion>[
      for (int i = 0; i < _questions.length; i++)
        AnsweredQuestion(
          question: _questions[i],
          selectedIndex: i < _answers.length ? (_answers[i] ?? -1) : -1,
        ),
    ];

    final String attemptId = await repository.recordAttempt(
      draft: AttemptDraft(
        studentId: _studentId,
        schoolId: _schoolId,
        chapterIds: _chapterIds,
        mode: _mode,
        answers: answered,
        parentAttemptId: _lastAttemptId,
      ),
    );

    _lastAttemptId = attemptId;
    notifyListeners();
    return attemptId;
  }

  /// Option 1: same chapters, same size, this attempt added to the seen set
  /// so a straight repeat is unlikely.
  Future<void> regenerate() async {
    _seenIds = <String>{..._seenIds, ..._currentAttemptIds};
    _assemble(AssemblyRequest(
      chapterIds: _chapterIds,
      count: _questions.length,
      mode: _mode,
      weaknessWeights: _weaknessWeights,
      recentlySeenIds: _seenIds,
      seed: _seed++,
    ));
    notifyListeners();
  }

  /// Option 2. Below a perfect score this targets the missed micro-skills;
  /// on a perfect score there is nothing to miss, so it asks for harder
  /// questions from the same chapters instead -- never a dead end.
  Future<void> practiseMistakes() async {
    final bool perfect = isPerfect;
    final Set<String> missed = missedMicroSkills;
    _seenIds = <String>{..._seenIds, ..._currentAttemptIds};

    _assemble(AssemblyRequest(
      chapterIds: _chapterIds,
      count: _questions.length,
      mode: _mode,
      weaknessWeights: _weaknessWeights,
      recentlySeenIds: _seenIds,
      targetMicroSkills: perfect ? const <String>{} : missed,
      harderOnly: perfect,
      seed: _seed++,
    ));
    notifyListeners();
  }

  /// Option 4: explanations for whatever was missed, to read rather than a
  /// fifth quiz.
  Future<void> generateNotes() async {
    final Set<String> missed = missedMicroSkills;
    final QuizRepository? repository = _repository;
    _notes = repository != null
        ? await repository.explanationsFor(missed)
        : <String, List<String>>{
            for (final String skillId in missed)
              skillId: <String>['Notes on ${labelFor(skillId)}.'],
          };
    notifyListeners();
  }

  void _assemble(AssemblyRequest request) {
    final AssemblyResult result = assembleQuiz(request, _pool);
    _questions = result.questions;
    _relaxedSeenSet = result.relaxedSeenSet;
    _answers.clear();
    _currentIndex = 0;
    // A reassembled quiz is a fresh attempt, so it may be submitted again.
    _submitted = false;
  }
}
