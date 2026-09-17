import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/functions/console_functions.dart';
import 'package:syncedu_console/teacher/teaching/pptx_writer.dart';
import 'package:syncedu_console/teacher/teaching/teaching_repository.dart';
import 'package:syncedu_console/teacher/teaching/teaching_screen.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

final DateTime _now = DateTime.utc(2026, 3, 1);

/// A school with one teacher taking two classes for one subject, both taught
/// chapter `ch1`. Students answer `s1`; who gets it wrong is the caller's
/// choice, which is what lets a test steer the cross-class comparison.
Future<void> _seed(
  SyncEduDatabase db, {
  required Map<String, int> strugglingByClass,
  required Map<String, int> fineByClass,
}) async {
  await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 'sub1', schoolId: 's', name: 'Mathematics',
      createdAt: _now, updatedAt: _now));
  await db.into(db.chapters).insert(ChaptersCompanion.insert(
      id: 'ch1', schoolId: 's', subjectId: 'sub1', ordinal: 1,
      title: 'Quadratics', createdAt: _now, updatedAt: _now));
  await db.into(db.microSkills).insert(MicroSkillsCompanion.insert(
      id: 's1', schoolId: 's', chapterId: 'ch1', slug: 'factorising',
      label: 'Factorising', ordinal: 1, createdAt: _now, updatedAt: _now));
  await db.into(db.questions).insert(QuestionsCompanion.insert(
      id: 'q1', schoolId: 's', chapterId: 'ch1', microSkillId: 's1',
      difficulty: 2, stem: 'Solve x^2 - 5x + 6 = 0',
      options: jsonEncode(<String>['x = 2 or 3', 'x = -2 or -3', 'x = 5', 'x = 6']),
      correctIndex: 0, createdAt: _now, updatedAt: _now));

  for (final String classId in <String>{
    ...strugglingByClass.keys,
    ...fineByClass.keys,
  }) {
    await db.into(db.classes).insert(ClassesCompanion.insert(
        id: classId, schoolId: 's', name: 'Class $classId', yearLevel: 4,
        createdAt: _now, updatedAt: _now));
    await db.into(db.classSubjects).insert(ClassSubjectsCompanion.insert(
        id: 'cs-$classId', schoolId: 's', classId: classId,
        subjectId: 'sub1', teacherId: 'teacher-1',
        createdAt: _now, updatedAt: _now));
    await db.into(db.classChapterSched).insert(ClassChapterSchedCompanion.insert(
        id: 'sched-$classId', schoolId: 's', classId: classId,
        chapterId: 'ch1', taughtOn: Value(_now),
        createdAt: _now, updatedAt: _now));

    int index = 0;
    Future<void> student(String id, {required bool struggling}) async {
      await db.into(db.profiles).insert(ProfilesCompanion.insert(
          id: 'p-$id', schoolId: 's', role: 'student', fullName: 'Student $id',
          email: '$id@t', createdAt: _now, updatedAt: _now));
      await db.into(db.students).insert(StudentsCompanion.insert(
          id: id, schoolId: 's', profileId: 'p-$id',
          classId: Value(classId), createdAt: _now, updatedAt: _now));
      await db.into(db.attempts).insert(AttemptsCompanion.insert(
          id: 'a-$id', schoolId: 's', studentId: id, mode: 'revise',
          questionCount: 4, score: Value(struggling ? 1 : 4),
          submittedAt: Value(_now), createdAt: _now, updatedAt: _now));
      // Four items each: above the 3-item per-student floor.
      for (int i = 0; i < 4; i++) {
        final bool correct = struggling ? i == 0 : true;
        await db.into(db.attemptItems).insert(AttemptItemsCompanion.insert(
            id: 'ai-$id-$i', schoolId: 's', attemptId: 'a-$id',
            questionId: const Value('q1'), microSkillId: 's1',
            selectedIndex: Value(correct ? 0 : 1), isCorrect: correct,
            ordinal: i, createdAt: _now, updatedAt: _now));
      }
    }

    for (int i = 0; i < (strugglingByClass[classId] ?? 0); i++) {
      await student('$classId-w${index++}', struggling: true);
    }
    for (int i = 0; i < (fineByClass[classId] ?? 0); i++) {
      await student('$classId-r${index++}', struggling: false);
    }
  }
}

/// Pumps until [finder] matches.
///
/// Not `pumpAndSettle`: while a review loads the screen shows a
/// `CircularProgressIndicator`, whose animation never stops scheduling frames,
/// so `pumpAndSettle` exhausts its budget instead of settling. Pumping toward
/// a condition waits for the thing the test actually cares about.
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 200,
}) async {
  for (int i = 0; i < maxPumps; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 20));
  }
  fail('$finder never appeared after $maxPumps pumps');
}

void main() {
  late SyncEduDatabase db;
  late TeachingRepository repo;

  setUp(() {
    db = SyncEduDatabase.forTesting();
    repo = TeachingRepository(
      db: db,
      functions: const ConsoleFunctions(null),
      teacherId: 'teacher-1',
    );
  });
  tearDown(() => db.close());

  group('TeachingRepository', () {
    test('offers only chapters this teacher has actually taught', () async {
      await _seed(db,
          strugglingByClass: <String, int>{'c1': 6},
          fineByClass: <String, int>{'c1': 4});
      // A second chapter scheduled but never taught must not be offered.
      await db.into(db.chapters).insert(ChaptersCompanion.insert(
          id: 'ch2', schoolId: 's', subjectId: 'sub1', ordinal: 2,
          title: 'Trigonometry', createdAt: _now, updatedAt: _now));
      await db.into(db.classChapterSched).insert(ClassChapterSchedCompanion.insert(
          id: 'sched-untaught', schoolId: 's', classId: 'c1',
          chapterId: 'ch2', createdAt: _now, updatedAt: _now));

      final List<TeachableChapter> options = await repo.teachableChapters();

      expect(options, hasLength(1));
      expect(options.single.chapterId, 'ch1');
      expect(options.single.label, 'Class c1 / Quadratics');
    });

    test("another teacher's classes are not offered", () async {
      await _seed(db,
          strugglingByClass: <String, int>{'c1': 6},
          fineByClass: <String, int>{'c1': 4});
      await db.update(db.classSubjects).write(
          const ClassSubjectsCompanion(teacherId: Value('someone-else')));

      expect(await repo.teachableChapters(), isEmpty);
    });

    test('the review reads the wrong answers students actually chose',
        () async {
      await _seed(db,
          strugglingByClass: <String, int>{'c1': 6},
          fineByClass: <String, int>{'c1': 4});

      final TeachingReview review =
          await repo.review(classId: 'c1', chapterId: 'ch1');

      expect(review.signals, hasLength(1));
      final TeachingSignal signal = review.signals.single;
      expect(signal.proportion, closeTo(0.6, 0.001));
      expect(signal.affectedCount, 6);
      // Six students each picked option 1 three times: six students, not 18.
      expect(signal.misconceptions.single.optionText, 'x = -2 or -3');
      expect(signal.misconceptions.single.studentCount, 6);
      // One class only, so no comparison can be drawn.
      expect(signal.scope, TeachingScope.insufficientComparison);
    });

    test('a second class of the same teacher turns the finding material-wide',
        () async {
      await _seed(db,
          strugglingByClass: <String, int>{'c1': 6, 'c2': 5},
          fineByClass: <String, int>{'c1': 4, 'c2': 5});

      final TeachingReview review =
          await repo.review(classId: 'c1', chapterId: 'ch1');

      expect(review.signals.single.scope, TeachingScope.materialWide);
      expect(review.signals.single.cohortProportion, closeTo(0.5, 0.001));
      expect(review.ruleHeadline, contains('presentation problem'));
    });

    test('offline, generate falls back to the rule and still persists',
        () async {
      await _seed(db,
          strugglingByClass: <String, int>{'c1': 6},
          fineByClass: <String, int>{'c1': 4});
      final TeachingReview review =
          await repo.review(classId: 'c1', chapterId: 'ch1');

      final TeachingInsight insight =
          await repo.generate(schoolId: 's', review: review);

      expect(insight.source, 'rule');
      expect(insight.summary, review.ruleHeadline);
      expect(insight.actions, hasLength(1));
      // The offline deck is rendered from the findings, so its claims are
      // traceable to the same numbers on screen.
      expect(insight.deck.slides, isNotEmpty);
      expect(
        insight.deck.slides.first.bullets.single,
        contains('Factorising'),
      );

      final TeachingInsightRecord row =
          await db.select(db.teachingInsights).getSingle();
      expect(row.source, 'rule');
      expect(row.teacherId, 'teacher-1');
      expect(row.classId, 'c1');
      expect(jsonDecode(row.signals), hasLength(1));

      // Tier 1: queued as an append-only insert against the same id, so the
      // eventual push is idempotent against whatever the function wrote.
      final List<OutboxData> outbox = await db.select(db.outbox).get();
      expect(outbox, hasLength(1));
      expect(outbox.single.table, 'teaching_insights');
      expect(outbox.single.op, 'insert');
      expect(
        (jsonDecode(outbox.single.payload!) as Map<String, dynamic>)['id'],
        row.id,
      );
    });

    test('a saved review is readable back with no connection', () async {
      await _seed(db,
          strugglingByClass: <String, int>{'c1': 6},
          fineByClass: <String, int>{'c1': 4});
      final TeachingReview review =
          await repo.review(classId: 'c1', chapterId: 'ch1');
      final TeachingInsight saved =
          await repo.generate(schoolId: 's', review: review);

      final TeachingInsight? read = await repo.latest(
          classId: 'c1', chapterId: 'ch1', review: review);

      expect(read, isNotNull);
      expect(read!.id, saved.id);
      expect(read.summary, saved.summary);
      expect(read.deck.slides.length, saved.deck.slides.length);
      // And it still exports, offline, from the mirrored deck alone.
      expect(read.toPptx().lengthInBytes, greaterThan(0));
    });

    test('generating with no finding is refused rather than invented',
        () async {
      // Everyone passes: nothing reached the threshold.
      await _seed(db,
          strugglingByClass: <String, int>{'c1': 0},
          fineByClass: <String, int>{'c1': 10});
      final TeachingReview review =
          await repo.review(classId: 'c1', chapterId: 'ch1');

      expect(review.hasFindings, isFalse);
      expect(
        () => repo.generate(schoolId: 's', review: review),
        throwsStateError,
      );
    });
  });

  group('buildPptx', () {
    const DeckSpec deck = DeckSpec(
      title: 'Re-teach: Quadratics',
      subtitle: '4 Amanah',
      slides: <SlideSpec>[
        SlideSpec(
          title: 'Why "x = -2 or -3" is wrong',
          bullets: <String>['Signs flip when factorising', 'Check by expanding'],
          notes: 'Ask the class to expand (x-2)(x-3) on the board.',
        ),
        SlideSpec(title: 'No notes here', bullets: <String>['Just a bullet']),
      ],
    );

    test('writes a package whose parts and content types agree', () {
      final Archive archive = ZipDecoder().decodeBytes(buildPptx(deck));
      final Set<String> names =
          archive.files.map((ArchiveFile f) => f.name).toSet();

      // The cover is generated, so two content slides make three parts.
      expect(names, contains('[Content_Types].xml'));
      expect(names, contains('ppt/presentation.xml'));
      expect(names, contains('ppt/slides/slide1.xml'));
      expect(names, contains('ppt/slides/slide2.xml'));
      expect(names, contains('ppt/slides/slide3.xml'));
      expect(names, isNot(contains('ppt/slides/slide4.xml')));

      // Slide 2 has notes; slide 3 does not, and declaring an override for a
      // part that is absent is exactly what makes PowerPoint refuse a file.
      expect(names, contains('ppt/notesSlides/notesSlide2.xml'));
      expect(names, isNot(contains('ppt/notesSlides/notesSlide3.xml')));

      final String contentTypes = utf8.decode(
        archive.files
            .firstWhere((ArchiveFile f) => f.name == '[Content_Types].xml')
            .content as List<int>,
      );
      expect(contentTypes, contains('/ppt/notesSlides/notesSlide2.xml'));
      expect(contentTypes, isNot(contains('/ppt/notesSlides/notesSlide3.xml')));

      // Every override names a part that is actually in the package.
      final RegExp override = RegExp(r'PartName="/([^"]+)"');
      for (final RegExpMatch match in override.allMatches(contentTypes)) {
        expect(names, contains(match.group(1)), reason: match.group(1));
      }
    });

    test('every relationship target resolves to a part in the package', () {
      final Archive archive = ZipDecoder().decodeBytes(buildPptx(deck));
      final Set<String> names =
          archive.files.map((ArchiveFile f) => f.name).toSet();
      final RegExp target = RegExp(r'Target="([^"]+)"');

      for (final ArchiveFile file
          in archive.files.where((ArchiveFile f) => f.name.endsWith('.rels'))) {
        // "a/_rels/b.xml.rels" describes "a/b.xml", so targets resolve
        // against "a/".
        final String base = file.name
            .substring(0, file.name.length - file.name.split('/').last.length)
            .replaceAll(RegExp(r'_rels/$'), '');
        final String xml = utf8.decode(file.content as List<int>);
        for (final RegExpMatch match in target.allMatches(xml)) {
          final String resolved = _normalise('$base${match.group(1)}');
          expect(names, contains(resolved),
              reason: '${file.name} -> ${match.group(1)}');
        }
      }
    });

    test('model text is XML-escaped rather than breaking the package', () {
      const DeckSpec hostile = DeckSpec(
        title: 'A & B <hr>',
        subtitle: '"quoted"',
        slides: <SlideSpec>[
          SlideSpec(
            title: '5 < 6 & 7 > 2',
            bullets: <String>["it's <b>wrong</b>"],
            notes: 'a & b',
          ),
        ],
      );

      final Archive archive = ZipDecoder().decodeBytes(buildPptx(hostile));
      final String slide = utf8.decode(
        archive.files
            .firstWhere((ArchiveFile f) => f.name == 'ppt/slides/slide2.xml')
            .content as List<int>,
      );

      expect(slide, contains('5 &lt; 6 &amp; 7 &gt; 2'));
      expect(slide, isNot(contains('<b>')));
      // Well-formed: the only tags left are OOXML's own.
      expect(slide, contains('</p:sld>'));
    });

    test('a slide with no bullets still produces a valid text body', () {
      final Archive archive = ZipDecoder().decodeBytes(buildPptx(
        const DeckSpec(
          title: 'T',
          subtitle: 'S',
          slides: <SlideSpec>[SlideSpec(title: 'Empty', bullets: <String>[])],
        ),
      ));
      final String slide = utf8.decode(
        archive.files
            .firstWhere((ArchiveFile f) => f.name == 'ppt/slides/slide2.xml')
            .content as List<int>,
      );
      // An empty <p:txBody> is invalid; one empty paragraph is not.
      expect(slide, contains('<a:p><a:pPr/></a:p>'));
    });
  });

  group('TeachingScreen', () {
    testWidgets('exports the deck it is showing', (WidgetTester tester) async {
      await _seed(db,
          strugglingByClass: <String, int>{'c1': 6},
          fineByClass: <String, int>{'c1': 4});

      Uint8List? exported;
      String? filename;

      // The console is a desktop web app; the 800x600 default viewport pushes
      // the buttons off-screen, and a tap that misses looks exactly like a
      // callback that never fired.
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TeachingScreen(
            repository: repo,
            schoolId: 's',
            download: (Uint8List bytes, String name, String _) async {
              exported = bytes;
              filename = name;
            },
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('teaching-picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Class c1 / Quadratics').last);
      await _pumpUntil(tester, find.byKey(const Key('teaching-findings')));

      expect(find.byKey(const Key('teaching-findings')), findsOneWidget);
      expect(find.textContaining('Factorising'), findsWidgets);

      await tester.tap(find.byKey(const Key('teaching-generate')));
      await _pumpUntil(tester, find.byKey(const Key('teaching-summary')));

      // Offline: the rule wrote it, and the screen says so rather than
      // passing it off as the model's.
      expect(find.byKey(const Key('teaching-summary-source')), findsOneWidget);
      expect(find.textContaining('Rule-based summary'), findsOneWidget);
      expect(find.byKey(const Key('teaching-deck')), findsOneWidget);

      await tester.tap(find.byKey(const Key('teaching-export')));
      await tester.pump();

      expect(exported, isNotNull);
      expect(filename, 're-teach-Class-c1-Quadratics.pptx');
      expect(ZipDecoder().decodeBytes(exported!).files, isNotEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('says so when no chapter has been taught yet',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TeachingScreen(repository: repo, schoolId: 's'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('teaching-no-chapters')), findsOneWidget);
      expect(find.byKey(const Key('teaching-picker')), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  });
}

/// Collapses the `../` segments an OPC relationship target uses.
String _normalise(String path) {
  final List<String> parts = <String>[];
  for (final String segment in path.split('/')) {
    if (segment == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else if (segment.isNotEmpty && segment != '.') {
      parts.add(segment);
    }
  }
  return parts.join('/');
}
