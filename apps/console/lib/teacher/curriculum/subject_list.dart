import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Lists the subjects a teacher teaches, and lets them add a new one. Reads
/// go through [CurriculumRepository.watchSubjectsForTeacher], which joins
/// through `class_subjects` so the console never shows a subject the teacher
/// does not own.
class SubjectList extends StatefulWidget {
  const SubjectList({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.teacherId,
    this.onSubjectTap,
  });

  final CurriculumRepository repository;
  final String schoolId;
  final String teacherId;
  final ValueChanged<Subject>? onSubjectTap;

  @override
  State<SubjectList> createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addSubject() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) return;
    await widget.repository.createSubject(
      schoolId: widget.schoolId,
      name: name,
    );
    _nameController.clear();
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
                  key: const Key('subject-name'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'New subject'),
                ),
              ),
              IconButton(
                key: const Key('subject-add'),
                icon: const Icon(Icons.add),
                onPressed: _addSubject,
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Subject>>(
            stream: widget.repository.watchSubjectsForTeacher(widget.teacherId),
            builder: (BuildContext context, AsyncSnapshot<List<Subject>> snapshot) {
              final List<Subject> subjects = snapshot.data ?? const <Subject>[];
              return ListView.builder(
                key: const Key('subject-list'),
                itemCount: subjects.length,
                itemBuilder: (BuildContext context, int index) {
                  final Subject subject = subjects[index];
                  return ListTile(
                    key: Key('subject-${subject.id}'),
                    title: Text(subject.name),
                    subtitle: Text('${subject.chapterCount} chapters'),
                    onTap: widget.onSubjectTap == null
                        ? null
                        : () => widget.onSubjectTap!(subject),
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
