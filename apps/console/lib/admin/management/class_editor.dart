import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Fixed vocabulary of target learning styles. The spec does not name one,
/// so this is a judgment call: a small, defensible set an admin can pick
/// from, plus the option to leave it unset until placement runs.
const List<String> kTargetLearningStyles = <String>[
  'visual',
  'auditory',
  'kinesthetic',
  'reading_writing',
];

/// Lets an administrator create a class. `targetLearningStyle` is collected
/// here even though nothing in this task reads it back -- Phase 9 placement
/// does, so it must exist from the moment a class is created rather than
/// being bolted on later.
class ClassEditor extends StatefulWidget {
  const ClassEditor({
    super.key,
    required this.repository,
    required this.schoolId,
  });

  final ManagementRepository repository;
  final String schoolId;

  @override
  State<ClassEditor> createState() => _ClassEditorState();
}

class _ClassEditorState extends State<ClassEditor> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _yearLevel = TextEditingController();
  String? _targetLearningStyle;

  @override
  void dispose() {
    _name.dispose();
    _yearLevel.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final int? yearLevel = int.tryParse(_yearLevel.text);
    if (_name.text.trim().isEmpty || yearLevel == null) return;

    await widget.repository.createClass(
      schoolId: widget.schoolId,
      name: _name.text.trim(),
      yearLevel: yearLevel,
      targetLearningStyle: _targetLearningStyle,
    );

    _name.clear();
    _yearLevel.clear();
    setState(() => _targetLearningStyle = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            key: const Key('class-name'),
            controller: _name,
            decoration: const InputDecoration(labelText: 'Class name'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            key: const Key('class-year-level'),
            controller: _yearLevel,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Year level'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: DropdownButton<String?>(
            key: const Key('class-learning-style'),
            value: _targetLearningStyle,
            hint: const Text('Target learning style (optional)'),
            items: <DropdownMenuItem<String?>>[
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('None yet'),
              ),
              ...kTargetLearningStyles.map(
                (String style) => DropdownMenuItem<String?>(
                  value: style,
                  child: Text(style),
                ),
              ),
            ],
            onChanged: (String? value) =>
                setState(() => _targetLearningStyle = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            key: const Key('class-create'),
            onPressed: _create,
            child: const Text('Create class'),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ClassesData>>(
            stream: widget.repository.watchClasses(widget.schoolId),
            builder: (BuildContext context, AsyncSnapshot<List<ClassesData>> snapshot) {
              final List<ClassesData> classes = snapshot.data ?? const <ClassesData>[];
              return ListView.builder(
                key: const Key('class-list'),
                itemCount: classes.length,
                itemBuilder: (BuildContext context, int index) {
                  final ClassesData item = classes[index];
                  return ListTile(
                    key: Key('class-row-${item.id}'),
                    title: Text(item.name),
                    subtitle: Text('Year ${item.yearLevel}'),
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
