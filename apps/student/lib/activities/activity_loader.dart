import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'content_models.dart';
import 'content_repository.dart';

/// Resolves a chapter ordinal to cached content, generating it once when
/// online and there is nothing saved. Never shows a spinner over an
/// artificial delay: the only spinner here covers a real in-flight request,
/// and the offline-with-no-cache state says plainly what is true.
class ActivityLoader extends StatefulWidget {
  const ActivityLoader({
    super.key,
    required this.repository,
    required this.chapterOrdinal,
    required this.kind,
    required this.builder,
  });

  final ContentRepository? repository;
  final int chapterOrdinal;
  final ContentKind kind;
  final Widget Function(
    BuildContext context,
    GeneratedContentData content,
    List<String> specialNeeds,
  ) builder;

  @override
  State<ActivityLoader> createState() => _ActivityLoaderState();
}

class _ActivityLoaderState extends State<ActivityLoader> {
  late Future<_Loaded> _load = _run();

  Future<_Loaded> _run() async {
    final ContentRepository? repo = widget.repository;
    if (repo == null) {
      return const _Loaded.unavailable('You need to be signed in and online '
          'to open this for the first time.');
    }

    final Chapter? chapter = await repo.chapterForOrdinal(widget.chapterOrdinal);
    final String? studentId = await repo.studentId();
    if (chapter == null || studentId == null) {
      return const _Loaded.unavailable('That chapter has not finished syncing '
          'to this device yet. Connect once, then try again.');
    }
    final List<String> specialNeeds = await _specialNeedsFor(repo, studentId);

    final GeneratedContentData? hit = await repo.cached(
      chapterId: chapter.id,
      kind: widget.kind,
      studentId: studentId,
    );
    if (hit != null) {
      return _Loaded.ready(hit, specialNeeds);
    }

    try {
      final GeneratedContentData fresh = await repo.generate(
        chapterId: chapter.id,
        kind: widget.kind,
        studentId: studentId,
        mode: await repo.modeForChapter(chapter.id),
      );
      return _Loaded.ready(fresh, specialNeeds);
    } catch (_) {
      return const _Loaded.unavailable(
        "There's nothing saved for this chapter yet, and it can't be made "
        'without a connection. Try again once you are online.',
      );
    }
  }

  Future<List<String>> _specialNeedsFor(
    ContentRepository repo,
    String studentId,
  ) async {
    final Student? row = await (repo.database.select(repo.database.students)
          ..where(($StudentsTable t) => t.id.equals(studentId)))
        .getSingleOrNull();
    if (row == null) return const <String>[];
    try {
      final List<dynamic> parsed = jsonDecode(row.specialNeeds) as List<dynamic>;
      return parsed.map((dynamic e) => e.toString()).toList();
    } catch (_) {
      return const <String>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Loaded>(
      future: _load,
      builder: (BuildContext context, AsyncSnapshot<_Loaded> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(_titleFor(widget.kind))),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing this from your chapter notes…'),
                ],
              ),
            ),
          );
        }
        final _Loaded result = snapshot.data!;
        if (result.content == null) {
          return Scaffold(
            appBar: AppBar(title: Text(_titleFor(widget.kind))),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(result.message!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      key: const Key('activity-retry'),
                      onPressed: () => setState(() => _load = _run()),
                      child: const Text('Try again'),
                    ),
                    TextButton(
                      key: const Key('activity-home'),
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return widget.builder(context, result.content!, result.specialNeeds);
      },
    );
  }
}

String _titleFor(ContentKind kind) => switch (kind) {
      ContentKind.flashcards => 'Flashcards',
      ContentKind.story => 'Story',
      ContentKind.notes => 'Notes',
    };

class _Loaded {
  const _Loaded.ready(this.content, this.specialNeeds) : message = null;
  const _Loaded.unavailable(this.message)
      : content = null,
        specialNeeds = const <String>[];

  final GeneratedContentData? content;
  final List<String> specialNeeds;
  final String? message;
}
