import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_local/syncedu_local.dart';

import '../quiz/quiz_controller.dart';

/// The landing point for `/quiz/start?chapters=1,2&count=10` -- the route a
/// voice or button "quiz me" resolves to.
///
/// It maps chapter ordinals to local ids, assembles the quiz, and forwards to
/// the runner. An empty range or an empty pool sends the student back home
/// with a word rather than a blank screen.
class QuizStarter extends StatefulWidget {
  const QuizStarter({
    super.key,
    required this.database,
    required this.schoolId,
    required this.controller,
    required this.chapterOrdinals,
    required this.count,
  });

  final SyncEduDatabase database;
  final String schoolId;
  final QuizController controller;
  final List<int> chapterOrdinals;
  final int count;

  @override
  State<QuizStarter> createState() => _QuizStarterState();
}

class _QuizStarterState extends State<QuizStarter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final List<Chapter> rows = await (widget.database.select(
      widget.database.chapters,
    )..where(($ChaptersTable t) =>
            t.schoolId.equals(widget.schoolId) & t.deletedAt.isNull()))
        .get();
    final Map<int, String> byOrdinal = <int, String>{
      for (final Chapter c in rows) c.ordinal: c.id,
    };
    final List<String> chapterIds = <String>[
      for (final int ordinal in widget.chapterOrdinals)
        if (byOrdinal.containsKey(ordinal)) byOrdinal[ordinal]!,
    ];

    if (!mounted) return;
    if (chapterIds.isEmpty) {
      _bail('Those chapters are not on this device yet.');
      return;
    }

    await widget.controller.startQuiz(
      chapterIds: chapterIds,
      count: widget.count,
    );
    if (!mounted) return;
    if (widget.controller.questions.isEmpty) {
      _bail('There are no questions for that range yet.');
      return;
    }
    context.go('/quiz/run');
  }

  void _bail(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
