import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Lets a teacher set how many chapters a subject has, and lists the
/// chapters that exist. Setting the count only ever creates the chapters
/// missing to reach it -- see [CurriculumRepository.setChapterCount] --
/// because reducing the count must never delete a chapter that already
/// holds micro-skills, a question pool, or graded attempts.
class ChapterEditor extends StatefulWidget {
  const ChapterEditor({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.subjectId,
  });

  final CurriculumRepository repository;
  final String schoolId;
  final String subjectId;

  @override
  State<ChapterEditor> createState() => _ChapterEditorState();
}

class _ChapterEditorState extends State<ChapterEditor> {
  final TextEditingController _countController = TextEditingController();

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final int? count = int.tryParse(_countController.text.trim());
    if (count == null || count < 0) return;
    await widget.repository.setChapterCount(
      schoolId: widget.schoolId,
      subjectId: widget.subjectId,
      count: count,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: const Key('chapter-count'),
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Chapter count'),
                ),
              ),
              ElevatedButton(
                key: const Key('chapter-count-save'),
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Chapter>>(
            stream: widget.repository.watchChaptersFor(widget.subjectId),
            builder: (BuildContext context, AsyncSnapshot<List<Chapter>> snapshot) {
              final List<Chapter> chapters = snapshot.data ?? const <Chapter>[];
              return ListView.builder(
                key: const Key('chapter-list'),
                itemCount: chapters.length,
                itemBuilder: (BuildContext context, int index) {
                  final Chapter chapter = chapters[index];
                  return ListTile(
                    key: Key('chapter-${chapter.id}'),
                    title: Text(chapter.title),
                    subtitle: Text('Ordinal ${chapter.ordinal}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
