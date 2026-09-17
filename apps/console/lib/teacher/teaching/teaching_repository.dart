import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:uuid/uuid.dart';

import '../../functions/console_functions.dart';
import 'pptx_writer.dart';

/// One (class, chapter) the teaching tab can review: a chapter this class was
/// actually taught, in a subject this teacher takes for it.
class TeachableChapter {
  const TeachableChapter({
    required this.classId,
    required this.className,
    required this.chapterId,
    required this.chapterTitle,
    required this.subjectName,
    required this.taughtOn,
  });

  final String classId;
  final String className;
  final String chapterId;
  final String chapterTitle;
  final String subjectName;

  /// When the class was taught this chapter. Never null: an untaught chapter
  /// is not offered, because a class failing a chapter nobody has taught them
  /// says nothing at all about how it was presented.
  final DateTime taughtOn;

  String get label => '$className / $chapterTitle';
}

/// One improvement action, as generated or as derived from the rule.
class TeachingAction {
  const TeachingAction({
    required this.microSkillId,
    required this.title,
    required this.detail,
  });

  final String microSkillId;
  final String title;
  final String detail;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'microSkillId': microSkillId,
        'title': title,
        'detail': detail,
      };

  static TeachingAction fromJson(Map<String, dynamic> json) => TeachingAction(
        microSkillId: json['microSkillId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
      );
}

/// A finished review: the Dart-computed findings, the prose written about
/// them, and the deck. [source] is 'ai' when the model wrote the prose and
/// 'rule' when [TeachingReview.ruleHeadline] stood in.
class TeachingInsight {
  const TeachingInsight({
    required this.id,
    required this.review,
    required this.summary,
    required this.actions,
    required this.deck,
    required this.source,
    required this.createdAt,
  });

  final String id;
  final TeachingReview review;
  final String summary;
  final List<TeachingAction> actions;
  final DeckSpec deck;

  /// 'ai' or 'rule'.
  final String source;
  final DateTime createdAt;

  /// The deck as a `.pptx`, built locally. Works with no connection: the
  /// bytes come from [deck], which is already in the mirror.
  Uint8List toPptx() => buildPptx(deck);

  String get filename {
    final String safe = '${review.className}-${review.chapterTitle}'
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return 're-teach-${safe.isEmpty ? 'deck' : safe}.pptx';
  }
}

/// Reads the teaching tab's inputs out of the local mirror, computes the
/// review in Dart, and turns it into prose and slides.
///
/// The split is the one the whole console keeps: every number here comes from
/// `reviewTeaching`; the Edge Function is handed those numbers and writes
/// about them. Offline, the review still computes and still renders -- only
/// the prose and the deck are missing, and the deterministic headline stands
/// in for the prose.
class TeachingRepository {
  TeachingRepository({
    required SyncEduDatabase db,
    required this.functions,
    required this.teacherId,
  })  : _db = db,
        _outbox = OutboxWriter(db),
        _analytics = AnalyticsRepository(db);

  final SyncEduDatabase _db;
  final OutboxWriter _outbox;
  final AnalyticsRepository _analytics;
  final ConsoleFunctions functions;
  final String teacherId;

  static const Uuid _uuid = Uuid();
  static const AnalyticsThresholds _thresholds = AnalyticsThresholds.standard();

  /// The (class, chapter) pairs this teacher may review: their own classes,
  /// the subjects they take for each, and only chapters already taught.
  Future<List<TeachableChapter>> teachableChapters() async {
    final List<TypedResult> rows = await (_db
            .select(_db.classChapterSched)
            .join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        _db.classes,
        _db.classes.id.equalsExp(_db.classChapterSched.classId),
      ),
      innerJoin(
        _db.chapters,
        _db.chapters.id.equalsExp(_db.classChapterSched.chapterId),
      ),
      innerJoin(
        _db.subjects,
        _db.subjects.id.equalsExp(_db.chapters.subjectId),
      ),
      // The join that scopes this to the teacher: they must take this
      // subject for this class.
      innerJoin(
        _db.classSubjects,
        _db.classSubjects.classId.equalsExp(_db.classChapterSched.classId) &
            _db.classSubjects.subjectId.equalsExp(_db.chapters.subjectId) &
            _db.classSubjects.teacherId.equals(teacherId) &
            _db.classSubjects.deletedAt.isNull(),
      ),
    ])
          ..where(_db.classChapterSched.deletedAt.isNull() &
              _db.classChapterSched.taughtOn.isNotNull() &
              _db.classes.deletedAt.isNull() &
              _db.chapters.deletedAt.isNull() &
              _db.subjects.deletedAt.isNull()))
        .get();

    final List<TeachableChapter> result = rows.map((TypedResult row) {
      final ClassChapterSchedData schedule =
          row.readTable(_db.classChapterSched);
      final ClassesData klass = row.readTable(_db.classes);
      final Chapter chapter = row.readTable(_db.chapters);
      final Subject subject = row.readTable(_db.subjects);
      return TeachableChapter(
        classId: klass.id,
        className: klass.name,
        chapterId: chapter.id,
        chapterTitle: chapter.title,
        subjectName: subject.name,
        taughtOn: schedule.taughtOn!,
      );
    }).toList();

    result.sort((TeachableChapter a, TeachableChapter b) {
      final int byDate = b.taughtOn.compareTo(a.taughtOn);
      return byDate != 0 ? byDate : a.label.compareTo(b.label);
    });
    return result;
  }

  /// Computes the diagnostic for one (class, chapter).
  ///
  /// Reads rows across *all* of this teacher's classes, not just [classId]:
  /// the cross-class comparison is what separates a class that struggled from
  /// material that does not teach a skill, and it cannot be made from one
  /// class's rows.
  Future<TeachingReview> review({
    required String classId,
    required String chapterId,
  }) async {
    final List<AnalyticRow> rows = await _analytics.readRows();
    final Set<String> mine = await _teacherClassIds();
    final List<AnalyticRow> scoped = rows
        .where((AnalyticRow r) =>
            r.chapterId == chapterId &&
            (r.classId == classId || mine.contains(r.classId)))
        .toList();

    final (List<WrongAnswerRow>, Map<String, QuestionText>) wrong =
        await _wrongAnswers(chapterId);

    return reviewTeaching(
      rows: scoped,
      classId: classId,
      chapterId: chapterId,
      wrongAnswers: wrong.$1,
      questions: wrong.$2,
      thresholds: _thresholds,
    );
  }

  /// Every class this teacher takes any subject for.
  Future<Set<String>> _teacherClassIds() async {
    final List<ClassSubject> rows = await (_db.select(_db.classSubjects)
          ..where(($ClassSubjectsTable t) =>
              t.teacherId.equals(teacherId) & t.deletedAt.isNull()))
        .get();
    return rows.map((ClassSubject r) => r.classId).toSet();
  }

  /// The wrong answers on this chapter, with the question text needed to name
  /// the distractor students chose.
  Future<(List<WrongAnswerRow>, Map<String, QuestionText>)> _wrongAnswers(
    String chapterId,
  ) async {
    final List<TypedResult> rows = await (_db
            .select(_db.attemptItems)
            .join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        _db.attempts,
        _db.attempts.id.equalsExp(_db.attemptItems.attemptId),
      ),
      innerJoin(
        _db.questions,
        _db.questions.id.equalsExp(_db.attemptItems.questionId),
      ),
    ])
          ..where(_db.attemptItems.deletedAt.isNull() &
              _db.attempts.deletedAt.isNull() &
              _db.questions.deletedAt.isNull() &
              _db.attemptItems.isCorrect.equals(false) &
              _db.attempts.mode.equals('revise') &
              _db.questions.chapterId.equals(chapterId)))
        .get();

    final List<WrongAnswerRow> answers = <WrongAnswerRow>[];
    final Map<String, QuestionText> questions = <String, QuestionText>{};
    for (final TypedResult row in rows) {
      final AttemptItem item = row.readTable(_db.attemptItems);
      final Attempt attempt = row.readTable(_db.attempts);
      final Question question = row.readTable(_db.questions);
      answers.add(
        WrongAnswerRow(
          studentId: attempt.studentId,
          questionId: question.id,
          microSkillId: item.microSkillId,
          selectedIndex: item.selectedIndex,
        ),
      );
      questions.putIfAbsent(
        question.id,
        () => QuestionText(
          stem: question.stem,
          // The mirror stores the Postgres text[] as a JSON string.
          options: (jsonDecode(question.options) as List<dynamic>)
              .map((dynamic o) => o.toString())
              .toList(),
          correctIndex: question.correctIndex,
        ),
      );
    }
    return (answers, questions);
  }

  /// The most recent saved review for one (class, chapter), or null.
  ///
  /// Read from the mirror, so a teacher who generated a review yesterday can
  /// re-read it and re-export its deck with no connection today.
  Future<TeachingInsight?> latest({
    required String classId,
    required String chapterId,
    required TeachingReview review,
  }) async {
    final List<TeachingInsight> rows = await (_db.select(_db.teachingInsights)
          ..where(($TeachingInsightsTable t) =>
              t.teacherId.equals(teacherId) &
              t.classId.equals(classId) &
              t.chapterId.equals(chapterId) &
              t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$TeachingInsightsTable>>[
            ($TeachingInsightsTable t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(1))
        .get()
        .then((List<TeachingInsightRecord> found) => found
            .map((TeachingInsightRecord r) => _hydrate(r, review))
            .toList());
    return rows.isEmpty ? null : rows.first;
  }

  TeachingInsight _hydrate(TeachingInsightRecord row, TeachingReview review) {
    final Map<String, dynamic> deck =
        jsonDecode(row.deck) as Map<String, dynamic>;
    return TeachingInsight(
      id: row.id,
      review: review,
      summary: row.summary,
      actions: (jsonDecode(row.actions) as List<dynamic>)
          .map((dynamic a) =>
              TeachingAction.fromJson((a as Map<dynamic, dynamic>).cast<String, dynamic>()))
          .toList(),
      deck: _deckFrom(deck, review),
      source: row.source,
      createdAt: row.createdAt,
    );
  }

  DeckSpec _deckFrom(Map<String, dynamic> json, TeachingReview review) {
    return DeckSpec(
      title: json['title'] as String? ?? 'Re-teach: ${review.chapterTitle}',
      subtitle: _subtitleFor(review),
      slides: ((json['slides'] as List<dynamic>?) ?? const <dynamic>[])
          .map((dynamic raw) {
        final Map<String, dynamic> slide =
            (raw as Map<dynamic, dynamic>).cast<String, dynamic>();
        return SlideSpec(
          title: slide['title'] as String? ?? '',
          bullets: ((slide['bullets'] as List<dynamic>?) ?? const <dynamic>[])
              .map((dynamic b) => b.toString())
              .toList(),
          notes: slide['notes'] as String? ?? '',
        );
      }).toList(),
    );
  }

  String _subtitleFor(TeachingReview review) =>
      '${review.className} — ${review.subjectName} — built from '
      '${review.signals.length} flagged '
      '${review.signals.length == 1 ? 'micro-skill' : 'micro-skills'}';

  /// Generates the prose and the deck for [review], persists both, and
  /// returns them.
  ///
  /// Offline, or when the model call fails, the review still saves: the
  /// summary becomes [TeachingReview.ruleHeadline] and the deck is assembled
  /// in Dart from the findings themselves. A teacher who cannot reach the
  /// model still leaves with something to take into the classroom.
  Future<TeachingInsight> generate({
    required String schoolId,
    required TeachingReview review,
  }) async {
    if (!review.hasFindings) {
      throw StateError('nothing to review: no micro-skill was flagged');
    }

    final String id = _uuid.v4();
    String summary = review.ruleHeadline;
    List<TeachingAction> actions = _ruleActions(review);
    DeckSpec deck = _ruleDeck(review);
    String source = 'rule';

    if (functions.online) {
      try {
        final Map<String, dynamic> response =
            await functions.suggestTeaching(<String, dynamic>{
          'insightId': id,
          'classId': review.classId,
          'chapterId': review.chapterId,
          'className': review.className,
          'ruleHeadline': review.ruleHeadline,
          'signals': review.signals.map(_signalJson).toList(),
        });
        final String? prose = response['summary'] as String?;
        if (prose != null && prose.trim().isNotEmpty) {
          summary = prose;
          actions = ((response['actions'] as List<dynamic>?) ?? const <dynamic>[])
              .map((dynamic a) => TeachingAction.fromJson(
                  (a as Map<dynamic, dynamic>).cast<String, dynamic>()))
              .toList();
          final Map<String, dynamic>? rawDeck =
              (response['deck'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>();
          if (rawDeck != null) deck = _deckFrom(rawDeck, review);
          source = 'ai';
        }
      } catch (_) {
        // A model failure must not cost the teacher the diagnostic: the rule
        // versions above already hold, so fall through and persist those.
        source = 'rule';
      }
    }

    await _persist(
      id: id,
      schoolId: schoolId,
      review: review,
      summary: summary,
      actions: actions,
      deck: deck,
      source: source,
    );

    return TeachingInsight(
      id: id,
      review: review,
      summary: summary,
      actions: actions,
      deck: deck,
      source: source,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> _signalJson(TeachingSignal signal) => <String, dynamic>{
        'microSkillId': signal.microSkillId,
        'microSkillLabel': signal.microSkillLabel,
        'sentence': signal.sentence,
        'scope': signal.scope.name,
        'proportion': signal.proportion,
        'affectedCount': signal.affectedCount,
        'studentsAssessed': signal.studentsAssessed,
        'classSize': signal.classSize,
        'cohortProportion': signal.cohortProportion,
        'cohortStudentsAssessed': signal.cohortStudentsAssessed,
        'cohortClassCount': signal.cohortClassCount,
        'misconceptions': signal.misconceptions
            .map((Misconception m) => <String, dynamic>{
                  'questionStem': m.questionStem,
                  'optionText': m.optionText,
                  'studentCount': m.studentCount,
                })
            .toList(),
      };

  /// What the tab shows when the model is unreachable: one action per flagged
  /// skill, rendered from the finding rather than written.
  List<TeachingAction> _ruleActions(TeachingReview review) =>
      review.signals.map((TeachingSignal signal) {
        final String lead = switch (signal.scope) {
          TeachingScope.materialWide =>
            'Rework how this is presented, not who it was presented to.',
          TeachingScope.classSpecific =>
            'Re-teach this to ${review.className}; your other classes have it.',
          TeachingScope.insufficientComparison =>
            'Re-teach this, and check it again once another class has covered '
                'the chapter.',
        };
        final String evidence = signal.misconceptions.isEmpty
            ? signal.sentence
            : '${signal.sentence} The commonest wrong answer was '
                '"${signal.misconceptions.first.optionText}" on '
                '"${signal.misconceptions.first.questionStem}", chosen by '
                '${signal.misconceptions.first.studentCount} students.';
        return TeachingAction(
          microSkillId: signal.microSkillId,
          title: signal.microSkillLabel,
          detail: '$lead $evidence',
        );
      }).toList();

  /// The offline deck. Not generated prose: every line is rendered from the
  /// findings, so a teacher exporting with no connection gets a deck whose
  /// claims are all traceable to the numbers on their screen.
  DeckSpec _ruleDeck(TeachingReview review) {
    final List<SlideSpec> slides = <SlideSpec>[
      SlideSpec(
        title: 'What did not land',
        bullets: review.signals
            .map((TeachingSignal s) =>
                '${s.microSkillLabel}: ${(s.proportion * 100).round()}% of the '
                'assessed class struggling')
            .toList(),
        notes: review.ruleHeadline,
      ),
      for (final TeachingSignal signal in review.signals)
        SlideSpec(
          title: signal.microSkillLabel,
          bullets: <String>[
            signal.sentence,
            for (final Misconception m in signal.misconceptions)
              '${m.studentCount} students answered "${m.optionText}" to '
                  '"${m.questionStem}"',
          ],
          notes: 'Generated offline from the class figures. Reconnect and '
              'regenerate for a worked re-teach deck.',
        ),
    ];
    return DeckSpec(
      title: 'Re-teach: ${review.chapterTitle}',
      subtitle: _subtitleFor(review),
      slides: slides,
    );
  }

  /// Writes the review to the mirror and queues it for the server.
  ///
  /// Tier 1, append-only, keyed by the same client-supplied id the Edge
  /// Function was handed: when the function already persisted the row, this
  /// push is an ignore-duplicates upsert against it rather than a second row.
  Future<void> _persist({
    required String id,
    required String schoolId,
    required TeachingReview review,
    required String summary,
    required List<TeachingAction> actions,
    required DeckSpec deck,
    required String source,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final List<Map<String, dynamic>> signals =
        review.signals.map(_signalJson).toList();
    final Map<String, dynamic> deckJson = <String, dynamic>{
      'title': deck.title,
      'slides': deck.slides
          .map((SlideSpec s) => <String, dynamic>{
                'title': s.title,
                'bullets': s.bullets,
                'notes': s.notes,
              })
          .toList(),
    };
    final List<Map<String, dynamic>> actionsJson =
        actions.map((TeachingAction a) => a.toJson()).toList();

    await _db.into(_db.teachingInsights).insert(
          TeachingInsightsCompanion.insert(
            id: id,
            schoolId: schoolId,
            teacherId: teacherId,
            classId: review.classId,
            chapterId: review.chapterId,
            signals: Value(jsonEncode(signals)),
            summary: Value(summary),
            actions: Value(jsonEncode(actionsJson)),
            deck: Value(jsonEncode(deckJson)),
            source: Value(source),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );

    await _outbox.queueInsert(
      table: 'teaching_insights',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'teacher_id': teacherId,
        'class_id': review.classId,
        'chapter_id': review.chapterId,
        'signals': signals,
        'summary': summary,
        'actions': actionsJson,
        'deck': deckJson,
        'source': source,
      },
    );
  }
}
