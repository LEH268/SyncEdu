import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Lets a student pick one or more chapters, then starts a quiz over the
/// range they chose. This is also where "a new range" (follow-up option 3)
/// lands the student back.
class ChapterPicker extends StatefulWidget {
  const ChapterPicker({
    super.key,
    required this.database,
    required this.schoolId,
    required this.onStart,
  });

  final SyncEduDatabase database;
  final String schoolId;

  /// Called with the chosen chapter ids once the student taps "Start quiz".
  final void Function(List<String> chapterIds) onStart;

  @override
  State<ChapterPicker> createState() => _ChapterPickerState();
}

class _ChapterPickerState extends State<ChapterPicker> {
  final Set<String> _selected = <String>{};
  late final Future<List<Chapter>> _chapters;

  @override
  void initState() {
    super.initState();
    _chapters = (widget.database.select(widget.database.chapters)
          ..where(($ChaptersTable t) =>
              t.schoolId.equals(widget.schoolId) & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ChaptersTable>>[
            ($ChaptersTable t) => OrderingTerm.asc(t.ordinal),
          ]))
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a range')),
      body: FutureBuilder<List<Chapter>>(
        future: _chapters,
        builder: (BuildContext context, AsyncSnapshot<List<Chapter>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Chapter> chapters = snapshot.data!;
          return ListView(
            children: <Widget>[
              for (final Chapter chapter in chapters)
                CheckboxListTile(
                  title: Text(chapter.title),
                  value: _selected.contains(chapter.id),
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked ?? false) {
                        _selected.add(chapter.id);
                      } else {
                        _selected.remove(chapter.id);
                      }
                    });
                  },
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selected.isEmpty
            ? null
            : () => widget.onStart(_selected.toList()),
        label: const Text('Start quiz'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

/// Convenience used by the router: pops back here for "choose a different
/// range" rather than wiring a bespoke route per caller.
void goToChapterPicker(BuildContext context) => context.go('/quiz/pick');
